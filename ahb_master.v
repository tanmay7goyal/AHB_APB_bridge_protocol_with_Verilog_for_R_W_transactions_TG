`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2023 11:13:47 AM
// Design Name: 
// Module Name: ahb_master
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


module ahb_master(  input hclk,hresetn,
                    input [31:0] hrdata,
                    output reg hwrite,
                    output reg hready_in,
                    output reg [1:0] htrans,
                    output reg [31:0] hwdata,
                    output reg [31:0] haddr
                    );
                    
reg [2:0] hburst;    //single,incr4,8,16,wrap4,8,16
reg [2:0] hsize;     //size 8,16 bit......
integer i;
task single_write();
begin
    @(posedge hclk)
        begin
        #1;
        hwrite=1;
        htrans=2'b10;
        haddr=32'h8000_0200;
        hready_in=1;
        hburst=0;
        hsize=0;
        end
  
    @(posedge hclk)
    #1;
        begin
        hwdata=32'h24;
//        hwrite=1'b0;
        htrans=2'd0;    
        end
end
endtask                    
 

task single_read();
begin
    @(posedge hclk)
//    #1;
        begin
        hwrite=0;
        htrans=2'd2;
        hburst=0;
        hsize=0;
        hready_in=1;
        haddr=32'h8000_0100;        
        end
    @(posedge hclk)
//    #1;
        begin
        htrans=2'd0;       
        end    
end
endtask                    
 

task burst_4_incr_write();
begin
    @(posedge hclk)
    #1;
        begin
        hwrite=1;
        htrans=2'd2;
        hsize=0;
        hburst=0;
        hready_in=1'b1;
        haddr=32'h8000_0020;    
        end
    @(posedge hclk)
    #1;
        begin
        haddr=haddr+1;
        hwdata=32'h4940_0000;
        htrans=2'd3;
       end
    for(i=0;i<2;i=i+1)
        begin
            @(posedge hclk)
            #1;
            begin
            haddr=haddr+1;
            hwdata={$random}%256;        
            htrans=2'd3;
            end
        
            @(posedge hclk);
        end
    @(posedge hclk)
    #1;
    begin
    hwdata={$random}%256;
    htrans=2'd0;  
    end              
end 
endtask                   
                    
endmodule
