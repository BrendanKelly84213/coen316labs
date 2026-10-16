add wave -r *
radix -hexadecimal
force clk 0,1 5 ns -r 10 ns
force write '1'
force write_address X"0"
force din X"AAAA"

run 10 ns

force write_address X"2"
force din X"FAFA3B3B"

force write '0'

run 10 ns

force read_a X"0"
force read_b X"2"

run 10 ns

