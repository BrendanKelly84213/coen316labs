add wave -r *
radix -hexadecimal
force clk 0,1 5 ns -r 10 ns

force reset '0'
force write '1'
force write_address X"0"
force din X"AAAA"

run 10 ns

force write_address X"2"
force din X"FAFA3B3B"

run 10 ns

force write '0'

force read_a X"0"
force read_b X"2"

run 10 ns

force reset "1"

run 10 ns

force write '1'
force reset "0"

force write_address X"4"

force din X"DEADBEEF"

run 10 ns

force write '0'

force read_a X"4"
force read_b X"2"

run 10 ns
