library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity datapath is
    port(clk         : in std_logic;
         reset       : in std_logic;
         pc_sel      : in std_logic_vector(1 downto 0);
         reg_dst     : in std_logic;
         reg_write   : in std_logic;
         alu_src     : in std_logic; -- AluOp in the textbook diagram
         branch_type : in std_logic_vector(1 downto 0);
         func        : in std_logic_vector(1 downto 0); -- control unit output for the alu
         logic_func  : in std_logic_vector(1 downto 0);
         add_sub     : in std_logic;
         data_write  : in std_logic;
         reg_in_src  : in std_logic;

         func_out    : out std_logic_vector(5 downto 0);
         opcode      : out std_logic_vector(5 downto 0);

         alu_overflow : out std_logic;
         alu_zero     : out std_logic;

         rs_out : out std_logic_vector(3 downto 0);
         rt_out : out std_logic_vector(3 downto 0);
         pc_out : out std_logic_vector(3 downto 0)
     );
end datapath;

architecture behavioural of datapath is

    component next_address is
    port(rt, rs : in std_logic_vector(31 downto 0); -- two register inputs
        pc      : in std_logic_vector(31 downto 0);
        target_address : in std_logic_vector(25 downto 0);
        branch_type    : in std_logic_vector(1 downto 0);
        pc_sel         : in std_logic_vector(1 downto 0);
        next_pc        : out std_logic_vector(31 downto 0));
    end component;

    component alu is
    port(x, y : in std_logic_vector(31 downto 0);
        -- two input operands
        add_sub    : in std_logic ; -- 0 = add , 1 = sub
        logic_func : in std_logic_vector(1 downto 0 ) ;
        -- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
        func       : in std_logic_vector(1 downto 0 ) ;
        -- 00 = lui, 01 = setless , 10 = arith , 11 = logic
        output     : out std_logic_vector(31 downto 0) ;
        overflow   : out std_logic ;
        zero       : out std_logic);
    end component;

    component regfile is
    port( din : in std_logic_vector(31 downto 0);
        reset : in std_logic;
        clk : in std_logic;
        write : in std_logic;
        read_a : in std_logic_vector(4 downto 0);
        read_b : in std_logic_vector(4 downto 0);
        write_address : in std_logic_vector(4 downto 0);
        out_a : out std_logic_vector(31 downto 0);
        out_b : out std_logic_vector(31 downto 0));
    end component;

    signal icache : std_logic_vector(31 downto 0);

    signal rs : std_logic_vector(4 downto 0);
    signal rt : std_logic_vector(4 downto 0);
    signal rd : std_logic_vector(4 downto 0);
    signal imm : std_logic_vector(15 downto 0); -- immediate mode

    signal alu_dout : std_logic_vector(31 downto 0);
    signal writereg : std_logic_vector(4 downto 0); -- register to write to?

    signal rfile_out_a : std_logic_vector(31 downto 0);
    signal rfile_out_b : std_logic_vector(31 downto 0);

    signal write_data : std_logic_vector(31 downto 0) := (others => '0');

    signal alu_out : std_logic_vector(31 downto 0);
    
    signal sgn_extend_out : std_logic_vector(31 downto 0);

    signal alu_y : std_logic_vector(31 downto 0);

    -- next_address calculation signal
    signal pc : std_logic_vector(31 downto 0); -- temporary
    signal next_pc : std_logic_vector(31 downto 0);
    signal target_address : std_logic_vector(25 downto 0);
    
    -- data cache
    type t_datacache is array (0 to 31) of std_logic_vector(31 downto 0); 
    signal datacache : t_datacache := (others => (others => '0'));
    signal datacache_out : std_logic_vector(31 downto 0);
