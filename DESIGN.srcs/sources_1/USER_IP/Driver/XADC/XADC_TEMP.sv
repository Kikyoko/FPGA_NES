//////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020 Kikyoko
// https://github.com/Kikyoko
// 
// Module   : XADC_TEMP
// Device   : Xilinx
// Author   : Kikyoko
// Contact  : Kikyoko@outlook.com
// Date     : 2021/3/8 16:00:07
// Revision : 1.00 - Simulation correct
//
// Description  : Use XADC get temperature
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

module XADC_TEMP (
    //global clock & reset
    input               xadc_clk            , //200M
    input               xadc_rst            ,
    
    output  [  7:0]     o_temperature       , //{1-signed,7-temp_value}
    output              o_temp_warnning     , //temp>70 warnning, temp<60 warnning cancel         
    output              o_temp_alert          //temp>85 alert, temp<70 alert cancel 
);


// =========================================================================================================================================
// Signal
// =========================================================================================================================================
//temp_data generate
logic   [ 11:0]     r_xadc_data     ;
logic   [  7:0]     r_temp_data     ;
logic               r_temp_warnning ;
logic               r_temp_alert    ;   

//DSP
logic   [ 11:0]     s_temp_data     ;

//XADC instance
logic               s_xadc_busy     ;
logic   [ 15:0]     s_xadc_odata    ;
logic               s_xadc_ovalid   ;
logic               s_temp_alert    ;
logic               s_temp_warnning ;

// =========================================================================================================================================
// output generate
// =========================================================================================================================================
assign o_temperature    = r_temp_data;
assign o_temp_warnning  = r_temp_warnning;

// =========================================================================================================================================
// Logic
// =========================================================================================================================================
//temp_data generate
always @ (posedge xadc_clk) begin
    if (xadc_rst) begin
        r_xadc_data     <= 12'd0;
        r_temp_data     <= 8'd0;
        r_temp_warnning <= 1'b0;
        r_temp_alert    <= 1'b0;
    end else begin
        if (s_xadc_ovalid) begin
            r_xadc_data <= s_xadc_odata[15:4];
        end
        r_temp_data     <= s_temp_data[7:0];
        r_temp_warnning <= s_temp_warnning;
        r_temp_alert    <= s_temp_alert;
    end
end

//DSP: (ADC Code*503.975)/4096-273.15, Equivalent: (ADC Code*504-1118822)>>12
DSP_13x10sub22_out12_m23l12 u_DSP (
    .CLK    ( xadc_clk              ), 
    .A      ( {1'b0,r_xadc_data}    ), 
    .B      ( 10'd504               ), 
    .C      ( 25'd1118822           ), 
    .P      ( s_temp_data           )
);

//XADC intance
XADC_IP u_XADC_IP (
    .daddr_in               ( 7'd0              ), // Address bus for the dynamic reconfiguration port
    .dclk_in                ( xadc_clk          ), // Clock input for the dynamic reconfiguration port
    .den_in                 ( ~s_xadc_busy      ), // Enable Signal for the dynamic reconfiguration port
    .di_in                  ( 16'd0             ), // Input data bus for the dynamic reconfiguration port
    .dwe_in                 ( 1'b0              ), // Write Enable for the dynamic reconfiguration port
    .reset_in               ( xadc_rst          ), // Reset signal for the System Monitor control logic
    .busy_out               ( s_xadc_busy       ), // ADC Busy signal
    .channel_out            (                   ), // Channel Selection Outputs
    .do_out                 ( s_xadc_odata      ), // Output data bus for dynamic reconfiguration port
    .drdy_out               ( s_xadc_ovalid     ), // Data ready signal for the dynamic reconfiguration port
    .eoc_out                (                   ), // End of Conversion Signal
    .eos_out                (                   ), // End of Sequence Signal
    .ot_out                 ( s_temp_alert      ), // Over-Temperature alarm output
    .user_temp_alarm_out    ( s_temp_warnning   ), // Temperature-sensor alarm output
    .alarm_out              (                   ), // OR'ed output of all the Alarms    
    .vp_in                  ( 1'b0              ), // Dedicated Analog Input Pair
    .vn_in                  ( 1'b0              )
);

endmodule