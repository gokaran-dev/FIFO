`timescale 1ns / 1ps

module Write_Controller_TB;

  parameter POINTER_WIDTH = 4;
  reg clk_wr, rst, write_en;
  reg [POINTER_WIDTH:0] rqs_read_ptr;
  wire [POINTER_WIDTH:0] write_ptr;
  wire fifo_full;
  wire [POINTER_WIDTH-1:0] write_addr;

  // Instantiate the Write_Controller
  Write_Controller #(.POINTER_WIDTH(POINTER_WIDTH)) dut (
    .clk_wr(clk_wr),
    .rst(rst),
    .write_en(write_en),
    .rqs_read_ptr(rqs_read_ptr),
    .write_ptr(write_ptr),
    .fifo_full(fifo_full),
    .write_addr(write_addr)
  );

  // Clock generation
  initial begin
    clk_wr = 0;
    forever #10 clk_wr = ~clk_wr; // 20ns period = 50MHz
  end

  // Binary to Gray conversion function for TB
  function [POINTER_WIDTH:0] binary_to_gray;
    input [POINTER_WIDTH:0] bin;
    begin
      binary_to_gray = bin ^ (bin >> 1);
    end
  endfunction

  reg [POINTER_WIDTH:0] rqs_read_ptr_bin;

  initial begin
    // Initial values
    rst = 1;
    write_en = 0;
    rqs_read_ptr_bin = 0;
    rqs_read_ptr = 0;

    // Apply reset for 50 ns
    #50;
    rst = 0;

    // Enable write enable after reset is deasserted
    #40;
    write_en = 1;

    // Run simulation long enough for writes to progress and fifo to fill
    #600;

    // End simulation
    $finish;
  end

  // Synchronously update rqs_read_ptr on clk_wr posedge
  always @(posedge clk_wr) begin
    if (!rst) begin
      // Increment read pointer binary count
      rqs_read_ptr_bin <= rqs_read_ptr_bin + 1;
      // Encode to Gray
      rqs_read_ptr <= binary_to_gray(rqs_read_ptr_bin + 1);
    end else begin
      rqs_read_ptr_bin <= 0;
      rqs_read_ptr <= 0;
    end
  end

endmodule
