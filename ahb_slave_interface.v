`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2023 04:42:15 PM
// Design Name: 
// Module Name: ahb_slave_interface
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


module ahb_slave_interface( hclk,hresetn,hwrite,hready_in,
                            haddr,hwdata,
                            htrans,
                            prdata,
                            
                            hrdata,
                            haddr1,haddr2,
                            hwdata1,hwdata2,
                            hwrite_reg,hwrite_reg1,
                            valid,
                            temp_sel);
input hclk,hresetn,hwrite,hready_in;
input [31:0] haddr,hwdata;
input [1:0] htrans;
input [31:0] prdata;
output [31:0] hrdata;
output reg [31:0] hwdata1,hwdata2;
output reg [31:0] haddr1,haddr2;
output reg hwrite_reg,hwrite_reg1;
output reg valid;
output reg [2:0] temp_sel;


/////////////////////////////////////////////// 1. Implementing pipeline logic for haddr,hwdata,hwrite ////////////////////////////////////////////////

/////////////////////////////////////////////// 1.1 For haddr //////////////////////////////////////////////////////////////////////////////////////////

always@(posedge hclk)
    begin
        if(!hresetn)
            begin
                haddr1<=0;
                haddr2<=0; 
            end
        else
            begin
                haddr1<=haddr;
                haddr2<=haddr1;
            end
    end

/////////////////////////////////////////////////////// 1.2 for hwdata ///////////////////////////////////////////////////////////////////////////////

always@(posedge hclk)
    begin
        if(!hresetn)
            begin
                hwrite_reg<=0;
                hwrite_reg1<=0; 
            end
        else
            begin
                hwrite_reg<=hwrite;
                hwrite_reg1<=hwrite_reg;
            end
    end

/////////////////////////////////////////////////////////////// 1.3 for hwrite //////////////////////////////////////////////////////////////////////////

always@(posedge hclk)
    begin
        if(!hresetn)
            begin
                hwdata1<=0;
                hwdata2<=0; 
            end
        else
            begin
                hwdata1<=hwdata;
                hwdata2<=hwdata1;
            end
    end

//////////////////////////////////////////////////////////////////////////// 2 Validating the signal /////////////////////////////////////////////////////////

always@(*)
    begin
    valid=1'b0;
        if( (hready_in==1'b1) && (haddr>=32'h8000_0000 && haddr<=32'h8c00_0000) && (htrans==2'b10 || htrans==2'b11) )
            valid=1'b1;
        else
            valid=1'b0;
    end

///////////////////////////////////////////////////// 3 To generate temp_sel to select peripheral device /////////////////////////////////////////////////////

always@(*)
    begin
        temp_sel=3'b000;
        if (haddr>=32'h8000_0000 && haddr<32'h8400_0000)
            temp_sel=3'b001;
        else if (haddr>=32'h8400_0000 && haddr<32'h8800_0000)
            temp_sel=3'b010;
            
        else if (haddr>=32'h8800_0000 && haddr<32'h8c00_0000)
            temp_sel=3'b100;
    
    end
    
assign hrdata=prdata;

endmodule


