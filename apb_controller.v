`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2023 04:45:29 PM
// Design Name: 
// Module Name: apb_controller
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


module apb_controller( input hclk, hresetn, hwrite_reg, hwrite, valid,
                       input [31:0] haddr, haddr1, hwdata, pr_data,
                       input [2:0] temp_sel,
                       output reg penable, pwrite,hr_readyout,
                       output reg [2:0] psel,
                       output reg [31:0] paddr, pwdata
                       );
                       
parameter st_idle=3'b000,
          st_read=3'b001,
          st_renable=3'b010,
          st_wenable=3'b011,
          st_write=3'b100,
          st_wwait=3'b101,
          st_writep=3'b110,
          st_wenablep=3'b111;                       
                       
reg [2:0] present,next;

/////////////////////////////// Defining temperary registers ////////////////////////////////
reg penable_temp, pwrite_temp, hr_readyout_temp;
reg [2:0] psel_temp;
reg [31:0] paddr_temp, pwdata_temp;

///////////////////////////////////////// Present State Logic ///////////////////////////////////////////////////////

always@(posedge hclk)
begin
    if(!hresetn)
        begin
        present<=st_idle;
//        next<=st_idle;
        end
    else
        present<=next;
end

///////////////////////////////////////// Next state Logic ///////////////////////////////////////////////////////

always@(*)
begin
next=st_idle;
    case(present)
        st_idle:begin
                    if(valid==1 && hwrite==1)
                        next=st_wwait;
                    else if (valid==1 && hwrite==0)
                        next=st_read;
                    else
                        next=st_idle;
                 end
        st_read:
                next=st_renable;
        st_renable:begin
                        if(valid==1 && hwrite==0)
                            next=st_read;
                        else if(valid==1 && hwrite==1)
                            next=st_wwait;
                        else if(valid==0)
                            next=st_idle;     
                    end     
        st_wwait:begin
                    if(valid)
                        next=st_writep;
                    else
                        next=st_write;            
                end             
        st_write:begin
                    if(!valid)
                        next=st_wenable;
                    else
                        next=st_wenablep;     
                end
        st_writep:begin
                    next=st_wenablep;       
                end 
        st_wenablep:begin
                        if(hwrite_reg==0)
                            next=st_read;
                        else if(valid==1 && hwrite_reg)
                            next=st_writep;
                        else if(valid==0 && hwrite_reg==1)
                            next=st_write;
                    end
        st_wenable:begin
                        if(valid==1 && hwrite==0)
                            next=st_read;
                        else if(valid==1 && hwrite==1)
                            next=st_wwait;
                        else if(valid==0)
                            next=st_idle;
                    end 
    endcase
end


/////////////////////////////////////////////// Temperary output Logic //////////////////////////////////////////
 
always@(*)
begin
    case(present)
        st_idle:if(valid && !hwrite)
                    begin
                        paddr_temp=haddr;
                        pwrite_temp=hwrite;
                        psel_temp=temp_sel;
                        penable_temp=0;
                        hr_readyout_temp=0;                
                    end
                else if(valid && hwrite)
                        begin
                            psel_temp=0;
                            penable_temp=0;
                            hr_readyout_temp=1;                        
                        end
                else
                    begin
                        psel_temp=0;
                        penable_temp=0;
                        hr_readyout_temp=1;                    
                    end
        st_read:begin
                    psel_temp=temp_sel;
                    penable_temp=1;
                    hr_readyout_temp=1;
                end
        st_renable:if(valid && !hwrite)
                        begin
                            paddr_temp=haddr;
                            pwrite_temp=hwrite;
                            psel_temp=temp_sel;
                            penable_temp=0;
                            hr_readyout_temp=0;                       
                        end        
                    else if( valid && hwrite)
                        begin
                            penable_temp=0;
                            hr_readyout_temp=1;
                            psel_temp=0;                        
                        end
                    else
                        begin
                            psel_temp=0;
                            hr_readyout_temp=1;
                            penable_temp=0;
                        end     
        st_wwait:  begin 
                        paddr_temp=haddr1;  // we havve write haddr1 bcoz we want to sample the prev. address 
                                            // as till this state our data and addr. did not reach to peripheral 
                                            // so we can send one more data. so haddr contains that new data but 
                                            // we want that old data first to be sampled. 
                        pwdata_temp=hwdata;
                        pwrite_temp=hwrite;
                        penable_temp=0;
                        hr_readyout_temp=0;
                        psel_temp=temp_sel;
                    end
        st_write:  begin
                        penable_temp=1;
                        hr_readyout_temp=1;
                    end   
        st_wenable:if(valid && !hwrite)
                        begin
                            hr_readyout_temp=1;
                            psel_temp=0;
                            penable_temp=0;
                        end  
                    else if(valid && hwrite)
                        begin
                            paddr_temp=haddr1;
                            penable_temp=0;
                            pwrite_temp=hwrite;
                            psel_temp=temp_sel;
                            hr_readyout_temp=0;
                        end     
                    else
                        begin
                            hr_readyout_temp=1;
                            penable_temp=0;
                            psel_temp=0;
                        end                
        st_writep:  begin
                        hr_readyout_temp=1;
                        penable_temp=1;
                    end             
        st_wenablep:begin
                        paddr_temp=haddr1;
                        pwdata_temp=hwdata;
                        pwrite_temp=hwrite;
                        psel_temp=temp_sel;
                        penable_temp=0;
                        hr_readyout_temp=0;
                    end            
    endcase
end    
    //////////////////////////// output logic //////////////////////////////////

always@(posedge hclk)    
begin
    if(!hresetn)
        begin
            paddr<=0;
            pwdata<=0;
            penable<=0;
            hr_readyout<=1;
            pwrite<=0;
            psel<=0;
        end
    else
        begin
            paddr<=paddr_temp;
            penable<=penable_temp;
            psel<=psel_temp;
            pwdata<=pwdata_temp;
            hr_readyout<=hr_readyout_temp;
            pwrite<=pwrite_temp;        
        end
end 
endmodule
