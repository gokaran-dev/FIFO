`timescale 1ns / 1ps

module Read_Controller #(
    parameter POINTER_WIDTH=4
    )(
    input  clk_rd,
    input  rst,
    input  read_en,
    input  [POINTER_WIDTH:0]rqs_write_ptr,  //gray coded write pointer, CDC signal
    output [POINTER_WIDTH:0]read_ptr,    //gray coded write pointer, CDC signal meant to be sent
    output [POINTER_WIDTH-1:0]read_addr,  //Binary address to FIFO memory
    output reg fifo_empty
    );

    reg [POINTER_WIDTH:0]read_bin;
    reg [POINTER_WIDTH:0]read_bin_next;
    reg [POINTER_WIDTH-1:0]read_addr_current;
    
    // Instantiate Binary to Gray Encoder
    Binary_Gray_Encoder #(.WIDTH(POINTER_WIDTH)) 
      encoder_read(
        .bin(read_bin),
        .gray(read_ptr)
      );
   
    always @(posedge clk_rd or posedge rst) 
      begin
        if (rst) 
          begin
            read_bin<=0;
            read_addr_current<=0;
            fifo_empty<=1;
          end 
        
        else 
          begin
            //making sure we use the previous address first, before incrementing. Fixes Timing issues.
            read_addr_current<=read_bin[POINTER_WIDTH-1:0];
            if(read_en && !fifo_empty) 
              begin
                read_bin<=read_bin+1; //after reading, we go to the next location
              end
           /*If the location where data is being written is same as the location where data is being read from,
           then fifo is empty. Note: we are comparing all 5 bits here.*/
           fifo_empty<=(rqs_write_ptr==read_ptr);
        end
      end
        
          assign read_addr=read_addr_current;
      
endmodule
