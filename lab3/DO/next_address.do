view wave
delete wave *
add wave -r *

radix -hex

# next_pc = pc + 1 = 1
force rt X"0"
force rs X"0"
force pc X"0"
force target_address X"0"
force branch_type X"0"
force pc_sel X"0"
run 2

# testing beq
force pc X"1"
force target_address X"04"
force branch_type X"1"
# Expecting to add 4 to the pc, next_address = 6 
# next_pc = pc + + 1 + 0x04 = 6
run 2

force pc X"6"
# Expecting to subtract 2 from the PC
# next_pc = pc + 1 + (-2) = 0x06 + 1 - 2 = 0x05
force target_address X"fffe"
run 2

# testing bne 
force branch_type X"2"
force rs X"1"
force pc X"4"

# next_pc = pc + 1 + (-2) = 0x05 + 1 - 2 = 0x04
run 2

# testing bltz
force pc X"3"
force branch_type X"3"
force rs X"ffffffff"
run 2
# next_pc = pc + 1 + (-2) = 0x04 + 1  - 2 = 0x03

# testing jump
force pc_sel X"1"
# expecting next_pc = target_address = 0x0000fffe
run 2

# testing jump register
force pc_sel X"2"
force rs X"DEADBEEF"
# expecting next_pc = rs = 0xDEADBEEF
run 2

