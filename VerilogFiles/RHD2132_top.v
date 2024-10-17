`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2024 20:32:44
// Design Name: 
// Module Name: RHD2132_top
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


module RHD2132_top(

    input    sysclk,
    input    rhd_miso,
    
    output  reg   rhd_cs,
    output        rhd_sck,
    output  reg   rhd_mosi,
    
    output  uart_tx,
    
    output  led
       
    );
        
    
    wire clk25;
    clk_wiz_0   clk_wiz_inst1(
    .clk_in1       ( sysclk    ),
    .clk_out1      ( clk25   )
    );
    
    initial rhd_cs = 1;
    assign rhd_sck = clk25 && (~tmp_cs);
        
    reg     [3:0]       state = IDLE;    
    
    reg     [7:0]       cnt_ack_bit = 0;
    reg     [7:0]       cnt_cmd_bit = 0;
    reg     [7:0]       cnt_wat_bit = 0;
    reg     [7:0]       cnt_idl_bit = 0;
    
    reg     tmp_cs;
    
    reg     [15:0]      rhd_ack = 16'hffff;
    
    parameter     MSG_REG0       = 16'b1000000011111110;
    parameter     MSG_REG0_READ  = 16'b1100000000000000;
    parameter     MSG_REG63_READ = 16'b1110101000000000;        // read command: {11 + 5bit: reg id + 00000000}
    parameter     WAIT_MAX       = 12'd100;
    
    parameter     IDLE = 4'd0,   REG0_W = 4'd1,  REG0_R = 4'd2, REG0_ACK = 4'd3, WAIT = 4'd4, X = 4'd5;
    parameter     cycle = 22;

    always@(posedge clk25)
        case (state)
            IDLE        :   state       <=      (   cnt_idl_bit == WAIT_MAX     ) ?   REG0_W     :   IDLE  ;
            REG0_W      :   state       <=      (   cnt_cmd_bit == cycle        ) ?   WAIT       :   REG0_W;
            WAIT        :   state       <=      (   cnt_wat_bit == cycle        ) ?   REG0_ACK   :   WAIT;
            REG0_ACK    :   state       <=      (   cnt_ack_bit == cycle        ) ?   X          :   REG0_ACK;
        endcase
    
    always@(posedge clk25)
        case (state)
            IDLE:
                if ( cnt_idl_bit < WAIT_MAX ) begin
                    cnt_idl_bit <= cnt_idl_bit + 1;
                    rhd_cs <= 1;
                    tmp_cs <= 1;
                end else begin
                    rhd_cs <= 0;
                end
                
            REG0_W:
                begin
                    if ( cnt_cmd_bit >= 8'd16 && cnt_cmd_bit < cycle ) begin
                        cnt_cmd_bit <= cnt_cmd_bit + 1;
                        rhd_cs <= 1;
                        tmp_cs <= 1;
                    end else if (cnt_cmd_bit == cycle ) begin
                        cnt_cmd_bit <= 8'd0;
                        rhd_cs <= 0;
                    end else
                        begin
                            rhd_mosi <= MSG_REG63_READ[15 - cnt_cmd_bit];
                            rhd_cs   <= 1'b0;
                            tmp_cs   <= 1'b0;
                            cnt_cmd_bit <= cnt_cmd_bit + 1;
                        end
                end
                
               WAIT:
                    begin
                    
                    if ( cnt_wat_bit >= 8'd16 && cnt_wat_bit < cycle ) begin
                        cnt_wat_bit <= cnt_wat_bit + 1;
                        rhd_cs <= 1;
                        tmp_cs <= 1;
                    end else if ( cnt_wat_bit == cycle ) begin
                        cnt_wat_bit <= 1'b0;
                        rhd_cs <= 0;
                    end else
                        begin
                            cnt_wat_bit <= cnt_wat_bit + 1;
                            rhd_cs      <= 1'b0;
                            tmp_cs      <= 1'b0;
                        end
                        
                    end
               
                
             REG0_ACK:
                begin
                    if ( cnt_ack_bit >= 8'd16 && cnt_ack_bit < cycle) begin
                        cnt_ack_bit <= cnt_ack_bit + 1;
                        rhd_cs <= 1;
                        tmp_cs <= 1;
                    end else if ( cnt_ack_bit == cycle ) begin
                        cnt_ack_bit <= 8'd0;
                        rhd_cs <= 0;
                    end else
                        begin
                            rhd_ack  <= {rhd_ack[14:0],rhd_miso};
                            rhd_cs   <= 1'b0;
                            tmp_cs <= 0;
                            cnt_ack_bit <= cnt_ack_bit + 1;
                        end
                end
                
        endcase               
       
       /*reg tmp = 0;       
       always@(posedge rhd_sck)
            if ( rhd_ack[15] == 1)
                   tmp <= 1;
                   
       
       assign led = ( tmp ) ? 1'b1 : 1'b0;*/
       assign led = ( rhd_ack == 84 ) ? 1'b1 : 1'b0;
               
endmodule
