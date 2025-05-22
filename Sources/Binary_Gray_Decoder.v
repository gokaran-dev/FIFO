`timescale 1ns / 1ps

module Binary_Gray_Decoder #(parameter WIDTH=4)
        (
        input [WIDTH:0]gray,
        output [WIDTH:0]bin
    );
    
        assign bin[WIDTH]=gray[WIDTH];
        
        genvar i;
        generate
            for(i=WIDTH-1;i>=0;i=i-1)
                begin
                    assign bin[i]=bin[i+1]^gray[i];
                end
        endgenerate
endmodule
