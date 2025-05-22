`timescale 1ns / 1ps

module Read_Controller_TB;

  parameter POINTER_WIDTH = 4;
  
  // Clocks and resets
  reg clk_wr, clk_rd;
  reg rst;
  
  // Write domain signals
  reg write_en;
  wire fifo_full;
  wire [POINTER_WIDTH:0] write_ptr;
  wire [POINTER_WIDTH-1:0] write_addr;
  
  // Read domain signals
  reg read_en;
  wire fifo_empty;
  wire [POINTER_WIDTH:0] read_ptr;
  wire [POINTER_WIDTH-1:0] read_addr;
  
  // Signals to connect synchronizers
  wire [POINTER_WIDTH:0] rqs_write_ptr;  // write_ptr synchronized to read domain
  wire [POINTER_WIDTH:0] rqs_read_ptr;   // read_ptr synchronized to write domain
  
  // Instantiate Write_Controller
  Write_Controller #(.POINTER_WIDTH(POINTER_WIDTH)) write_ctrl (
    .clk_wr(clk_wr),
    .rst(rst),
    .write_en(write_en),
    .rqs_read_ptr(rqs_read_ptr),
    .write_ptr(write_ptr),
    .fifo_full(fifo_full),
    .write_addr(write_addr)
  );
  
  // Instantiate Read_Controller
  Read_Controller #(.POINTER_WIDTH(POINTER_WIDTH)) read_ctrl (
    .clk_rd(clk_rd),
    .rst(rst),
    .read_en(read_en),
    .rqs_write_ptr(rqs_write_ptr),
    .read_ptr(read_ptr),
    .read_addr(read_addr),
    .fifo_empty(fifo_empty)
  );
  
  // Synchronizer for write pointer crossing to read clock domain
  Synchronizer #(.WIDTH(POINTER_WIDTH+1)) sync_write_to_read (
    .rst(rst),
    .clk(clk_rd),
    .async_pointer(write_ptr),
    .sync_pointer(rqs_write_ptr)
  );
  
  // Synchronizer for read pointer crossing to write clock domain
  Synchronizer #(.WIDTH(POINTER_WIDTH+1)) sync_read_to_write (
    .rst(rst),
    .clk(clk_wr),
    .async_pointer(read_ptr),
    .sync_pointer(rqs_read_ptr)
  );
  
  // Clock generation
  initial begin
    clk_wr = 0;
    forever #5 clk_wr = ~clk_wr;  // 100 MHz write clock (10 ns period)
  end
  
  initial begin
    clk_rd = 0;
    forever #8 clk_rd = ~clk_rd;  // 62.5 MHz read clock (16 ns period)
  end
  
  // Test stimulus
  initial begin
    // Initialize signals
    rst = 1;
    write_en = 0;
    read_en = 0;
    
    // Reset assertion time
    #20;
    rst = 0;
    
    // Start writing after reset deasserted
    #20;
    write_en = 1;
    
    // After some writes, start reading
    #200;
    read_en = 1;
    
    // Continue simulation for a while
    #1000;
    
    // Stop write and read
    write_en = 0;
    read_en = 0;
    
    // Wait and finish simulation
    #100;
    $finish;
  end
  
endmodule
