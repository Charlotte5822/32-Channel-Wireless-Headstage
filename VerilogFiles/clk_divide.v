//偶数分频电路设计（2分频、4分频、8分频、6分频）
//触发器法实现2分频、4分频、8分频
//计数器法实现6分频
module clk_divide(
    input 		rst_n,			//复位信号
    input 		clk,			//源时钟信号
    output 		clk_div2,		//输出2分频
    output 		clk_div4,		//输出4分频
    output 		clk_div6,		//输出6分频
    output 		clk_div8		//输出8分频
    );

//定义4个中间寄存器和1个计数器    
reg         clk_div2_r;
reg 		clk_div4_r;
reg 		clk_div6_r;
reg 		clk_div8_r;
reg [3:0] cnt;

//2分频时钟输出模块
//源时钟上升沿触发，低电平异步复位
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin		//低电平复位
        clk_div2_r <= 1'b0;
    end
    else begin
        clk_div2_r <= ~clk_div2_r;		//源时钟上升沿信号翻转得到2分频时钟
    end
end

assign clk_div2 = clk_div2_r;		//延时输出，消除亚稳态

//4分频时钟输出模块
//2分频时钟上升沿触发 低电平异步复位
always @(posedge clk_div2 or negedge rst_n) begin
    if (!rst_n) begin
        clk_div4_r <= 1'b0;
    end
    else begin
        clk_div4_r <= ~clk_div4_r;		//2分频时钟上升沿信号翻转得到4分频时钟
    end
end

assign clk_div4 = clk_div4_r;		//延时输出，消除亚稳态

//8分频时钟输出模块
//4分频时钟上升沿触发 低电平异步复位
always @(posedge clk_div4 or negedge rst_n) begin
    if (!rst_n) begin
        clk_div8_r <= 'b0;
    end
    else begin
        clk_div8_r <= ~clk_div8_r;		//4分频时钟上升沿信号翻转得到8分频时钟
    end
end
    
assign clk_div8 = clk_div8_r;		//延时输出，消除亚稳态

//计数器模块
//源时钟上升沿触发，低电平异步复位
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin		//低电平复位
        cnt    <= 4'b0 ;
    end
    else if (cnt == 2) begin		//计数器从0计数，到2清零
        cnt    <= 4'b0 ;
    end
    else begin				//计数累加
        cnt    <= cnt + 1'b1 ;
    end
end

//6分频时钟输出模块
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin		
        clk_div6_r <= 1'b0;
    end
    else if (cnt == 2 ) begin		//3个周期信号翻转得到6分频时钟
        clk_div6_r <= ~clk_div6_r;
    end
end
    
assign clk_div6 = clk_div6_r;		//延时输出，消除亚稳态

endmodule