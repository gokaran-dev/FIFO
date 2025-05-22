`timescale 1ns / 1ps

module Synchronizer #(parameter WIDTH=4)
  (
    input rst,clk,
    input [WIDTH:0]async_pointer,
    output reg [WIDTH:0]sync_pointer 
    );
        
        reg [WIDTH:0]sync_ff_2;
        
        always @(posedge clk or posedge rst)
            begin
                if(rst)
                    begin
                        sync_pointer<=0;
                        sync_ff_2<=0;
                    end
                    
                 else
                    begin
                        sync_ff_2<=async_pointer;
                        sync_pointer<=sync_ff_2;
                    end
            end
    
endmodule
