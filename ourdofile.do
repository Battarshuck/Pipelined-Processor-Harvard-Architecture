vsim work.processor
add wave -position end  sim:/processor/clk
add wave -position end  sim:/processor/rst
add wave -position end  sim:/processor/inputPort
add wave -position end  sim:/processor/flagOut
# ** Note: (vsim-12125) Error and warning message counts have been reset to '0' because of 'restart'.
mem load -i {C:/Users/mosmo/Desktop/Uni stuff/senior1/arch/project/Pipelined-Processor-Harvard-Architecture/Instruction_Memory.mem} /processor/fetchStage/instructionCache/ram
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/processor/rst 1 0
force -freeze sim:/processor/inputPort FFFE 0
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/decodeStage/RegisterFile
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/decodeStage/RegisterFile
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/fetchStage/instructionCache
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/fetchStage/instructionCache
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 50 ps  Iteration: 0  Instance: /processor/decodeStage/RegisterFile
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 50 ps  Iteration: 0  Instance: /processor/decodeStage/RegisterFile
force -freeze sim:/processor/rst 0 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
force -freeze sim:/processor/inputPort 0001 0
run
force -freeze sim:/processor/inputPort 000F 0
run
force -freeze sim:/processor/inputPort 00C8 0
run
run
mem load -filltype value -filldata 0000000011111111 -fillradix binary /processor/decodeStage/RegisterFile/ram(4)
run
mem load -filltype value -filldata 0000000000011111 -fillradix binary /processor/decodeStage/RegisterFile/ram(4)
run
mem load -filltype value -filldata 0000000011111100 -fillradix binary /processor/decodeStage/RegisterFile/ram(4)
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run