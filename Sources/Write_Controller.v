`timescale 1ns / 1ps

module Write_Controller #(
    parameter POINTER_WIDTH=4
    )(
    input clk_wr,
    input rst,
    input write_en,
    input [POINTER_WIDTH:0]rqs_read_ptr,  //gray coded read pointer, CDC signal
    output [POINTER_WIDTH:0]write_ptr,    //gray coded write pointer, CDC signal meant to be sent
    output fifo_full,
    output reg[POINTER_WIDTH-1:0]write_addr   //Binary address to FIFO memory  
    );

    reg [POINTER_WIDTH:0]write_bin;
    wire [POINTER_WIDTH:0]read_bin;

    // Decode read pointer received from read domain
    Binary_Gray_Decoder #(.WIDTH(POINTER_WIDTH)) 
      decoder_Comp(
        .gray(rqs_read_ptr),
        .bin(read_bin)
      );

    /*computing fifo_full logic using wrap around condition. We are comparing if the location we are writing at next,
    is equal to the location we are reading from. In that case, fifo_empty can also be true. This is where the 5th bit(MSB) becomes useful.
    if MSB is 1, we can be sure FIFO has been written once, in that case, fifo will be full, and not empty*/
    
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
            //making sure we use the previous address first, before incrementing. Fixes Timing issues.
            write_addr<=write_bin[POINTER_WIDTH-1:0]; 
            if(write_en && !fifo_full) 
              begin
                write_bin<=write_bin+1; //after writing, we move to next location
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
