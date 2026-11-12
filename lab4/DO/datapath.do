add wave -r *
radix -hexadecimal
force clk 0,1 5 ns -r 10 ns

# initial values for every input
force reset 1
force pc_sel 2#00
force reg_dst 0
force reg_write 0
force reg_in_src 1
force alu_src 0
force func 2#00
force logic_func 2#00
force add_sub 0
force branch_type 2#00
force data_write 0

run 10 ns

# release reset, pc = 0
force reset 0

# pc = 0 : addi r3, r0, 0
force reg_write 1
force reg_dst 0
force reg_in_src 1
force alu_src 1
force func 2#10
force add_sub 0
run 10 ns

# pc = 1 : addi r1, r0, 0
run 10 ns

# pc = 2 : addi r2, r0, 5
run 10 ns

# loop body (pc = 3 to 6), repeated 4 times
# the 5th pass is done by hand below because the beq is taken
for {set i 0} {$i < 4} {incr i} {

    # pc = 3 : add r1, r1, r2
    force reg_write 1
    force reg_dst 1
    force alu_src 0
    force func 2#10
    force add_sub 0
    force pc_sel 2#00
    run 10 ns

    # pc = 4 : addi r2, r2, -1
    force reg_dst 0
    force alu_src 1
    run 10 ns

    # pc = 5 : beq r2, r3 (not taken)
    force reg_write 0
    force alu_src 0
    force add_sub 1
    force branch_type 2#01
    run 10 ns

    # pc = 6 : jump 3
    force add_sub 0
    force branch_type 2#00
    force pc_sel 2#01
    run 10 ns
}

# last pass: pc = 3 : add r1, r1, r2
force reg_write 1
force reg_dst 1
force alu_src 0
force func 2#10
force add_sub 0
force pc_sel 2#00
run 10 ns

# pc = 4 : addi r2, r2, -1  (r2 becomes 0)
force reg_dst 0
force alu_src 1
run 10 ns

# pc = 5 : beq r2, r3 (taken)
force reg_write 0
force alu_src 0
force add_sub 1
force branch_type 2#01
run 10 ns

# pc = 7 : sw r1, 0(r0)
force branch_type 2#00
force reg_write 0
force alu_src 1
force add_sub 0
force func 2#10
force data_write 1
run 10 ns

# pc = 8 : lw r4, 0(r0)
force data_write 0
force reg_write 1
force reg_dst 0
force reg_in_src 0
force alu_src 1
force func 2#10
force add_sub 0
run 10 ns

# pc = 9 : andi r4, r4, 0x000A
force reg_in_src 1
force alu_src 1
force func 2#11
force logic_func 2#00
run 10 ns

# pc = 10 : ori r4, r4, 0x0001
force logic_func 2#01
run 10 ns

# pc = 11 : xori r4, r4, 0x000B
force logic_func 2#10
run 10 ns

# pc = 12 : xori r4, r4, 0x0000
run 10 ns
