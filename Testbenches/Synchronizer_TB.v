`timescale 1ns / 1ps

module Synchronizer_TB();
    
        parameter WIDTH=4;
        reg clk,rst;
        reg [WIDTH-1:0]async_pointer;
        wire [WIDTH-1:0]sync_pointer;
        
        Synchronizer #(.WIDTH(WIDTH))
         uut(
                .clk(clk),
                .rst(rst),
                .async_pointer(async_pointer),
                .sync_pointer(sync_pointer)
                );
                
         initial
            begin
                clk=0; rst=0; async_pointer=0;
            end

          always
            #5 clk=~clk;
            
         initial
            begin
                #100
                #5 rst=1;
                #5 rst=0;
                #10 async_pointer=4'b1101;
                #10 async_pointer=4'b1110;
                #10 async_pointer=4'b1011;
                #10 async_pointer=4'b0111;
                #5 rst=1;
                #5 rst=0;
                #10 async_pointer=4'b1110;
                #10 async_pointer=4'b1101;
                #10 $finish;
            end
    
endmodule
