library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity cpu is
    port(reset          : in  std_logic;
         clk            : in  std_logic;
         rs_out, rt_out : out std_logic_vector(3 downto 0);
         pc_out         : out std_logic_vector(3 downto 0);
         overflow, zero : out std_logic);
end cpu;

architecture rtl of cpu is

    component datapath is
        port(clk          : in  std_logic;
             reset        : in  std_logic;
             pc_sel       : in  std_logic_vector(1 downto 0);
             reg_dst      : in  std_logic;
             reg_write    : in  std_logic;
             alu_src      : in  std_logic;
             branch_type  : in  std_logic_vector(1 downto 0);
             func         : in  std_logic_vector(1 downto 0);
             logic_func   : in  std_logic_vector(1 downto 0);
             add_sub      : in  std_logic;
             data_write   : in  std_logic;
             reg_in_src   : in  std_logic;
             func_out     : out std_logic_vector(5 downto 0);
             opcode       : out std_logic_vector(5 downto 0);
             alu_overflow : out std_logic;
             alu_zero     : out std_logic;
             rs_out       : out std_logic_vector(3 downto 0);
             rt_out       : out std_logic_vector(3 downto 0);
             pc_out       : out std_logic_vector(3 downto 0));
    end component;

    component control_unit is
        port(opcode      : in  std_logic_vector(5 downto 0);
             func_in     : in  std_logic_vector(5 downto 0);
             reg_write   : out std_logic;
             reg_dst     : out std_logic;
             reg_in_src  : out std_logic;
             alu_src     : out std_logic;
             add_sub     : out std_logic;
             data_write  : out std_logic;
             logic_func  : out std_logic_vector(1 downto 0);
             func        : out std_logic_vector(1 downto 0);
             branch_type : out std_logic_vector(1 downto 0);
             pc_sel      : out std_logic_vector(1 downto 0));
    end component;

    -- instruction fields: datapath -> control unit
    signal opcode_s   : std_logic_vector(5 downto 0);
    signal func_in_s  : std_logic_vector(5 downto 0);

    -- control signals: control unit -> datapath
    signal reg_write_s   : std_logic;
    signal reg_dst_s     : std_logic;
    signal reg_in_src_s  : std_logic;
    signal alu_src_s     : std_logic;
    signal add_sub_s     : std_logic;
    signal data_write_s  : std_logic;
    signal logic_func_s  : std_logic_vector(1 downto 0);
    signal func_s        : std_logic_vector(1 downto 0);
    signal branch_type_s : std_logic_vector(1 downto 0);
    signal pc_sel_s      : std_logic_vector(1 downto 0);

begin

    DP: datapath
    port map(clk          => clk,
             reset        => reset,
             pc_sel       => pc_sel_s,
             reg_dst      => reg_dst_s,
             reg_write    => reg_write_s,
             alu_src      => alu_src_s,
             branch_type  => branch_type_s,
             func         => func_s,
             logic_func   => logic_func_s,
             add_sub      => add_sub_s,
             data_write   => data_write_s,
             reg_in_src   => reg_in_src_s,
             func_out     => func_in_s,
             opcode       => opcode_s,
             alu_overflow => overflow,
             alu_zero     => zero,
             rs_out       => rs_out,
             rt_out       => rt_out,
             pc_out       => pc_out);

    CU: control_unit
    port map(opcode      => opcode_s,
             func_in     => func_in_s,
             reg_write   => reg_write_s,
             reg_dst     => reg_dst_s,
             reg_in_src  => reg_in_src_s,
             alu_src     => alu_src_s,
             add_sub     => add_sub_s,
             data_write  => data_write_s,
             logic_func  => logic_func_s,
             func        => func_s,
             branch_type => branch_type_s,
             pc_sel      => pc_sel_s);

end rtl;
