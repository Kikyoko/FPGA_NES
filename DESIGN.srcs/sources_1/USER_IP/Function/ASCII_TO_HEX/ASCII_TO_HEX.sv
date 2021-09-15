//////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020 Kikyoko
// https://github.com/Kikyoko
// 
// Module   : ASCII_TO_HEX
// Device   : Xilinx/Altera
// Author   : Kikyoko
// Contact  : Kikyoko@outlook.com
// Date     : 2020/9/1 13:54:01
// Revision : 1.00 - Simulation correct
//
// Description  : ASCII code number to Hex number
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

module ASCII_TO_HEX (
    input   [  7:0]     i_ascii_num     ,
    output  [  3:0]     o_hex_num        
);

// =========================================================================================================================================
// Signal
// =========================================================================================================================================
logic   [  3:0]     s_hex_num;

// =========================================================================================================================================
// output generate
// =========================================================================================================================================
assign o_hex_num = s_hex_num;

// =========================================================================================================================================
// Logic
// =========================================================================================================================================
always @ * begin
    case (i_ascii_num)
        8'h30       : s_hex_num = 4'h0;
        8'h31       : s_hex_num = 4'h1;
        8'h32       : s_hex_num = 4'h2;
        8'h33       : s_hex_num = 4'h3;
        8'h34       : s_hex_num = 4'h4;
        8'h35       : s_hex_num = 4'h5;
        8'h36       : s_hex_num = 4'h6;
        8'h37       : s_hex_num = 4'h7;
        8'h38       : s_hex_num = 4'h8;
        8'h39       : s_hex_num = 4'h9;
        8'h41,8'h61 : s_hex_num = 4'hA;
        8'h42,8'h62 : s_hex_num = 4'hB;
        8'h43,8'h63 : s_hex_num = 4'hC;
        8'h44,8'h64 : s_hex_num = 4'hD;
        8'h45,8'h65 : s_hex_num = 4'hE;
        8'h46,8'h66 : s_hex_num = 4'hF;
        default     : s_hex_num = 4'h0;
    endcase
end

endmodule