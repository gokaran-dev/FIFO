//This is the Top Module for Asynchronous FIFO 

`timescale 1ns / 1ps

module Async_FIFO #(
        parameter DATA_WIDTH=8,
        parameter FIFO_DEPTH=16,
        parameter POINTER_WIDTH=$clog2(FIFO_DEPTH)
    )(  
    input clk_rd,clk_wr,rst,
    input write_en,read_en,
    input [DATA_WIDTH-1:0]data_in,
    output fifo_empty,fifo_full,
   // output [POINTER_WIDTH-1:0]rd_add,wr_add, //only for debugging
    output [DATA_WIDTH-1:0]data_out   
    );

    wire [POINTER_WIDTH-1:0] rd_add,wr_add; 
    wire [POINTER_WIDTH:0] rd_ptr_gray,wr_ptr_gray;
    wire [POINTER_WIDTH:0] sync_wr_ptr_gray,sync_rd_ptr_gray;
    
    reg [DATA_WIDTH-1:0] data_reg;
    reg [DATA_WIDTH-1:0] fifo_memory[FIFO_DEPTH-1:0];

    Synchronizer #(.WIDTH(POINTER_WIDTH))
      sync_wr_ptr_rd(
            .rst(rst),
            .clk(clk_rd),
            .async_pointer(wr_ptr_gray),
            .sync_pointer(sync_wr_ptr_gray)  
          );
    
    Read_Controller #(.POINTER_WIDTH(POINTER_WIDTH))
      read_address(
            .clk_rd(clk_rd),
            .rst(rst),
            .read_en(read_en),
            .rqs_write_ptr(sync_wr_ptr_gray),
            .read_ptr(rd_ptr_gray),
            .read_addr(rd_add),
            .fifo_empty(fifo_empty)
          );
    
    Synchronizer #(.WIDTH(POINTER_WIDTH))
      sync_rd_ptr_wr(
            .rst(rst),
            .clk(clk_wr),
            .async_pointer(rd_ptr_gray),
            .sync_pointer(sync_rd_ptr_gray)  
          );
    
    Write_Controller #(.POINTER_WIDTH(POINTER_WIDTH))
      write_address(
            .clk_wr(clk_wr),
            .rst(rst),
            .write_en(write_en),
            .rqs_read_ptr(sync_rd_ptr_gray),
            .write_ptr(wr_ptr_gray),
            .write_addr(wr_add),
            .fifo_full(fifo_full)
          );
    
    //fetching data from the memory
    always @(posedge clk_rd or posedge rst)
        begin
             if (rst)
                data_reg<=0;
                
             else if (read_en && !fifo_empty)
                data_reg<=fifo_memory[rd_add];
        end
     
     //did so for debugging and stability purpose.
     assign data_out=data_reg;
     
    //writing data to the memory
    always @(posedge clk_wr)
        begin
              if(write_en && !fifo_full)
                begin
                  fifo_memory[wr_add]<=data_in;      
                end
        end
endmodule
