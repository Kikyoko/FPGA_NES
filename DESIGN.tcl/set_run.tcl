
# add verilog header file
add_files -quiet ./DESIGN.srcs/sources_1/DEFINE_FUNC.vh
add_files -quiet ./DESIGN.srcs/sources_1/FPGA_DEFINE.vh

# add top file
add_files -quiet ./DESIGN.srcs/sources_1/FPGA_NES_TOP.sv

# add RTL file
add_files -quiet ./DESIGN.srcs/sources_1/CLK_RST/CLK_RST.sv
add_files -quiet ./DESIGN.srcs/sources_1/SYS_REG/SYS_REG.sv
add_files -quiet ./DESIGN.srcs/sources_1/UART_CTL/UART_CTL.sv
add_files -quiet ./DESIGN.srcs/sources_1/UART_CTL/UART_DECODE.sv
add_files -quiet ./DESIGN.srcs/sources_1/USER_IP/Function/ASCII_TO_HEX/ASCII_TO_HEX.sv
add_files -quiet ./DESIGN.srcs/sources_1/USER_IP/Interface/UART/UART_IF.sv
add_files -quiet ./DESIGN.srcs/sources_1/USER_IP/Interface/UART/UART_RX.sv
add_files -quiet ./DESIGN.srcs/sources_1/USER_IP/Interface/UART/UART_TX.sv

# add bd file

# add IP file
add_files -quiet ./DESIGN.srcs/sources_1/ip/MMCM_SYS_CLK/MMCM_SYS_CLK.xci
add_files -quiet ./DESIGN.srcs/sources_1/ip/ASYNC_BRAM_8x65536_8x65536/ASYNC_BRAM_8x65536_8x65536.xci
add_files -quiet ./DESIGN.srcs/sources_1/ip/SYNC_DRAM_6x32_6x32/SYNC_DRAM_6x32_6x32.xci

# add constrs
add_files -fileset constrs_1 -norecurse ./DESIGN.srcs/constrs_1/pin.xdc
add_files -fileset constrs_1 -norecurse ./DESIGN.srcs/constrs_1/timing.xdc

# Update to set top and file compile order
set_property top FPGA_NES_TOP [current_fileset]
update_compile_order -fileset sources_1

# set_property strategy Flow_AreaOptimized_high [get_runs synth_1]
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# set_property strategy Performance_Explore [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

file copy -force ./DESIGN.runs/impl_1/FPGA_NES_TOP.bit  ./FPGA_NES_TOP.bit

exit
