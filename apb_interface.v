`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2023 12:17:31 PM
// Design Name: 
// Module Name: apb_interface
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


module apb_interface(   input pwrite,penable,
                        input [2:0] psel,
                        input [31:0] paddr,
                        input [31:0] pwdata,
                        output pwrite_out,
                        output penable_out,
                        output [2:0] psel_out,
                        output [31:0] paddr_out,
                        output [31:0] pwdata_out,
                        output reg [31:0] prdata
                        );
                        
assign pwrite_out=pwrite;
assign paddr_out=paddr;
assign psel_out=psel;
assign pwdata_out=pwdata;
assign penable_out=penable; 

always@(*)
begin
    if(!pwrite && penable)
        prdata=8'd25;
end                       
endmodule
