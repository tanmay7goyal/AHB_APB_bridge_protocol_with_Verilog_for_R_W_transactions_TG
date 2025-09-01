`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2023 04:35:21 PM
// Design Name: 
// Module Name: top_bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_bridge(input hclk,hresetn,hwrite,hready_in,
                  input [31:0] haddr,hwdata,
                  input [1:0] htrans,
                  input [31:0] prdata,
                  output penable, pwrite,hr_readyout,
                  output [2:0] psel,
                  output [31:0] paddr, pwdata, hrdata
//                  output [1:0] hres
    );
 
wire [31:0] hwdata1,hwdata2;
wire [31:0] haddr1,haddr2;
wire hwrite_reg,hwrite_reg1;
wire valid;
wire [2:0] temp_sel;

ahb_slave_interface ahb_s ( hclk,hresetn,hwrite,hready_in,
                            haddr,hwdata,
                            htrans,
                            prdata,
                            
                            hrdata,
                            haddr1,haddr2,
                            hwdata1,hwdata2,
                            hwrite_reg,hwrite_reg1,
                            valid,
                            temp_sel);
apb_controller apb_c( hclk, hresetn, hwrite_reg, hwrite, valid,
                      haddr, haddr1, hwdata, pr_data,
                      temp_sel,
                      penable, pwrite,hr_readyout,
                      psel,
                      paddr, pwdata
                       );
endmodule
