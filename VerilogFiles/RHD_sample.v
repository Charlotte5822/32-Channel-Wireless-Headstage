`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2024 22:05:53
// Design Name: 
// Module Name: RHD_sample
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


module RHD_sample(
    input       sysclk,
    input       ADC_EN, 
    
    input         rhd_miso,
    
    output  reg   rhd_cs,
    output        rhd_sck,
    output  reg   rhd_mosi,
    
    output  reg   [15:0]      rhd_data,
    output  reg   rhd_data_en,
    
    output        led1
    
    );
    
    initial begin  rhd_cs = 1; end
    assign  rhd_sck = sysclk && (~tmp_cs);
    
    reg         [3:0]       state = IDLE;
    parameter   IDLE = 0,   CONVERT = 1, cycle = 20, IDLE_MAX = 100;
    
    reg         [5:0]       cnt_command = 0;
    reg         [15:0]      cnt_cmd_bit = 0;
    reg         [15:0]      cnt_idle = 0;
    reg         [15:0]      CMD = 16'h0000;
    
    reg                     tmp_cs;
    
    always@(posedge sysclk) begin
        case ( state )
            IDLE        :       state       <=      ( !(ADC_EN) )  ?   IDLE    :       CONVERT;
        endcase
    end
        
    // write command 
    always@(posedge sysclk) begin
        case ( state )
            IDLE:
                begin
                    rhd_cs <= 1;
                    tmp_cs <= 1;
                end
        
            CONVERT:
                if ( cnt_command < 35 ) begin  
                        CMD <= {2'b00,cnt_command,8'b00000000}; 
                        if ( cnt_cmd_bit >= 8'd16 && cnt_cmd_bit < cycle ) begin
                                cnt_cmd_bit <= cnt_cmd_bit + 1;
                                rhd_cs <= 1;
                                tmp_cs <= 1;
                            end else if (cnt_cmd_bit == cycle ) begin
                                cnt_cmd_bit <= 8'd0;
                                rhd_cs <= 0;
                                cnt_command <= cnt_command + 1;
                            end else
                                begin
                                    rhd_mosi <= CMD[15 - cnt_cmd_bit];
                                    rhd_cs   <= 1'b0;
                                    tmp_cs   <= 1'b0;
                                    cnt_cmd_bit <= cnt_cmd_bit + 1;
                                end                                    // three dummy commands
                 end else begin
                    cnt_command <= 0;
                    CMD <= 0;
                 end
        endcase
    
    end
    
    // read data from adc
    always@(posedge rhd_sck) begin
        case ( state )
            CONVERT:
                if ( cnt_command < 34 && cnt_command > 1 ) begin  
                    rhd_data <= {rhd_data[14:0],rhd_mosi};                                       
                end 
        endcase
        
    end
    
    always@(posedge sysclk) begin
        case ( state )
            CONVERT:
                if ( cnt_command < 34 && cnt_command > 1 ) begin  
                    if ( cnt_cmd_bit == 16 )
                        rhd_data_en <= 1;
                    else
                        rhd_data_en <= 0;
                end 
        endcase
        
    end
    
    // check the read data value
    assign led1 = ( rhd_data > 0 ) ? 1'b1:1'b0;
    
endmodule
