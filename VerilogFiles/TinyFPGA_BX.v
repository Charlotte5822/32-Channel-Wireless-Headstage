`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2024 15:36:03
// Design Name: 
// Module Name: TinyFPGA_BX
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
//////////////////////////////////////////////////////////////////////////////////


module TinyFPGA_BX(
    input   CLK_16mhz,
    
    // for esp spi communication port
    input  wire ESP32_EN,
    output wire ESP32_CS,
    output wire ESP32_SCLK,
    output wire ESP32_DATA0,
    output wire ESP32_DATA1,
    output wire ESP32_DATA2,
    output wire ESP32_DATA3,

    // RHD signals
    input  wire  rhd_miso,
    output  rhd_mosi,
    output  rhd_cs,
    output  rhd_sck,

    // Uart signal for init
    // input   uart_rx,
    // output  uart_tx,
    
    output  LED
    );

        // ****** Time PLL module *******
        wire clk160, clk80, clk40, clk20;

        clk_pll clk_pll_inst(
            .CLK_16mhz  (   CLK_16mhz   ),
            .clk160     (   clk160      ),
            .clk80      (   clk80       ),
            .clk40      (   clk40       ),
            .clk20      (   clk20       )
        );
            

    
        // ****** 1. DATA SOURCE ****** //
    
        // 2. RHD INTAN signal

        // =========== RHD 2132 init module =========== //
        reg            rhd_init;
        wire   [15:0]     rd_data;
        wire              rd_data_en;
        
        RHD_init                 RHD_init_inst      (
        .clk                     (   CLK_16mhz      ),
        .rhd_miso                (   rhd_miso       ),
        .rhd_mosi                (   rhd_mosi       ),
        .rhd_cs                  (   rhd_cs         ),
        .rhd_sck                 (   rhd_sck        ),
        .rhd_init                (   rhd_init       ),
        .rhd_data                (   rd_data        ),
        .rhd_data_en             (   rd_data_en     )
        // .led                     (    LED           )
        );

    
        // ****** 2. frame buffer ******//
        reg [32*16*2-1:0] frame;
        reg [15:0] byte_cnt;
        reg         frame_en;

        always@(posedge CLK_16mhz)begin
            frame_en <= 0;
            if ( rd_data_en ) begin
                byte_cnt <= byte_cnt + 1;
                frame[byte_cnt*16+:16] <= rd_data;
                if ( byte_cnt == 32*2 - 1) begin
                        byte_cnt <= 0;
                        frame_en <= 1;
                    end else
                        frame_en <= 0;
            end
        end

        // 
        reg [31:0] frame_cnt;
        reg [07:0] spi_f_cnt;
        always@(posedge CLK_16mhz) begin
            if ( frame_en ) begin
                frame_cnt <= frame_cnt + 1;
                spi_f_cnt <= spi_f_cnt + 1;
            end
        end

        assign LED = (frame_cnt > 32'd50000) ? 1 : 0;

        
        // ****** 3. spi transmit *******
        reg [32*16*2-1:0] spi_frame;

        always@(posedge CLK_16mhz) begin
            if ( frame_en ) begin
                spi_frame <= frame;
            end
        end

        wire spi_en;
        assign spi_en = (frame_en) ? 1:spi_en;

        Spi_master spi(

        .clk_160mhz             (clk80                  ),
        .spi_en                 (spi_en                 ),
        
        .en                     (ESP32_EN               ),
        .cs                     (ESP32_CS               ),
        .sclk                   (ESP32_SCLK             ),
        .data0                  (ESP32_DATA0            ),
        .data1                  (ESP32_DATA1            ),
        .data2                  (ESP32_DATA2            ),
        .data3                  (ESP32_DATA3            ),
        
        .frame                  (spi_frame              ),
        .spi_frame_id           (spi_f_cnt              ) 

        ); 
        
        
endmodule
