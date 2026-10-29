## Nexys A7-100T constraints for next_address_board_wrapper
## Design is purely combinational, so no clock is constrained.

## Switches -----------------------------------------------------------
# rs_in[1:0]  = sw[1:0]
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { rs_in[0] }]; #sw[0]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { rs_in[1] }]; #sw[1]

# rt_in[1:0]  = sw[3:2]
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { rt_in[0] }]; #sw[2]
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { rt_in[1] }]; #sw[3]

# pc_in[2:0]  = sw[6:4]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { pc_in[0] }]; #sw[4]
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { pc_in[1] }]; #sw[5]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { pc_in[2] }]; #sw[6]

# target_address_in[2:0] = sw[9:7]  (sw[8], sw[9] are on a 1.8V bank)
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { target_address_in[0] }]; #sw[7]
set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS18 } [get_ports { target_address_in[1] }]; #sw[8]
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS18 } [get_ports { target_address_in[2] }]; #sw[9]

# branch_type[1:0] = sw[11:10]
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports { branch_type[0] }]; #sw[10]
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 } [get_ports { branch_type[1] }]; #sw[11]

# pc_sel[1:0] = sw[13:12]
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports { pc_sel[0] }]; #sw[12]
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports { pc_sel[1] }]; #sw[13]

## LEDs ---------------------------------------------------------------
# next_pc_out[2:0] = LED[2:0]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { next_pc_out[0] }]; #LED[0]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { next_pc_out[1] }]; #LED[1]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { next_pc_out[2] }]; #LED[2]
