# Add all ALU signals to the waveform window.
add wave -r /*

# Arithmetic: 0x00000003 + 0x00000002 = 0x00000005.
force x 00000000000000000000000000000011
force y 00000000000000000000000000000010
force add_sub 0
force logic_func 00
force func 10
run 10 ns

# Arithmetic: 0x00000003 - 0x00000002 = 0x00000001.
force add_sub 1
run 10 ns

# Set-less-than: 3 < 2 is false.
force func 01
run 10 ns

# LUI path: output is y.
force func 00
run 10 ns

# Logic operations with x = 0x0F and y = 0x33.
force x 00000000000000000000000000001111
force y 00000000000000000000000000110011
force func 11
force logic_func 00
run 10 ns

# OR
force logic_func 01
run 10 ns

# XOR
force logic_func 10
run 10 ns

# NOR
force logic_func 11
run 10 ns

# Signed overflow: 0x7FFFFFFF + 1.
force x 01111111111111111111111111111111
force y 00000000000000000000000000000001
force add_sub 0
force func 10
run 10 ns
