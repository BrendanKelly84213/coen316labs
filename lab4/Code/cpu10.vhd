library IEEE;
use IEEE.std_logic_1164.all;

entity cpu10 is
    port(reset : in  std_logic;
         clk   : in  std_logic);
end cpu10;

architecture rtl of cpu10 is

    component cpu is
        port(reset          : in  std_logic;
             clk            : in  std_logic;
             rs_out, rt_out : out std_logic_vector(3 downto 0);
             pc_out         : out std_logic_vector(3 downto 0);
             overflow, zero : out std_logic);
    end component;

    -- one set of dangling signals per instance
    signal rs0, rs1, rs2, rs3, rs4, rs5, rs6, rs7, rs8, rs9 : std_logic_vector(3 downto 0);
    signal rt0, rt1, rt2, rt3, rt4, rt5, rt6, rt7, rt8, rt9 : std_logic_vector(3 downto 0);
    signal pc0, pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9 : std_logic_vector(3 downto 0);
    signal ov0, ov1, ov2, ov3, ov4, ov5, ov6, ov7, ov8, ov9 : std_logic;
    signal z0,  z1,  z2,  z3,  z4,  z5,  z6,  z7,  z8,  z9  : std_logic;

    -- DONT_TOUCH prevents the optimizer from deduplicating the CPUs
    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of U0 : label is "TRUE";
    attribute DONT_TOUCH of U1 : label is "TRUE";
    attribute DONT_TOUCH of U2 : label is "TRUE";
    attribute DONT_TOUCH of U3 : label is "TRUE";
    attribute DONT_TOUCH of U4 : label is "TRUE";
    attribute DONT_TOUCH of U5 : label is "TRUE";
    attribute DONT_TOUCH of U6 : label is "TRUE";
    attribute DONT_TOUCH of U7 : label is "TRUE";
    attribute DONT_TOUCH of U8 : label is "TRUE";
    attribute DONT_TOUCH of U9 : label is "TRUE";

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
    U5: cpu port map(reset=>reset, clk=>clk, rs_out=>rs5, rt_out=>rt5,
                     pc_out=>pc5, overflow=>ov5, zero=>z5);
    U6: cpu port map(reset=>reset, clk=>clk, rs_out=>rs6, rt_out=>rt6,
                     pc_out=>pc6, overflow=>ov6, zero=>z6);
    U7: cpu port map(reset=>reset, clk=>clk, rs_out=>rs7, rt_out=>rt7,
                     pc_out=>pc7, overflow=>ov7, zero=>z7);
    U8: cpu port map(reset=>reset, clk=>clk, rs_out=>rs8, rt_out=>rt8,
                     pc_out=>pc8, overflow=>ov8, zero=>z8);
    U9: cpu port map(reset=>reset, clk=>clk, rs_out=>rs9, rt_out=>rt9,
                     pc_out=>pc9, overflow=>ov9, zero=>z9);

end rtl;
