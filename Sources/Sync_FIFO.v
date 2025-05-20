`timescale 1ns / 1ps

module Sync_FIFO #(
        parameter DATA_WIDTH=8,
        parameter FIFO_DEPTH=16,
        parameter POINTER_WIDTH=$clog2(FIFO_DEPTH)
    )(  
    input wire clk, rst,
    input wire write_en, read_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg [POINTER_WIDTH:0] data_counter, //from 0 to 16
    output reg fifo_empty, fifo_full
    );

    reg [POINTER_WIDTH-1:0] head, tail;
    reg [DATA_WIDTH-1:0] fifo_memory[FIFO_DEPTH-1:0];

   //counter logic and flag management
    always @(posedge clk or posedge rst) 
      begin
        if(rst)
            begin
                fifo_empty<=1;
                fifo_full<=0;
                data_counter<=0;
            end
            
        else 
            begin
                case ({write_en && !fifo_full, read_en && !fifo_empty})
                    2'b10: data_counter<=data_counter+1; //during write data
                    2'b01: data_counter<=data_counter-1; //during read data
                    default: data_counter<=data_counter; //during hold data
                endcase
            
            //flag management
            fifo_empty<=(data_counter==0);
            fifo_full<=(data_counter==FIFO_DEPTH);
        end
    end

  

    //fetching and writing data
    always @(posedge clk or posedge rst) 
        begin
            if(rst)
                data_out<=0;
            
            //fetching data from FIFO
            data_out<=(read_en && !fifo_empty)?fifo_memory[tail]:data_out; 
            //writing data to the FIFO
            fifo_memory[head]<=(write_en && !fifo_full)?data_in:fifo_memory[head];
    end

    //updating read=tail pointer, write=head pointer
    always @(posedge clk or posedge rst) 
      begin
        if (rst) 
            begin
                head<=0;
                tail<=0;
            end 
        
        else
             begin
                //updating head
                head<=(!fifo_full && write_en)?(head+1):head;
                //upating tail
                tail<=(!fifo_empty && read_en)?(tail+1):tail;
             end
      end
endmodule
