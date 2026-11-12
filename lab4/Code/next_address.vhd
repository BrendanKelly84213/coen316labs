library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity next_address is
port(rt, rs : in std_logic_vector(31 downto 0);
        -- two register inputs
    pc      : in std_logic_vector(31 downto 0);
    target_address : in std_logic_vector(25 downto 0);
    branch_type    : in std_logic_vector(1 downto 0);
    pc_sel         : in std_logic_vector(1 downto 0);
    next_pc        : out std_logic_vector(31 downto 0));
end next_address ;

architecture behavioural of next_address is 
    signal branch : std_logic_vector(31 downto 0);
    signal jump : std_logic_vector(31 downto 0);
    signal sign_extended_beq : signed(31 downto 0);
    signal sign_extended_bne : signed(31 downto 0);
    signal sign_extended_bltz : signed(31 downto 0);
begin

    with pc_sel select
        next_pc <= branch when "00",
                   jump   when "01",
                   rs     when "10",
                   pc     when others;

    with branch_type select
        branch <= std_logic_vector(signed(pc) + 1) when "00",
                  std_logic_vector(signed(pc) + 1 + sign_extended_beq) when "01",
                  std_logic_vector(signed(pc) + 1 + sign_extended_bne) when "10",
                  std_logic_vector(signed(pc) + 1 + sign_extended_bltz) when  others;

    
    sign_extended_beq <= resize(signed(target_address(15 downto 0)), 32) when signed(rt) = signed(rs) else 
                         (others => '0');
    sign_extended_bne <= resize(signed(target_address(15 downto 0)), 32) when signed(rt) /= signed(rs) else 
                         (others => '0');
    sign_extended_bltz <= resize(signed(target_address(15 downto 0)), 32) when signed(rs) < 0 else 
                         (others => '0');

    jump <= std_logic_vector(resize(unsigned(target_address), 32));

end behavioural;

