/*fork...join is a verilog command using which we can run multiple blocks of code simultaneously, parallely.
We use it here because we want to simulate read, write on a fifo memory, where both of these operations can happen parallely*/

`timescale 1ns / 1ps

module Async_FIFO_TB();

    parameter DATA_WIDTH=8;
    parameter FIFO_DEPTH=16;
    parameter POINTER_WIDTH=$clog2(FIFO_DEPTH);
    
    
    reg clk_wr,clk_rd;
    reg rst;
    reg write_en,read_en;
    reg [DATA_WIDTH-1:0]data_in;
    //wire [POINTER_WIDTH-1:0]rd_add,wr_add;        //only used to help in debugging
    wire [DATA_WIDTH-1:0]data_out;
    wire fifo_empty,fifo_full;
    
    // Instantiate DUT
    Async_FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)) 
      dut(
        .clk_rd(clk_rd),
        .clk_wr(clk_wr),
        .rst(rst),
        .write_en(write_en),
        .read_en(read_en),
        .data_in(data_in),
        .fifo_empty(fifo_empty),
        //.rd_add(rd_add),
        //.wr_add(wr_add),
        .fifo_full(fifo_full),
        .data_out(data_out)
          );
    
    
    initial 
      begin
        clk_wr=0;
        clk_rd=0;
      end
    
    always 
      #5 clk_wr=~clk_wr;  //clock for writing operations: (10ns period)
    always 
      #7 clk_rd=~clk_rd;  //clock for reading operations: (14ns period)
    
    
    initial 
      begin
        #100      //artificial delay so memory elements get some time to stabalize.
        rst=1;
        write_en=0;
        read_en=0;
        data_in=1;
        
        #50;
        rst=0;
        #10;    //waiting for sometime before writing into the FIFO, giving time for reset to propogate
        
        //writing into FIFO
        fork
            begin
                repeat(FIFO_DEPTH+2) //attempting to write more than DEPTH of FIFO
                  begin 
                    @(posedge clk_wr);
                    if(!fifo_full) 
                        begin
                          write_en<=1;
                          data_in<=data_in;
                        end 
                        
                    else 
                      begin
                        write_en<=1;  //Testing if fifo_full flag works
                      end
                    @(posedge clk_wr);
                      write_en<=0;
                      data_in<=data_in+1;
                      #10; 
                    end
              end
        join
        
        
        #100; //delay given for synchronization to take place between different clock domains
        
        //fetching data  
        fork
            begin
                repeat(FIFO_DEPTH + 2) 
                  begin  // Try to read more than written
                    @(posedge clk_rd);
                    if(!fifo_empty) 
                      begin
                        read_en<=1;
                    end 
                    
                    else 
                      begin
                        read_en<=1;  //trying to read when empty
                        $display("FIFO EMPTY; Cannot read at time %0t", $time);
                      end 
                    @(posedge clk_rd);
                    read_en<=0;
                    #10; //Small delay between reads
                end
            end
        join
        
        
        //Test 3: Concurrent read/write
        data_in=50;  //Start with different data pattern
        
        fork
            begin
                repeat(10) 
                  begin: concurrent_write
                    @(posedge clk_wr);
                    if(!fifo_full) 
                      begin
                        write_en<=1;
                      end
                    @(posedge clk_wr);
                    write_en<=0;
                    data_in<=data_in + 1;
                    #20;
                  end
              end
            
            begin: concurrent_read
                #30; // Start reading after some writes
                repeat(10)
                  begin
                    @(posedge clk_rd);
                    if(!fifo_empty) 
                      begin
                        read_en<=1;
                    end
                    @(posedge clk_rd);
                    read_en<=0;
                    #25;
                end
            end
        join    
    end
    
    
    initial 
      begin
        #10100; $finish;
      end

endmodule