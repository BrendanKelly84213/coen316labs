-- Board wrapper for the 32 x 32 register file (Nexys A7-100T)
-- Only a subset of the I/O is brought out to switches, buttons and LEDs:
--   * data and addresses are narrowed (4-bit data, 2-bit addresses)
--   * the upper bits of the addresses and data are tied to '0'
--   * only R0..R3 are addressable, and only the low 4 bits of each are shown
library IEEE;
use IEEE.std_logic_1164.all;

entity regfile_wrapper is
port( din_in           : in  std_logic_vector(3 downto 0);   -- sw[3:0]
      reset            : in  std_logic;                      -- BTNU   (async, active high)
      clk              : in  std_logic;                      -- BTNC   (push button as clock)
      write            : in  std_logic;                      -- sw[10]
      read_a_in        : in  std_logic_vector(1 downto 0);   -- sw[5:4]
      read_b_in        : in  std_logic_vector(1 downto 0);   -- sw[7:6]
      write_address_in : in  std_logic_vector(1 downto 0);   -- sw[9:8]
      out_a_out        : out std_logic_vector(3 downto 0);   -- LED[3:0]
      out_b_out        : out std_logic_vector(3 downto 0));  -- LED[7:4]
end regfile_wrapper;

architecture structural of regfile_wrapper is

    signal din_full   : std_logic_vector(31 downto 0);
    signal read_a_f   : std_logic_vector(4 downto 0);
    signal read_b_f   : std_logic_vector(4 downto 0);
    signal wr_addr_f  : std_logic_vector(4 downto 0);
    signal out_a_full : std_logic_vector(31 downto 0);
    signal out_b_full : std_logic_vector(31 downto 0);

begin

    -- zero-extend the narrow board inputs to the full-width register file ports
    din_full  <= (31 downto 4 => '0') & din_in;
    read_a_f  <= "000" & read_a_in;
    read_b_f  <= "000" & read_b_in;
    wr_addr_f <= "000" & write_address_in;

    u_regfile : entity work.regfile
        port map (
            din           => din_full,
            reset         => reset,
            clk           => clk,
            write         => write,
            read_a        => read_a_f,
            read_b        => read_b_f,
            write_address => wr_addr_f,
            out_a         => out_a_full,
            out_b         => out_b_full
        );

    -- only the 4 least significant bits go to the LEDs
    out_a_out <= out_a_full(3 downto 0);
    out_b_out <= out_b_full(3 downto 0);

end structural;
