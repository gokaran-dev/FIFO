`timescale 1ns / 1ps

module Read_Controller #(
    parameter POINTER_WIDTH=4
    )(
    input  clk_rd,
    input  rst,
    input  read_en,
    input  [POINTER_WIDTH:0] rqs_write_ptr,  // Gray-coded write pointer (from write domain)
    output [POINTER_WIDTH:0] read_ptr,    // Gray-coded pointer (to send to write domain)
    output [POINTER_WIDTH-1:0] read_addr,            // Binary address for memory access
    output reg fifo_empty
    );

    reg [POINTER_WIDTH:0]read_bin;
    reg [POINTER_WIDTH:0] read_bin_next;
    
    // Instantiate Binary to Gray Encoder
    Binary_Gray_Encoder #(.WIDTH(POINTER_WIDTH)) 
      encoder_read(
        .bin(read_bin),
        .gray(read_ptr)
      );
 
    assign read_addr=read_bin[POINTER_WIDTH-1:0];
   
    always @(posedge clk_rd or posedge rst) 
      begin
        if (rst) 
          begin
            read_bin<=0;
            fifo_empty<=1;
          end 
        
        else 
          begin
            if (read_en && !fifo_empty) 
              begin
                read_bin<=read_bin+1;
              end
            
           fifo_empty<=(rqs_write_ptr==read_ptr);
        end
      end
        
      
endmodule
