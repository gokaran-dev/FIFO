`timescale 1ns / 1ps

module Write_Controller #(
    parameter POINTER_WIDTH=4
    )(
    input clk_wr,
    input rst,
    input write_en,
    input [POINTER_WIDTH:0] rqs_read_ptr,  // Gray-coded from read domain
    output [POINTER_WIDTH:0] write_ptr,    // Gray-coded write pointer (to send to read domain)
    output fifo_full,
    output reg [POINTER_WIDTH-1:0] write_addr   // Binary address to memory  
    );

    reg [POINTER_WIDTH:0] write_bin;
    wire [POINTER_WIDTH:0] read_bin;

    // Decode read pointer received from read domain
    Binary_Gray_Decoder #(.WIDTH(POINTER_WIDTH)) 
      decoder_Comp(
        .gray(rqs_read_ptr),
        .bin(read_bin)
      );

    // Full flag logic
    wire [POINTER_WIDTH:0] next_write_bin=write_bin+1;
    assign fifo_full=(next_write_bin[POINTER_WIDTH:0]=={~read_bin[POINTER_WIDTH],read_bin[POINTER_WIDTH-1:0]});

    always @(posedge clk_wr or posedge rst) 
      begin
        if (rst) 
          begin
            write_bin<=0;
            write_addr<=0;
          end 
        
        else 
          begin
            if(write_en && !fifo_full) 
              begin
                write_addr<=write_bin[POINTER_WIDTH-1:0];
                write_bin<=write_bin+1;
              end 
          end
      end
    
    // Gray Encoder for sending to read domain
    Binary_Gray_Encoder #(.WIDTH(POINTER_WIDTH)) 
      encoder_write(
        .bin(write_bin),
        .gray(write_ptr)
      );
    
endmodule
