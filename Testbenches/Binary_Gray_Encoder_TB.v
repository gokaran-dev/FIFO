`timescale 1ns / 1ps

module Binary_Gray_Encoder_TB();
    parameter WIDTH=4;
    reg [WIDTH-1:0]bin;
    wire [WIDTH-1:0]gray;
    
    Binary_Gray_Encoder #(.WIDTH(WIDTH))
      uut(
        .bin(bin),
        .gray(gray)
        );
        
        initial
        #5 bin=4'b0; //delay
        
        initial 
            begin
               #5 bin=4'b1001;
               #5 bin=4'b1101;
               #5 bin=4'b1011;
               #5 bin=4'b1010;
               #5 bin=4'b1110;
               #10 $finish;
            end
   
endmodule
