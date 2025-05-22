`timescale 1ns / 1ps

module Async_FIFO_TB;
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter POINTER_WIDTH = $clog2(FIFO_DEPTH);
    
    // Testbench signals
    reg clk_wr, clk_rd;
    reg rst;
    reg write_en, read_en;
    reg [DATA_WIDTH-1:0] data_in;
    
    wire [DATA_WIDTH-1:0] data_out;
    wire fifo_empty, fifo_full;
    
    // Instantiate DUT
    Async_FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk_rd(clk_rd),
        .clk_wr(clk_wr),
        .rst(rst),
        .write_en(write_en),
        .read_en(read_en),
        .data_in(data_in),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full),
        .data_out(data_out)
    );
    
    // Clock generation - different frequencies for async operation
    initial begin
        clk_wr = 0;
        clk_rd = 0;
    end
    
    always #5  clk_wr = ~clk_wr;  // 100MHz (10ns period)
    always #7  clk_rd = ~clk_rd;  // ~71MHz (14ns period)
    
    // Variables for monitoring
    integer write_count = 0;
    integer read_count = 0;
    reg [DATA_WIDTH-1:0] expected_data = 1;
    
    // Monitor important signals
    initial begin
        $monitor("Time=%0t | WR_CLK=%b RD_CLK=%b | WE=%b RE=%b | DIN=%0d DOUT=%0d | EMPTY=%b FULL=%b | WR_CNT=%0d RD_CNT=%0d", 
                 $time, clk_wr, clk_rd, write_en, read_en, data_in, data_out, fifo_empty, fifo_full, write_count, read_count);
    end
    
    // Main test sequence
    initial begin
        // Initialize all signals
        rst = 1;
        write_en = 0;
        read_en = 0;
        data_in = 1;
        
        $display("=== ASYNC FIFO TEST START ===");
        $display("FIFO_DEPTH = %0d, DATA_WIDTH = %0d", FIFO_DEPTH, DATA_WIDTH);
        
        // Hold reset for several clock cycles
        #50;
        rst = 0;
        $display("Reset released at time %0t", $time);
        
        // Wait for reset to propagate
        #20;
        
        // Test 1: Fill FIFO completely
        $display("\n=== TEST 1: FILLING FIFO ===");
        fork
            begin : write_process
                repeat (FIFO_DEPTH + 2) begin  // Try to write more than FIFO depth
                    @(posedge clk_wr);
                    if (!fifo_full) begin
                        write_en <= 1;
                        data_in <= data_in;
                        $display("Writing: %0d at time %0t", data_in, $time);
                        write_count <= write_count + 1;
                    end else begin
                        write_en <= 1;  // Keep trying to write when full
                        $display("FIFO FULL - Cannot write %0d at time %0t", data_in, $time);
                    end
                    @(posedge clk_wr);
                    write_en <= 0;
                    data_in <= data_in + 1;
                    #10; // Small delay between writes
                end
            end
        join
        
        $display("Write phase completed. Total writes attempted: %0d", write_count);
        
        // Wait for synchronization
        #100;
        
        // Test 2: Read all data
        $display("\n=== TEST 2: EMPTYING FIFO ===");
        expected_data = 1;  // Reset expected data
        
        fork
            begin : read_process
                repeat (FIFO_DEPTH + 2) begin  // Try to read more than written
                    @(posedge clk_rd);
                    if (!fifo_empty) begin
                        read_en <= 1;
                        $display("Reading at time %0t, expecting %0d", $time, expected_data);
                    end else begin
                        read_en <= 1;  // Keep trying to read when empty
                        $display("FIFO EMPTY - Cannot read at time %0t", $time);
                    end
                    @(posedge clk_rd);
                    if (read_en && !fifo_empty) begin
                        if (data_out == expected_data) begin
                            $display("? Read correct data: %0d", data_out);
                        end else begin
                            $display("? Read incorrect data: %0d, expected: %0d", data_out, expected_data);
                        end
                        expected_data <= expected_data + 1;
                        read_count <= read_count + 1;
                    end
                    read_en <= 0;
                    #10; // Small delay between reads
                end
            end
        join
        
        $display("Read phase completed. Total reads: %0d", read_count);
        
        // Test 3: Concurrent read/write
        $display("\n=== TEST 3: CONCURRENT READ/WRITE ===");
        
        // Reset counters
        write_count = 0;
        read_count = 0;
        data_in = 50;  // Start with different data pattern
        
        fork
            begin : concurrent_write
                repeat (10) begin
                    @(posedge clk_wr);
                    if (!fifo_full) begin
                        write_en <= 1;
                        $display("Concurrent write: %0d", data_in);
                        write_count <= write_count + 1;
                    end
                    @(posedge clk_wr);
                    write_en <= 0;
                    data_in <= data_in + 1;
                    #20;
                end
            end
            
            begin : concurrent_read
                #30; // Start reading after some writes
                repeat (10) begin
                    @(posedge clk_rd);
                    if (!fifo_empty) begin
                        read_en <= 1;
                        $display("Concurrent read: %0d", data_out);
                        read_count <= read_count + 1;
                    end
                    @(posedge clk_rd);
                    read_en <= 0;
                    #25;
                end
            end
        join
        
        // Final status
        #100;
        $display("\n=== FINAL STATUS ===");
        $display("FIFO Empty: %b, FIFO Full: %b", fifo_empty, fifo_full);
        $display("Total Writes: %0d, Total Reads: %0d", write_count, read_count);
        
        #50;
        $display("=== TEST COMPLETED ===");
        $finish;
    end
    
    // Timeout protection
    initial begin
        #10100;
        $display("ERROR: Testbench timeout!");
        $finish;
    end
    
    // Debug: Monitor internal pointer states (if accessible)
    // You might need to add these as outputs in your design for debugging
    /*
    always @(posedge clk_wr) begin
        $display("WR_DOMAIN: wr_bin=%0d, wr_gray=%b, sync_rd_gray=%b", 
                 dut.write_address.write_bin, dut.wr_ptr_gray, dut.sync_rd_ptr_gray);
    end
    
    always @(posedge clk_rd) begin
        $display("RD_DOMAIN: rd_bin=%0d, rd_gray=%b, sync_wr_gray=%b", 
                 dut.read_address.read_bin, dut.rd_ptr_gray, dut.sync_wr_ptr_gray);
    end
    */

endmodule