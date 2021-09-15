//////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Kikyoko
// https://github.com/Kikyoko
//
// Module   : FPGA_NES_TOP
// Device   : Xilinx
// Author   : Kikyoko
// Contact  : Kikyoko@outlook.com
// Date     : 2021/9/15 16:52:23
// Revision : 1.00 - Simulation correct
//
// Description  : FPGA_NES top
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//////////////////////////////////////////////////////////////////////////////////////////

`include "FPGA_DEFINE.vh"

module FPGA_NES_TOP (
    //Hardware clock & reset
    input               hard_clk        , //50M
    input               hard_rst_n      ,
    
    //uart interface
    output              uart_txd        ,
    input               uart_rxd        ,
    
    //Led interface
    output  [  3:0]     o_led_n         ,
    
    //Key interface
    input   [  3:0]     i_key_n
);

// =========================================================================================================================================
// Signal
// =========================================================================================================================================
//clock & reset generate
logic               sys_clk             ;
logic               sys_rst             ;

//reg interface
logic   [  7:0]     reg_addr            ;
logic   [ 31:0]     reg_wdata           ;
logic               reg_we              ;
logic               reg_re              ;
logic   [ 31:0]     reg_rdata           ;
logic               reg_rvalid          ;

//ROM instance
logic               s_rom_we            ;
logic   [ 15:0]     s_rom_waddr         ;
logic   [  7:0]     s_rom_wdata         ;
logic               s_rom_re            ;
logic   [ 15:0]     s_rom_raddr         ;
logic   [  7:0]     s_rom_rdata         ;
                       
// =========================================================================================================================================
// Logic
// =========================================================================================================================================
//clock & reset generate
CLK_RST (
    //Hardware clock & reset
    .hard_clk       ( hard_clk      ),
    .hard_rst_n     ( hard_rst_n    ),
    
    //clock & reset output
    .sys_clk        ( sys_clk       ),
    .sys_rst        ( sys_rst       )
);

//UART control
UART_CTL u_UART_CTL (
    //global clock & reset
    .clk                ( sys_clk           ),
    .rst                ( sys_rst           ),
    
    //UART ports
    .uart_txd           ( uart_txd          ),
    .uart_rxd           ( uart_rxd          ),
    
    //REG bus
    .reg_addr           ( reg_addr          ),
    .reg_wdata          ( reg_wdata         ),
    .reg_we             ( reg_we            ),
    .reg_re             ( reg_re            ),
    .reg_rdata          ( reg_rdata         ),
    .reg_rvalid         ( reg_rvalid        ),
    
    //rom interface
    .o_rom_wdata        ( s_rom_wdata       ),
    .o_rom_waddr        ( s_rom_waddr       ),
    .o_rom_we           ( s_rom_we          )
);
              
//System register instance
SYS_REG (
    //global clock & reset
    .sys_clk            ( sys_clk           ),
    .sys_rst            ( sys_rst           ),
    
    //REG bus
    .reg_addr           ( reg_addr          ),
    .reg_wdata          ( reg_wdata         ),
    .reg_we             ( reg_we            ),
    .reg_re             ( reg_re            ),
    .reg_rdata          ( reg_rdata         ),
    .reg_rvalid         ( reg_rvalid        )
);

//ROM instance
ASYNC_BRAM_8x65536_8x65536 u_ROM (
    .clka       ( sys_clk           ),
    .ena        ( s_rom_we          ),
    .wea        ( 1'b1              ),
    .addra      ( s_rom_waddr       ),
    .dina       ( s_rom_wdata       ),

    .clkb       ( nes_clk           ),
    .enb        ( s_rom_re          ),
    .addrb      ( s_rom_raddr       ),
    .doutb      ( s_rom_rdata       )
);

endmodule
