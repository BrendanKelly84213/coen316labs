library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity alu is
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
end alu ;

architecture behavioural of alu is
    -- both signals have one more bit than the original
    signal x_s   : SIGNED(x'length downto 0);
    signal y_s   : SIGNED(y'length downto 0);
    signal sum_s : SIGNED(x'length downto 0);
    signal sum   : std_logic_vector(31 downto 0) := (others => '0');
    signal sum_msb : std_logic_vector(31 downto 0) := (others => '0');
    signal logic_o : std_logic_vector(31 downto 0) := (others => '0');
begin
    process (func, y, logic_o, sum, sum_msb) is
    begin
        case func is
            when "00" =>
                output <= y;
            when "01" =>
                output <= sum_msb;
            when "10" =>
                output <= sum;
            when others =>
                output <= logic_o;
        end case;
    end process;

    -- addition - subtraction
    -- convert type and perform a sign-extension
    x_s <= resize(signed(x), x_s'length);
    y_s <= resize(signed(y), y_s'length);

    -- addition of two 33 bit values
    sum_s <= x_s + y_s when add_sub = '0' else x_s - y_s;
    sum <= std_logic_vector(resize(sum_s, output'length));

    sum_msb <= (31 downto 1 => '0') & sum(31);
    zero <= '1' when sum = (sum'range => '0') else '0';
    overflow <= '1' when
        (add_sub = '0' and
            ((x_s(31) = '0' and y_s(31) = '0' and sum_s(31) = '1') or
             (x_s(31) = '1' and y_s(31) = '1' and sum_s(31) = '0'))) or
        (add_sub = '1' and
            ((x_s(31) /= y_s(31)) and (sum_s(31) /= x_s(31))))
        else '0';


    -- logic
    process (logic_o, logic_func) is
    begin
        case logic_func is
            when "00" => logic_o <= x and y;
            when "01" => logic_o <= x or y;
            when "10" => logic_o <= x xor y;
            when others => logic_o <= x nor y;
        end case;
    end process;


end behavioural;
