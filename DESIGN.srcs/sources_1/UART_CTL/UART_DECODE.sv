//////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Kikyoko
// https://github.com/Kikyoko
// 
// Module   : UART_DECODE
// Device   : Xilinx/Altera
// Author   : Kikyoko
// Contact  : Kikyoko@outlook.com
// Date     : 2021/9/15 18:07:10
// Revision : 1.00 - Simulation correct
//
// Description  : user uart command decode
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

module UART_DECODE (
    //global clock & reset
    input               clk                 ,
    input               rst                 ,
    
    //UART interface, UART tx to PC
    input               UART_tx_ready       ,
    output  [  7:0]     UART_tx_data        ,
    output              UART_tx_valid       ,
    input   [  7:0]     UART_rx_data        ,
    input               UART_rx_valid       ,
    
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

//command code: command address data, address & data is Hex
localparam  LP_REG_WRITE    = 64'h7265675F77720000  ,   //reg_wr
            LP_REG_READ     = 64'h7265675F72640000  ,   //reg_rd
            LP_LOAD_ROM     = 64'h6C6F61645F726F6D  ,   //load_rom
            LP_DONE         = 64'h646F6E6500000000  ;   //done, Current operation done
            
localparam  LP_SPACE        = 8'h20;  

//command type
localparam  LP_TYPE_CMD         = 2'b01 ,
            LP_TYPE_LOAD_ROM    = 2'b10 ;  

`include "DEFINE_FUNC.vh"
localparam  LP_100US_LEN    = `_FRAC_SYS_CLK*1000*1000/100 - 1;
localparam  LP_CNT_WIDTH    = FUNC_N2W(LP_100US_LEN);

// =========================================================================================================================================
// Signal
// =========================================================================================================================================
//input FF
logic   [  7:0]     r_uart_rx_data  ;
logic               r_uart_rx_valid ;
logic               r_rx_space      ;

//command type control
logic   [  1:0]     r_cmd_type      ;

//command/address/data flag generate, r_rx_flag[2:0]:{data,addr,cmd}
logic   [  2:0]     r_rx_flag       ;

//get pc download command
logic   [  7:0]     r_cmd_flag      ;
logic   [ 63:0]     r_cmd_tmp       ;

//get pc download address/data
logic   [  7:0]     r_address       ;
logic   [ 31:0]     r_data          ;
logic   [  3:0]     s_hex_data      ;

//command decode
logic               r_cmd_reg_wr    ;
logic               r_cmd_reg_rd    ;
logic               r_cmd_load_rom  ;
logic               r_cmd_done      ;

//time counter generate
logic   [LP_CNT_WIDTH-1:0]  r_time_cnt      ;
logic                       r_time_en       ;
logic                       r_time_out      ;

//reg bus control
logic   [  7:0]     r_reg_addr      ;
logic   [ 31:0]     r_reg_wdata     ;
logic               r_reg_we        ;
logic               r_reg_re        ;
logic   [ 31:0]     r_reg_rdata     ;
logic   [  3:0]     r_reg_rvalid    ;

//rom write control
logic   [  7:0]     r_rom_data      ;
logic               r_rom_we        ;
logic   [ 15:0]     r_rom_waddr     ;

// =========================================================================================================================================
// output generate
// =========================================================================================================================================
assign UART_tx_data     = r_reg_rdata[31:24];
assign UART_tx_valid    = |r_reg_rvalid;

assign reg_addr     = r_reg_addr    ; 
assign reg_wdata    = r_reg_wdata   ;
assign reg_we       = r_reg_we      ;
assign reg_re       = r_reg_re      ;

assign o_rom_wdata  = r_rom_data    ;
assign o_rom_waddr  = r_rom_waddr   ;
assign o_rom_we     = r_rom_we      ;

// =========================================================================================================================================
// Logic
// =========================================================================================================================================
//input FF
always @ (posedge clk) begin
    r_uart_rx_data  <= UART_rx_data;
    r_uart_rx_valid <= UART_rx_valid;
    r_rx_space      <= UART_rx_valid & (UART_rx_data == LP_SPACE);
end

//command type control
always @ (posedge clk) begin
    if (rst) begin
        r_cmd_type  <= LP_TYPE_CMD;
    end else begin
        if (r_cmd_done) begin
            r_cmd_type  <= LP_TYPE_CMD;
        end else begin
            case (r_cmd_type)
                LP_TYPE_CMD     : begin
                    if (r_time_out & r_cmd_load_rom) begin
                        r_cmd_type  <= LP_TYPE_LOAD_ROM;
                    end
                end
                default         : ;
            endcase
        end
    end
end

//command/address/data flag generate, r_rx_flag[2:0]:{data,addr,cmd}
always @ (posedge clk) begin
    if (rst) begin
        r_rx_flag   <= 3'd1;
    end else begin
        if (r_cmd_type == LP_TYPE_CMD) begin
            if (r_time_out) begin
                r_rx_flag   <= 3'd1;
            end else if (r_rx_space) begin
                r_rx_flag   <= (r_rx_flag << 1);
            end
        end else begin
            r_rx_flag   <= 3'd1;
        end
    end
end

//get pc download command
always @ (posedge clk) begin
    if (rst) begin
        r_cmd_flag  <= 8'b1000_0000;
        r_cmd_tmp   <= 64'd0;
    end else begin
        if (r_rx_flag[0] & r_uart_rx_valid & ~r_rx_space) begin
            r_cmd_flag  <= (r_cmd_flag >> 1);
        end else if (r_time_out) begin
            r_cmd_flag  <= 8'b1000_0000;
        end
        
        if (r_time_out) begin
            r_cmd_tmp   <= 64'd0;
        end else if (r_rx_flag[0] & r_uart_rx_valid & ~r_rx_space) begin
            if (r_cmd_flag[7]) r_cmd_tmp[63:56] <= r_uart_rx_data;
            if (r_cmd_flag[6]) r_cmd_tmp[55:48] <= r_uart_rx_data;
            if (r_cmd_flag[5]) r_cmd_tmp[47:40] <= r_uart_rx_data;
            if (r_cmd_flag[4]) r_cmd_tmp[39:32] <= r_uart_rx_data;
            if (r_cmd_flag[3]) r_cmd_tmp[31:24] <= r_uart_rx_data;
            if (r_cmd_flag[2]) r_cmd_tmp[23:16] <= r_uart_rx_data;
            if (r_cmd_flag[1]) r_cmd_tmp[15:08] <= r_uart_rx_data;
            if (r_cmd_flag[0]) r_cmd_tmp[07:00] <= r_uart_rx_data;
        end
    end
end

//get pc download address/data
always @ (posedge clk) begin
    if (rst) begin
        r_address   <= 8'd0;
        r_data      <= 32'd0;
    end else begin
        if (r_time_out) begin
            r_address   <= 8'd0;
            r_data      <= 32'd0;
        end else begin
            if (r_rx_flag[1] & r_uart_rx_valid & ~r_rx_space) begin
                r_address   <= {r_address[3:0],s_hex_data};
            end
            if (r_rx_flag[2] & r_uart_rx_valid & ~r_rx_space) begin
                r_data      <= {r_data[27:0],s_hex_data};
            end
        end
    end
end

ASCII_TO_HEX u_ASCII_TO_HEX (
    .i_ascii_num    ( r_uart_rx_data    ),
    .o_hex_num      ( s_hex_data        )  
);

//command decode
always @ (posedge clk) begin
    //reg write
    if (r_cmd_tmp == LP_REG_WRITE) begin
        r_cmd_reg_wr    <= 1'b1;
    end else begin
        r_cmd_reg_wr    <= 1'b0;
    end
    
    //reg read
    if (r_cmd_tmp == LP_REG_READ) begin
        r_cmd_reg_rd    <= 1'b1;
    end else begin
        r_cmd_reg_rd    <= 1'b0;
    end
    
    //Flash operation
    if (r_cmd_tmp == LP_LOAD_ROM) begin
        r_cmd_load_rom  <= 1'b1;
    end else begin
        r_cmd_load_rom  <= 1'b0;
    end
    
    //operation done
    if (r_cmd_tmp == LP_DONE) begin
        r_cmd_done  <= 1'b1;
    end else begin
        r_cmd_done  <= 1'b0;
    end
end

//time counter generate
always @ (posedge clk) begin
    if (rst) begin
        r_time_cnt  <= LP_100US_LEN;
        r_time_en   <= 1'b0;
        r_time_out  <= 1'b0;
    end else begin
        if (UART_rx_valid | r_time_out) begin
            r_time_cnt  <= LP_100US_LEN;
        end else if (r_time_en) begin
            r_time_cnt  <= r_time_cnt - 1'b1;
        end
        if (UART_rx_valid) begin
            r_time_en   <= 1'b1;
        end else if (r_time_out) begin
            r_time_en   <= 1'b0;
        end
        r_time_out  <= ~|r_time_cnt;
    end
end

//reg bus control
always @ (posedge clk) begin
    r_reg_addr  <= r_address    ;
    r_reg_wdata <= r_data       ;
    r_reg_we    <= r_time_out & r_cmd_reg_wr;
    r_reg_re    <= r_time_out & r_cmd_reg_rd;
end

always @ (posedge clk) begin
    if (reg_rvalid) begin
        r_reg_rdata     <= reg_rdata;
        r_reg_rvalid    <= 4'b0001;
    end else if (UART_tx_ready & UART_tx_valid) begin
        r_reg_rdata     <= (r_reg_rdata << 8);
        r_reg_rvalid    <= (r_reg_rvalid << 1);
    end
end

//rom write control
always @ (posedge clk) begin
    if (rst) begin
        r_rom_data  <= 8'd0;
        r_rom_we    <= 1'b0;
        r_rom_waddr <= 16'd0;
    end else begin
        if (r_cmd_type == LP_TYPE_LOAD_ROM) begin
            r_rom_data  <= r_uart_rx_data;
            r_rom_we    <= r_uart_rx_valid;
        end else begin
            r_rom_data  <= 'd0;
            r_rom_we    <= 'd0;
        end
        
        if (r_time_out & r_cmd_load_rom) begin
            r_rom_waddr <= 'd0;
        end else if (r_rom_we) begin
            r_rom_waddr <= r_rom_waddr + 1'b1;
        end
    end
end


endmodule

