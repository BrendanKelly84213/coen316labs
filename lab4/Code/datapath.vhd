library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity datapath is 
    port(
        clk : in std_logic; 
        reset : in std_logic;
        );
end datapath;

architecture behavioural of datapath is

    component next_address is
    port(rt, rs : in std_logic_vector(31 downto 0);
            -- two register inputs
        pc      : in std_logic_vector(31 downto 0);
        target_address : in std_logic_vector(25 downto 0);
        branch_type    : in std_logic_vector(1 downto 0);
        pc_sel         : in std_logic_vector(1 downto 0);
        next_pc        : out std_logic_vector(31 downto 0));
    end component 

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

    signal pc : std_logic_vector(31 downto 0);
    signal icache : std_logic_vector(31 downto 0);
    signal reg_dst : std_logic;

    signal rs : std_logic_vector(4 downto 0);
    signal rt : std_logic_vector(4 downto 0);
    signal rd : std_logic_vector(4 downto 0);

    signal alu_dout : std_logic_vector(31 downto 0);
    signal regwrite : std_logic; -- TODO: implement me
    signal writereg : std_logic_vector(4 downto 0); -- register to write to?

    signal rfile_out_a : std_logic_vector(31 downto 0);
    signal rfile_out_b : std_logic_vector(31 downto 0);

    signal alu_in_y : std_logic_vector(31 downto 0);
    signal alu_src : std_logic; -- control signal, placeholder for now
    
    signal add_sub : std_logic;
    signal alu_out_zero : std_logic;

    signal sgn_extend_icache_out : std_logic_vector(31 downto 0);

    signal dcache_out : std_logic_vector(31 downto 0);
    signal data_write : std_logic;
    signal dcache_din : std_logic_vector(31 downto 0);
    signal dcache_addr : std_logic_vector(4 downto 0);
begin

    -- hardcoded icache 
    -- 
--       "00000"   "00100000000000110000000000000000"; -- addi r3, r0, 0
--       "00001"   "00100000000000010000000000000000"; -- addi r1, r0, 0
--       "00010"   "00100000000000100000000000000101"; -- addi r2,r0,5
-- LOOP: "00011"   "00000000001000100000100000100000"; -- add r1,r1,r2
--       "00100"   "00100000010000101111111111111111"; -- addi r2, r2, -1
--       "00101"   "00010000010000110000000000000001"; -- beq r2,r3 (+1) THERE
--       "00110"   "00001000000000000000000000000011"; -- jump 3  (LOOP)
-- THERE:"00111"   "10101100000000010000000000000000"; -- sw r1, 0(r0)  
--       "01000"   "10001100000001000000000000000000"; -- lw r4, 0(r0)
--       "01001"   "00110000100001000000000000001010"; -- andi r4,r4, 0x000A
--       "01010"   "00110100100001000000000000000001"; -- ori r4,r4, 0x0001
--       "01011"   "00111000100001000000000000001011"; -- xori r4,r4, 0xB
--       "01100"   "00111000100001000000000000000000"; -- xori r4,r4, 0x0000
--       others    "00000000000000000000000000000000"; -- dont care

    process(clk, pc)
        variable low_order : std_logic_vector(4 downto 0) := pc(4 downto 0);
    begin
        if (rising_edge(clk)) then
            case pc is
                when "00000" => icache <= "00100000000000110000000000000000"; 
                when "00001" => icache <= "00100000000000010000000000000000"; 
                when "00010" => icache <= "00100000000000100000000000000101"; 
                when "00011" => icache <= "00000000001000100000100000100000"; 
                when "00100" => icache <= "00100000010000101111111111111111"; 
                when "00101" => icache <= "00010000010000110000000000000001"; 
                when "00110" => icache <= "00001000000000000000000000000011"; 
                when "00111" => icache <= "10101100000000010000000000000000"; 
                when "01000" => icache <= "10001100000001000000000000000000"; 
                when "01001" => icache <= "00110000100001000000000000001010"; 
                when "01010" => icache <= "00110100100001000000000000000001"; 
                when "01011" => icache <= "00111000100001000000000000001011"; 
                when "01100" => icache <= "00111000100001000000000000000000"; 
                when others  => icache <= "00000000000000000000000000000000"; 
            end case;
        end if;
    end process;


    writereg <= rt when reg_dst = "0" else
                rd;

    write_data <= alu_dout when mem_to_reg = "0" else
                  dcache_out;
    -- regfile
    U1: regfile
    port map (din           => write_data; -- output of alu
              reset         => reset;
              clk           => clk;
              write         => regwrite; -- placeholder, control signal
              read_a        => rs;
              read_b        => rt;
              write_address => writereg;
              out_a         => rfile_out_a;
              out_b         => rfile_out_b);
             
    -- FIXME: sign extension is more complicated than this. Depends on instruction
    --        load uppper immediate: pad 16 0s at least significant position
    --        set less immediate: arithmetic sign extend (pad high order with sign bit)
    --        arithmetic: same as above
    --        logical: high order 16 bits padded with 0s
    alu_in_y <= rfile_out_b when alu_src = "0" else 
                sgn_extend_icache_out; 
    U2: alu
    port map (x          => rfile_out_a;
              y          => alu_in_y;
              add_sub    => add_sub; 
              logic_func => logic_func;
              func       => func;
              output     => alu_dout;
              overflow   => alu_out_overflow;
              zero       => alu_out_zero);

    -- Data cache process
    process(clk, reset, dcache_din, dcache_addr, data_write)
    begin
        -- FIXME: reset 
        if (rising_edge(clk) ) then
            if (data_write = '1') then
                dcache_lookup(to_integer(unsigned(dcache_addr))) <= dcache_din;
            else
                dcache_out <= dcache_lookup(to_integer(unsigned(dcache_addr)));
            end if;
        end if;
    end process;

end behavioural;

