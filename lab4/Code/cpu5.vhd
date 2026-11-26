library IEEE;
use IEEE.std_logic_1164.all;

entity cpu5 is
    port(reset : in  std_logic;
         clk   : in  std_logic);
end cpu5;

architecture rtl of cpu5 is

    component cpu is
        port(reset          : in  std_logic;
             clk            : in  std_logic;
             rs_out, rt_out : out std_logic_vector(3 downto 0);
             pc_out         : out std_logic_vector(3 downto 0);
             overflow, zero : out std_logic);
    end component;

    -- one set of dangling signals per instance
    signal rs0, rs1, rs2, rs3, rs4 : std_logic_vector(3 downto 0);
    signal rt0, rt1, rt2, rt3, rt4 : std_logic_vector(3 downto 0);
    signal pc0, pc1, pc2, pc3, pc4 : std_logic_vector(3 downto 0);
    signal ov0, ov1, ov2, ov3, ov4 : std_logic;
    signal z0,  z1,  z2,  z3,  z4  : std_logic;

    -- DONT_TOUCH so the optimizer doesn't collapse the 5 CPUs into 1
    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of U0 : label is "TRUE";
    attribute DONT_TOUCH of U1 : label is "TRUE";
    attribute DONT_TOUCH of U2 : label is "TRUE";
    attribute DONT_TOUCH of U3 : label is "TRUE";
    attribute DONT_TOUCH of U4 : label is "TRUE";

begin
    U0: cpu port map(reset=>reset, clk=>clk, rs_out=>rs0, rt_out=>rt0,
                     pc_out=>pc0, overflow=>ov0, zero=>z0);
    U1: cpu port map(reset=>reset, clk=>clk, rs_out=>rs1, rt_out=>rt1,
                     pc_out=>pc1, overflow=>ov1, zero=>z1);
    U2: cpu port map(reset=>reset, clk=>clk, rs_out=>rs2, rt_out=>rt2,
                     pc_out=>pc2, overflow=>ov2, zero=>z2);
    U3: cpu port map(reset=>reset, clk=>clk, rs_out=>rs3, rt_out=>rt3,
                     pc_out=>pc3, overflow=>ov3, zero=>z3);
    U4: cpu port map(reset=>reset, clk=>clk, rs_out=>rs4, rt_out=>rt4,
                     pc_out=>pc4, overflow=>ov4, zero=>z4);
end rtl;
