`timescale 1ns / 1ps

module Binary_Gray_Encoder #(parameter WIDTH=4)
        (
        input [WIDTH:0]bin,
        output [WIDTH:0]gray
    );
    
        assign gray[WIDTH]=bin[WIDTH];
        
        genvar i;
        generate
            for(i=WIDTH-1;i>=0;i=i-1)
                begin
                    assign gray[i]=bin[i+1]^bin[i];
                end
        endgenerate
endmodule
