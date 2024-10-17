`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2024 13:54:05
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////

module Spi_master (
    input   wire clk_160mhz,
    input   wire en,
    output  reg  cs,
    output  reg  sclk,
    output  reg  data0,
    output  reg  data1,
    output  reg  data2,
    output  reg  data3,

    input  wire spi_en,
    input  wire [32*16*2-1:0] frame,
    input  wire [7:0] spi_frame_id
);

       localparam Hdr_Len = 32;       
       localparam SPI_IDLE          = 3'b000;
       localparam SPI_INIT          = 3'b001;
       localparam SPI_TRANSMIT      = 3'b010;
       localparam SPI_CSOFF         = 3'b011; 
       localparam SPI_LOAD          = 3'b111; 
       localparam SPI_LOAD1         = 3'b110; 
       localparam SPI_LOAD2         = 3'b100; 
       
       localparam [7:0] cmd         = 8'h03;        
       localparam [7:0] addr        = 8'h00;
       localparam [7:0] dummy       = 8'h00;  
       localparam [15:0] frame_len  = 1024;//11496;                         // content
       localparam [15:0] trans_len  = 32+frame_len;               // 1000 bytes
       localparam csoff_len         = 160*5;//160*30;
       localparam en_len            = 160;//160;
       
        reg [7:0] seq = 0;
        reg [trans_len-1:0] tx_buf = 0;
        reg [15:0] tx_cnt = 0;
        reg [15:0] csoff_tick = 0;
        reg [15:0] en_tick = 0;
        reg [2:0]  spi_state = SPI_IDLE;
        reg [15:0] off_cnt = 0;
        
        reg frame_enable;
        reg spi_flag = 0;
        
        
         
       // STATE MACHINE
       /*always@(posedge clk_160mhz)begin
            case (spi_state)
                SPI_IDLE        :       spi_state       <=      (en_tick < en_len)          ?   SPI_IDLE    :   SPI_INIT;
                SPI_INIT        :       spi_state       <=      SPI_TRANSMIT;
                SPI_TRANSMIT    :       spi_state       <=      (tx_cnt == trans_len)       ?   SPI_CSOFF   :   SPI_TRANSMIT;
                SPI_CSOFF       :       spi_state       <=      (csoff_tick >= csoff_len)   ?   SPI_IDLE    :   SPI_CSOFF;
            endcase
       end*/
       
       // sender 
       reg [7:0] prev_frame_id = 0;
       reg [15:0] bit_len = 0;
       reg [15:0] spi_frame_cnt = 0;
       reg [15:0] tx_buf_cnt;
       integer i;
             
      always @(posedge clk_160mhz) begin
      if ( spi_en ) begin
        case (spi_state)
            SPI_IDLE: begin
                data0 <= 0;
                data1 <= 0;
                data2 <= 0;
                data3 <= 0;
                sclk <= 0;
                cs <= 1;
       
                if (!en) begin
                	en_tick <= 0;
                end else begin
                	if (en_tick < en_len) begin
		                en_tick <= en_tick + 1;
		            end else begin
                        prev_frame_id <= spi_frame_id;
                        tx_buf <= {cmd,addr,dummy,spi_frame_id,frame};
		                spi_state <= (prev_frame_id==spi_frame_id) ? SPI_IDLE : SPI_LOAD;
		                 //  spi_state <= SPI_LOAD;
		            end
                end
            end
            
            SPI_LOAD : begin

                spi_state <= SPI_INIT;
            end
 
            SPI_INIT: begin
                data0 <= tx_buf[trans_len-1];
                data1 <= 0;
                data2 <= 0;
                data3 <= 0;
            	cs <= 0;
                tx_cnt <= 1;
                spi_state <= SPI_TRANSMIT;
            end

            SPI_TRANSMIT: begin
            	sclk <= ~sclk;
	            if (sclk) begin // sclk negedge
	                if (tx_cnt == trans_len) begin
            			csoff_tick <= 0;
            			spi_state <= SPI_CSOFF;
            		end else begin
                        data0 <=tx_buf[trans_len-tx_cnt-1];
                        data1 <= 0;
                        data2 <= 0;
                        data3 <= 0;
                        tx_cnt <= tx_cnt+1;
				    end
                end
            end

            SPI_CSOFF: begin
                data0 <= 0;
                data1 <= 0;
                data2 <= 0;
                data3 <= 0;
                sclk <= 0;
                cs <= 1;
                csoff_tick <= csoff_tick + 1;
                if ( (csoff_tick >= csoff_len)) begin
                    en_tick <= 0;
                    spi_state <= SPI_IDLE;
                end
            end
        endcase
        end
    end

endmodule
