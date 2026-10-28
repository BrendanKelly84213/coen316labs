# regfile.do - 32x32 register file directed test
# Assumes simulation is already loaded (vsim work.regfile or testbench).

# Helper: check a signal value and stop on first failure.
proc check_eq {sig expected label} {
    set actual [string toupper [examine -radix hexadecimal $sig]]
    set exp [string toupper $expected]
    if {$actual ne $exp} {
        echo "FAIL: $label -- $sig expected $exp, got $actual"
        stop
    } else {
        echo "PASS: $label"
    }
}

# Waveform setup
add wave -divider {Inputs}
add wave clk reset write write_address din read_a read_b
add wave -divider {Outputs}
add wave out_a out_b
radix -hexadecimal

# Free-running 10 ns clock
force clk 0 0 ns, 1 5 ns -r 10 ns

# Initialize DUT inputs and assert reset
force reset '1'
force write '0'
force write_address "00000"
force read_a "00000"
force read_b "00000"
force din X"00000000"
run 12 ns

# Release reset and allow async outputs to settle
force reset '0'
run 2 ns
check_eq out_a 00000000 "Reset clears read port A"
check_eq out_b 00000000 "Reset clears read port B"

# 1) Write-enable check: write=0 should not modify addressed register
force write '0'
force write_address "00011"
force din X"DEADBEEF"
run 10 ns
force read_a "00011"
run 2 ns
check_eq out_a 00000000 "Write disabled leaves register unchanged"

# 2) Write/read register 3
force write '1'
force write_address "00011"
force din X"DEADBEEF"
run 10 ns
force write '0'
force read_a "00011"
run 2 ns
check_eq out_a DEADBEEF "Write to register 3"

# 3) Write/read register 21 and verify independent dual-port reads
force write '1'
force write_address "10101"
force din X"12345678"
run 10 ns
force write '0'
force read_a "00011"
force read_b "10101"
run 2 ns
check_eq out_a DEADBEEF "Read port A keeps register 3"
check_eq out_b 12345678 "Read port B reads register 21"

# 4) Overwrite register 3, confirm register 21 unchanged
force write '1'
force write_address "00011"
force din X"0F0F0F0F"
run 10 ns
force write '0'
force read_a "00011"
force read_b "10101"
run 2 ns
check_eq out_a 0F0F0F0F "Overwrite register 3"
check_eq out_b 12345678 "Register 21 unchanged after write to register 3"

# 5) Address boundary test: write/read register 31
force write '1'
force write_address "11111"
force din X"FFFFFFFF"
run 10 ns
force write '0'
force read_a "11111"
force read_b "00000"
run 2 ns
check_eq out_a FFFFFFFF "Write/read register 31"
check_eq out_b 00000000 "Register 0 still zero"

# 6) Async read behavior: changing read addresses updates outputs without a clock edge
force read_a "10101"
force read_b "00011"
run 2 ns
check_eq out_a 12345678 "Async read A updates after address change"
check_eq out_b 0F0F0F0F "Async read B updates after address change"

# 7) Reset clears previously written registers
force reset '1'
run 10 ns
force reset '0'
force read_a "00011"
force read_b "11111"
run 2 ns
check_eq out_a 00000000 "Reset clears register 3"
check_eq out_b 00000000 "Reset clears register 31"

echo "PASS: regfile directed test complete"
stop
