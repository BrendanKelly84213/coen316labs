add wave -r *
radix -hexadecimal
force clk 0,1 5 ns -r 10 ns
force reset 1
run 10 ns
force reset 0
run 400 ns
