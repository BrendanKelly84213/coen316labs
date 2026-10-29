library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Board wrapper for next_address on the Nexys A7-100T.
-- narrow inputs are sign-extended into the core and only the low
-- 3 bits of next_pc are shown on LED[2:0].
--
-- Switch map (14 switches used):
--   sw[1:0]   rs_in
--   sw[3:2]   rt_in
--   sw[6:4]   pc_in
--   sw[9:7]   target_address_in
--   sw[11:10] branch_type
--   sw[13:12] pc_sel
-- LED map:
--   LED[2:0]  next_pc_out
entity next_address_board_wrapper is
port(rt_in, rs_in         : in  std_logic_vector(1 downto 0);
     pc_in                : in  std_logic_vector(2 downto 0);
     target_address_in    : in  std_logic_vector(2 downto 0);
     branch_type          : in  std_logic_vector(1 downto 0);
     pc_sel               : in  std_logic_vector(1 downto 0);
     next_pc_out          : out std_logic_vector(2 downto 0));
end next_address_board_wrapper;

architecture structural of next_address_board_wrapper is

    component next_address is
    port(rt, rs          : in  std_logic_vector(31 downto 0);
         pc              : in  std_logic_vector(31 downto 0);
         target_address  : in  std_logic_vector(25 downto 0);
         branch_type     : in  std_logic_vector(1 downto 0);
         pc_sel          : in  std_logic_vector(1 downto 0);
         next_pc         : out std_logic_vector(31 downto 0));
    end component;

    signal rt_32, rs_32, pc_32, next_pc_32 : std_logic_vector(31 downto 0);
    signal target_26                       : std_logic_vector(25 downto 0);

begin

    -- Sign-extend so signed compares (beq/bne/bltz) and the signed
    -- branch offset (target_address(15 downto 0)) behave correctly.
    rt_32     <= std_logic_vector(resize(signed(rt_in), 32));
    rs_32     <= std_logic_vector(resize(signed(rs_in), 32));
    pc_32     <= std_logic_vector(resize(signed(pc_in), 32));
    target_26 <= std_logic_vector(resize(signed(target_address_in), 26));

    uut : next_address
    port map(rt             => rt_32,
             rs             => rs_32,
             pc             => pc_32,
             target_address => target_26,
             branch_type    => branch_type,
             pc_sel         => pc_sel,
             next_pc        => next_pc_32);

    next_pc_out <= next_pc_32(2 downto 0);

end structural;
