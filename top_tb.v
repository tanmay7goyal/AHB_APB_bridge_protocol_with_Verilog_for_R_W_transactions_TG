`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2023 12:22:42 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb();
reg hclk,hresetn;
wire [31:0] hrdata,haddr,hwdata,prdata;
wire hwrite,hready_in;
wire [1:0] htrans;

wire penable,pwrite,hr_readyout;
wire [2:0] psel;
wire [31:0] paddr, pwdata, hrdata;

wire pwrite_out,penable_out;
wire [2:0] psel_out;
wire [31:0] paddr_out,pwdata_out,prdata;

ahb_master AHB(  hclk,hresetn,
             hrdata,
             hwrite,
             hready_in,
             htrans,
             hwdata,
             haddr
             );
             
top_bridge BRIDGE( hclk,hresetn,hwrite,hready_in,
            haddr,hwdata,
            htrans,
            prdata,
            penable, pwrite,hr_readyout,
            psel,
            paddr, pwdata, hrdata
    );             

apb_interface APB(pwrite,penable,
              psel,
              paddr,
              pwdata,
              pwrite_out,
              penable_out,
              psel_out,
              paddr_out,
              pwdata_out,
              prdata
                   );
initial 
begin
hclk=1'b0;                                     
forever #10 hclk=~hclk;
end
 
task reset();
begin
@(negedge hclk);
hresetn=1'b0;
@(negedge hclk);
hresetn=1'b1;
end
endtask         

initial 
begin
reset();
//AHB.single_write();
AHB.single_read();
//AHB.burst_4_incr_write();
end                              
endmodule
