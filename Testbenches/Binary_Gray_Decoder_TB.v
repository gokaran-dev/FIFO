`timescale 1ns / 1ps

module Binary_Gray_Decoder_TB();
    parameter WIDTH=4;
    reg [WIDTH-1:0]gray;
    wire [WIDTH-1:0]bin;
    
    Binary_Gray_Decoder #(.WIDTH(WIDTH))
      uut(
        .bin(bin),
        .gray(gray)
        );
        
        initial
        #5 gray=4'b0; //delay
        
        initial 
            begin
               #5 gray=4'b1101;
               #5 gray=4'b1011;
               #5 gray=4'b0111;
               #5 gray=4'b1110;
               #10 $finish;
            end
   
endmodule
