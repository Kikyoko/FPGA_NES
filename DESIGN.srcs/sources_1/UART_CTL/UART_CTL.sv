//////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Kikyoko
// https://github.com/Kikyoko
// 
// Module   : UART_CTL
// Device   : Xilinx/Altera
// Author   : Kikyoko
// Contact  : Kikyoko@outlook.com
// Date     : 2021/9/15 18:07:17
// Revision : 1.00 - Simulation correct
//
// Description  : user uart control
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

module UART_CTL (
    //global clock & reset
    input               clk                 ,
    input               rst                 ,
    
    //UART ports
    output              uart_txd            ,
    input               uart_rxd            ,
    
    //REG bus
    output  [  7:0]     reg_addr            ,
    output  [ 31:0]     reg_wdata           ,
    output              reg_we              ,
    output              reg_re              ,
    input   [ 31:0]     reg_rdata           ,
    input               reg_rvalid          ,
    
    //load rom interface
    output  [  7:0]     o_rom_wdata         ,
    output  [ 15:0]     o_rom_waddr         ,
    output              o_rom_we 
);

// =========================================================================================================================================
// Signal
// =========================================================================================================================================
logic               UART_tx_ready       ;
logic   [  7:0]     UART_tx_data        ;
logic               UART_tx_valid       ;
logic   [  7:0]     UART_rx_data        ;
logic               UART_rx_valid       ;

// =========================================================================================================================================
// output generate
// =========================================================================================================================================

// =========================================================================================================================================
// Logic
// =========================================================================================================================================
UART_IF # (
    .CLK_FRAC           ( `_FRAC_SYS_CLK), //unit: MHz
    .BAUD               ( `_UART_BAUD   ),
    .DATA_WIDTH         ( 8             ),
    .CHECK_BIT          ( "none"        ), //"even", "odd", "mask", "space", "none"
    .END_WIDTH          ( 1             )  //end bit width
) u_UART_IF (
    //global clock & reset
    .clk                ( clk           ),
    .rst                ( rst           ),
    
    //user data interface
    .o_user_tx_ready    ( UART_tx_ready ),
    .i_user_tx_data     ( UART_tx_data  ),
    .i_user_tx_valid    ( UART_tx_valid ),
    .o_user_rx_data     ( UART_rx_data  ),
    .o_user_rx_valid    ( UART_rx_valid ),
    .o_user_rx_err      (               ),
    
    //UART interface
    .uart_txd           ( uart_txd      ),
    .uart_rxd           ( uart_rxd      )
);

UART_DECODE u_UART_DECODE (
    //global clock & reset
    .clk                ( clk               ),
    .rst                ( rst               ),
    
    //UART interface, UART tx to PC
    .UART_tx_ready      ( UART_tx_ready     ),
    .UART_tx_data       ( UART_tx_data      ),
    .UART_tx_valid      ( UART_tx_valid     ),
    .UART_rx_data       ( UART_rx_data      ),
    .UART_rx_valid      ( UART_rx_valid     ),
    
    //REG bus
    .reg_addr           ( reg_addr          ),
    .reg_wdata          ( reg_wdata         ),
    .reg_we             ( reg_we            ),
    .reg_re             ( reg_re            ),
    .reg_rdata          ( reg_rdata         ),
    .reg_rvalid         ( reg_rvalid        ),
    
    //load rom interface
    .o_rom_wdata        ( o_rom_wdata       ),
    .o_rom_waddr        ( o_rom_waddr       ),
    .o_rom_we           ( o_rom_we          )
);

endmodule