begin

    -- hardcoded icache
    process(pc)
    begin
        case pc(4 downto 0) is
            when "00000" => icache <= "00100000000000110000000000000000"; -- addi r3, r0, 0
            when "00001" => icache <= "00100000000000010000000000000000"; -- addi r1, r0, 0
            when "00010" => icache <= "00100000000000100000000000000101"; -- addi r2,r0,5
            when "00011" => icache <= "00000000001000100000100000100000"; -- add r1,r1,r2
            when "00100" => icache <= "00100000010000101111111111111111"; -- addi r2, r2, -1
            when "00101" => icache <= "00010000010000110000000000000001"; -- beq r2,r3 (+1) THERE
            when "00110" => icache <= "00001000000000000000000000000011"; -- jump 3  (LOOP)
            when "00111" => icache <= "10101100000000010000000000000000"; -- sw r1, 0(r0)
            when "01000" => icache <= "10001100000001000000000000000000"; -- lw r4, 0(r0)
            when "01001" => icache <= "00110000100001000000000000001010"; -- andi r4,r4, 0x000A
            when "01010" => icache <= "00110100100001000000000000000001"; -- ori r4,r4, 0x0001
            when "01011" => icache <= "00111000100001000000000000001011"; -- xori r4,r4, 0xB
            when "01100" => icache <= "00111000100001000000000000000000"; -- xori r4,r4, 0x0000
            when others  => icache <= "00000000000000000000000000000000"; -- dont care
        end case;
    end process;


    opcode <= icache(31 downto 26);
    rs <= icache(25 downto 21);
    rt <= icache(20 downto 16);
    rd <= icache(15 downto 11);
    -- the lab calls 2 seperate things "func", this one will be used as an input to the control unit
    -- the control unit also outputs something called "func", which we will use to decide alu operation
    func_out <= icache(5 downto 0);

    imm <= icache(15 downto 0);
    target_address <= icache(25 downto 0);

    -- reg_dst = '0' in immediate mode
    writereg <= rt when reg_dst = '0' else
                rd;

    -- sign extendor
    process(func, imm)
    begin
        case func is
            when "00" =>
                sgn_extend_out <= imm & (15 downto 0 => '0');
            when "01" | "10" =>
                sgn_extend_out <= std_logic_vector(resize(signed(imm), 32));
            when others => 
                sgn_extend_out <= (31 downto 16 => '0') & imm;
        end case;
    end process;

    -- FIXME: multiplexer with reg_in_src whether this comes from data cache or alu output
    write_data <= alu_out when reg_in_src = '1' else
                  datacache_out;

    U1: regfile
    port map (din           => write_data, -- output of alu
              reset         => reset,
              clk           => clk,
              write         => reg_write, -- placeholder, control signal
              read_a        => rs,
              read_b        => rt,
              write_address => writereg,
              out_a         => rfile_out_a,
              out_b         => rfile_out_b);

    
    alu_y <= sgn_extend_out when alu_src = '1' else
             rfile_out_b;

    U2: alu
    port map(x          => rfile_out_a,
             y          => alu_y,
            add_sub     => add_sub,
            logic_func  => logic_func,
            func        => func,
            output      => alu_out,
            overflow    => alu_overflow,
            zero        => alu_zero);


    -- pc register
    process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            pc <= next_pc;
        end if;
    end process;

    U3: next_address
    port map (rt             => rfile_out_b, 
              rs             => rfile_out_a,
              pc             => pc,
              target_address => target_address,
              branch_type    => branch_type,
              pc_sel         => pc_sel,
              next_pc        => next_pc);

    -- d-cache
    process(clk, reset)
    begin
        if reset = '1' then
            datacache <= (others => (others => '0'));
        elsif rising_edge(clk)  then
            if data_write = '1' then
                datacache(to_integer(unsigned(alu_out(4 downto 0)))) <= rfile_out_b;    
            end if;
        end if;
    end process;

    datacache_out <= datacache(to_integer(unsigned(alu_out(4 downto 0))));

    -- datapath outputs
    rs_out <= rfile_out_a(3 downto 0);
    rt_out <= rfile_out_b(3 downto 0);
    pc_out <= pc(3 downto 0);

end behavioural;

