/*module RHD(
    input   clk,
    input   rhd_miso,
    output  rhd_mosi,
    output  rhd_cs,
    output  rhd_sck,
    output  rd_data,
    output  rd_data_en,
    output  led
);

        wire            init_mosi,  init_cs,    init_sck;
        wire            rhd_init;


        
        RHD_init                 RHD_init_inst      (
        .clk                     (   CLK_16mhz      ),
        .rhd_miso                (   rhd_miso       ),
        .rhd_mosi                (   rhd_mosi       ),
        .rhd_cs                  (   rhd_cs         ),
        .rhd_sck                 (   rhd_sck        ),
        .rhd_init                (   rhd_init       ),
        .led                     (    led           )
        );

        // ============ RHD 2132 ADC sample ============ //
        
        wire        sample_mosi, sample_cs, sample_sck;
        
        wire   [15:0]     rd_data;
        wire              rd_data_en;

    
        RHD_sample               RHD_sample_inst    (
        .sysclk                  (   CLK_16mhz      ),
        .ADC_EN                  (   rhd_init       ),
        
        .rhd_miso                (   rhd_miso       ),
        .rhd_mosi                (   rhd_mosi    ),
        .rhd_cs                  (   rhd_cs      ),
        .rhd_sck                 (   rhd_sck     ),
        
        .rhd_data                (   rd_data        ),
        .rhd_data_en             (   rd_data_en     )
        
        //.led1                    (   LED           )
        
        );

endmodule*/