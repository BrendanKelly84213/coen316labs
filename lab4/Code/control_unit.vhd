library IEEE;
use IEEE.std_logic_1164.all;

entity control_unit is
    port(opcode      : in  std_logic_vector(5 downto 0);
         func_in     : in  std_logic_vector(5 downto 0);  -- func field of the instruction

         reg_write   : out std_logic;
         reg_dst     : out std_logic;
         reg_in_src  : out std_logic;
         alu_src     : out std_logic;
         add_sub     : out std_logic;
         data_write  : out std_logic;
         logic_func  : out std_logic_vector(1 downto 0);
         func        : out std_logic_vector(1 downto 0);  -- 2-bit control signal
         branch_type : out std_logic_vector(1 downto 0);
         pc_sel      : out std_logic_vector(1 downto 0));
end control_unit;

architecture behavioural of control_unit is
begin
    process(opcode, func_in)
    begin
        -- defaults: a harmless "do nothing" instruction
        reg_write   <= '0';
        reg_dst     <= '0';
        reg_in_src  <= '1';
        alu_src     <= '0';
        add_sub     <= '0';
        data_write  <= '0';
        logic_func  <= "00";
        func        <= "10";
        branch_type <= "00";
        pc_sel      <= "00";

        case opcode is
            when "000000" =>  -- R-type, decided by func_in
                case func_in is
                    when "100000" =>  -- add
                        reg_write <= '1'; reg_dst <= '1';
                    when "100010" =>  -- sub
                        reg_write <= '1'; reg_dst <= '1'; add_sub <= '1';
                    when "101010" =>  -- slt
                        reg_write <= '1'; reg_dst <= '1'; add_sub <= '1'; func <= "01";
                    when "100100" =>  -- and
                        reg_write <= '1'; reg_dst <= '1'; func <= "11"; logic_func <= "00";
                    when "100101" =>  -- or
                        reg_write <= '1'; reg_dst <= '1'; func <= "11"; logic_func <= "01";
                    when "100110" =>  -- xor
                        reg_write <= '1'; reg_dst <= '1'; func <= "11"; logic_func <= "10";
                    when "100111" =>  -- nor
                        reg_write <= '1'; reg_dst <= '1'; func <= "11"; logic_func <= "11";
                    when "001000" =>  -- jr
                        pc_sel <= "10";
                    when others => null;
                end case;

            when "001111" =>  -- lui
                reg_write <= '1'; alu_src <= '1'; func <= "00";
            when "001000" =>  -- addi
                reg_write <= '1'; alu_src <= '1';
            when "001010" =>  -- slti
                reg_write <= '1'; alu_src <= '1'; add_sub <= '1'; func <= "01";
            when "001100" =>  -- andi
                reg_write <= '1'; alu_src <= '1'; func <= "11"; logic_func <= "00";
            when "001101" =>  -- ori
                reg_write <= '1'; alu_src <= '1'; func <= "11"; logic_func <= "01";
            when "001110" =>  -- xori
                reg_write <= '1'; alu_src <= '1'; func <= "11"; logic_func <= "10";
            when "100011" =>  -- lw
                reg_write <= '1'; reg_in_src <= '0'; alu_src <= '1';
            when "101011" =>  -- sw
                alu_src <= '1'; data_write <= '1';
            when "000100" =>  -- beq
                branch_type <= "01";
            when "000101" =>  -- bne
                branch_type <= "10";
            when "000001" =>  -- bltz
                branch_type <= "11";
            when "000010" =>  -- j
                pc_sel <= "01";
            when others => null;
        end case;
    end process;
end behavioural;
