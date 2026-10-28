library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity next_address is
port(rt_in, rs_in : in std_logic_vector(1 downto 0);
    pc_in         : in std_logic_vector(2 downto 0);
    target_address_in : in std_logic_vector(2 downto 0);
    branch_type       : in std_logic_vector(1 downto 0);
    pc_sel            : in std_logic_vector(1 downto 0);
    next_pc_out       : out std_logic_vector(2 downto 0));
end next_address ;
