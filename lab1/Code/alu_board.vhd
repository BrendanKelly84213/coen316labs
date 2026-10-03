library IEEE;
use IEEE.std_logic_1164.all;

entity alu_board is
    port(
        sw  : in  std_logic_vector(12 downto 0);
        LED : out std_logic_vector(5 downto 0)
    );
end alu_board;

architecture structural of alu_board is
    signal x_in       : std_logic_vector(3 downto 0);
    signal y_in       : std_logic_vector(3 downto 0);
    signal add_sub    : std_logic;
    signal logic_func : std_logic_vector(1 downto 0);
    signal func       : std_logic_vector(1 downto 0);
    signal x          : std_logic_vector(31 downto 0);
    signal y          : std_logic_vector(31 downto 0);
    signal alu_output : std_logic_vector(31 downto 0);
    signal overflow   : std_logic;
    signal zero       : std_logic;
begin
    x_in       <= sw(3 downto 0);
    y_in       <= sw(7 downto 4);
    add_sub    <= sw(8);
    logic_func <= sw(10 downto 9);
    func       <= sw(12 downto 11);

    x <= (31 downto 4 => '0') & x_in;
    y <= (31 downto 4 => '0') & y_in;

    alu_instance: entity work.alu
        port map(
            x        => x,
            y        => y,
            add_sub  => add_sub,
            logic_func => logic_func,
            func      => func,
            output   => alu_output,
            overflow => overflow,
            zero     => zero
        );

    LED(3 downto 0) <= alu_output(3 downto 0);
    LED(4)          <= overflow;
    LED(5)          <= zero;
end structural;
