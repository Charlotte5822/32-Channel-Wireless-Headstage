
module clk_pll(
    input   CLK_16mhz,
    output  clk20,
    output  clk40,
    output  clk80,
    output  clk160
);

        SB_PLL40_CORE TinyFPGA_BX_pll_inst(
            .REFERENCECLK(CLK_16mhz),
            .PLLOUTCORE(clk160),
            .RESETB(1'b1),
            .BYPASS(1'b0)
        );

            //\\ Fin=16, Fout=160;
            defparam TinyFPGA_BX_pll_inst.DIVR = 4'b0000;
            defparam TinyFPGA_BX_pll_inst.DIVF = 7'b0100111;
            defparam TinyFPGA_BX_pll_inst.DIVQ = 3'b010;
            defparam TinyFPGA_BX_pll_inst.FILTER_RANGE = 3'b001;
            defparam TinyFPGA_BX_pll_inst.FEEDBACK_PATH = "SIMPLE";
            defparam TinyFPGA_BX_pll_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
            defparam TinyFPGA_BX_pll_inst.FDA_FEEDBACK = 4'b0000;
            defparam TinyFPGA_BX_pll_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
            defparam TinyFPGA_BX_pll_inst.FDA_RELATIVE = 4'b0000;
            defparam TinyFPGA_BX_pll_inst.SHIFTREG_DIV_MODE = 2'b00;
            defparam TinyFPGA_BX_pll_inst.PLLOUT_SELECT = "GENCLK";
            defparam TinyFPGA_BX_pll_inst.ENABLE_ICEGATE = 1'b0;

            // generate 20, 40 and 80 MHz clk
            clk_divide clk_div_inst(
                    .rst_n      (   1'b1        ),
                    .clk        (   clk160      ),
                    .clk_div2   (   clk80       ),
                    .clk_div4   (   clk40       ),
                    .clk_div8   (   clk20       )
            );

endmodule