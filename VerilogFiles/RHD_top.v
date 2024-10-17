`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2024 16:28:49
// Design Name: 
// Module Name: RHD_top
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


module RHD_top(
    input           sysclk,
    
    input           rhd_miso,
    
    output          rhd_mosi,
    output          rhd_cs,
    output          rhd_sck,
    
    // output          rd_data,
    // output          rd_data_en,
    
    output          led,
    output          led1
    );
    
    // select a 20MHz clock to drive the Intan chip
    wire clk;
    clk_wiz_0   clk_wiz_inst(
    .clk_in1       ( sysclk    ),
    .clk_out1      ( clk       )
    );
    
    // rhd signal select
    assign rhd_mosi     =   ( !ADC_EN )    ?   init_mosi :     sample_mosi;
    assign rhd_cs       =   ( !ADC_EN )    ?   init_cs   :     sample_cs;
    assign rhd_sck      =   ( !ADC_EN )    ?   init_sck  :     sample_sck;
    
    // =========== RHD 2132 init module =========== //
    wire        init_mosi, init_cs, init_sck;
    
    RHD_init                 RHD_init_inst      (
    .clk                     (   clk            ),
    .rhd_miso                (   rhd_miso       ),
    .rhd_mosi                (   init_mosi      ),
    .rhd_cs                  (   init_cs        ),
    .rhd_sck                 (   init_sck       ),
    .rhd_init                (   rhd_init       ),
    .led                     (   led            )
    );
    
    // ============ RHD 2132 ADC sample ============ //
    
    wire        ADC_EN;     // ADC enable signal
    
    assign      ADC_EN      =       rhd_init;
    wire        sample_mosi, sample_cs, sample_sck;
    
  
    RHD_sample               RHD_sample_inst    (
    .sysclk                  (   clk            ),
    .ADC_EN                  (   ADC_EN         ),
    
    .rhd_miso                (   rhd_miso       ),
    .rhd_mosi                (   sample_mosi    ),
    .rhd_cs                  (   sample_cs      ),
    .rhd_sck                 (   sample_sck     ),
    
    //.rhd_data                (   rd_data        ),
    //.rhd_data_en             (   rd_data_en     ),
    
    .led1                    (   led1           )
    
    );
    
endmodule
