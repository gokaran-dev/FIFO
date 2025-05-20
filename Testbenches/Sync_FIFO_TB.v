`timescale 1ns / 1ps

module Sync_FIFO_TB();

    reg clk, rst;
    reg write_en, read_en;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire [4:0] data_counter;
    wire fifo_empty, fifo_full;


    Sync_FIFO dut(
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .read_en(read_en),
        .data_in(data_in),
        .data_out(data_out),
        .data_counter(data_counter),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full)
    );


    always 
        #5 clk=~clk;

   
    initial 
       begin
        clk=0;
        rst=1;
        write_en=0;
        read_en=0;
        data_in=8'd235;
        
        //delay given so the registers can stabalize.
        #100;           
        
        //Applying reset
        #12 rst=0;
        #10;

      //pushing   
        repeat(16)
         begin
            @(posedge clk)
            if (!fifo_full) 
              begin
                write_en<=1;
                data_in<=data_in+1;
              end
         end
            @(posedge clk);
            write_en<=0;

        #20;

      //poping
        repeat(16) 
          begin
            @(posedge clk)
            if (!fifo_empty) 
              begin
                read_en<=1;
              end          
          end
              @(posedge clk)
                read_en<=0;

        #20;

        $finish; 
    end
endmodule
