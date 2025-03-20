module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Internal signals
    wire reset = ~rst_n;         // Active high reset
    wire time_1sec, time_5sec;   // Timer signals
    wire [1:0] dir_n, dir_e, dir_s, dir_w; // Traffic directions

    // Instantiate counter module
    counter u_counter (
        .clk(clk),
        .reset(reset),
        .time_1sec(time_1sec),
        .time_5sec(time_5sec)
    );

    // Instantiate traffic_light_controller module
    traffic_light_controller u_traffic_light (
        .clk(clk),
        .rst(reset),
        .time_1sec(time_1sec),
        .time_5sec(time_5sec),
        .dir_n(dir_n),
        .dir_e(dir_e),
        .dir_s(dir_s),
        .dir_w(dir_w)
    );

    // Assign traffic light outputs to uo_out (4 directions, 2 bits each)
    assign uo_out = {dir_n, dir_e, dir_s, dir_w};

    // Unused IO paths, assign to 0
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in, 1'b0};

endmodule



module traffic_light_controller (
    input wire clk,
    input wire rst,
    input wire time_1sec,
    input wire time_5sec,
    output reg [1:0] dir_n,
    output reg [1:0] dir_e,
    output reg [1:0] dir_s,
    output reg [1:0] dir_w
);

    
    parameter [3:0] RST = 4'b0000;
    parameter [3:0] S0 = 4'b0001;
    parameter [3:0] S1 = 4'b0010;
    parameter [3:0] S2 = 4'b0011;
    parameter [3:0] S3 = 4'b0100;
    parameter [3:0] S4 = 4'b0101;
    parameter [3:0] S5 = 4'b0110;
    parameter [3:0] S6 = 4'b0111;
    parameter [3:0] S7 = 4'b1000;

    reg [3:0] current_state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= RST;
        end else begin
            current_state <= next_state;
        end
    end

    
    always @(time_5sec or  time_1sec or current_state ) begin
        case (current_state)
            RST: begin
                dir_n = 2'b01;
                dir_e = 2'b01;
                dir_s = 2'b01;
                dir_w = 2'b01;
					 
					 if(time_1sec==1'b1)
                next_state = S0;
					 else
					 next_state=current_state;
					 
            end
            S0: begin
                dir_n = 2'b10;
                dir_e = 2'b00;
                dir_s = 2'b00;
                dir_w = 2'b00;
                if (time_5sec == 1'b1)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                dir_n = 2'b01;
                dir_e = 2'b01;
                dir_s = 2'b00;
                dir_w = 2'b00;
                if (time_1sec == 1'b1)
                    next_state = S2;
                else
                    next_state = S1;
            end
            S2: begin
                dir_n = 2'b00;
                dir_e = 2'b10;
                dir_s = 2'b00;
                dir_w = 2'b00;
                if (time_5sec == 1'b1)
                    next_state = S3;
                else
                    next_state = S2;
            end
            S3: begin
                dir_n = 2'b00;
                dir_e = 2'b01;
                dir_s = 2'b01;
                dir_w = 2'b00;
                if (time_5sec == 1'b1)
                    next_state = S4;
                else
                    next_state = S3;
            end
            S4: begin
                dir_n = 2'b00;
                dir_e = 2'b00;
                dir_s = 2'b10;
                dir_w = 2'b00;
                if (time_5sec == 1'b1)
                    next_state = S5;
                else
                    next_state = S4;
            end
            S5: begin
                dir_n = 2'b00;
                dir_e = 2'b00;
                dir_s = 2'b01;
                dir_w = 2'b01;
                if (time_1sec == 1'b1)
                    next_state = S6;
                else
                    next_state = S5;
            end
            S6: begin
                dir_n = 2'b00;
                dir_e = 2'b00;
                dir_s = 2'b00;
                dir_w = 2'b10;
                if (time_5sec == 1'b1)
                    next_state = S7;
                else
                    next_state = S6;
            end
            S7: begin
                dir_n = 2'b01;
                dir_e = 2'b00;
                dir_s = 2'b00;
                dir_w = 2'b01;
                if (time_1sec == 1'b1)
                    next_state = S0;
                else
                    next_state = S7;
            end
            default: begin
                
                next_state=RST;
            end
        endcase
    end
endmodule

     
  module counter(input wire clk,
    input wire reset,
    output reg time_1sec,
    output reg time_5sec
);

    reg [25:0] count_1;
    reg [2:0] count_5;

    parameter sec_1 = 26'd50*1000 * 1000;
    parameter sec_5 = 3'd5;

    always @(posedge clk ,posedge reset) begin
        if (reset) begin
            count_1 <= 0;
            count_5 <= 0;
            time_1sec <= 1'b0;
            time_5sec <= 1'b0;
        end else begin
            if (count_1 == sec_1) begin
                count_1 <= 0;
                time_1sec <= 1'b1;

                if (count_5 == sec_5) begin
                    count_5 <= 0;
                    time_5sec <= 1'b1;
                end else begin
                    count_5 <= count_5 + 1'b1;
                   // time_5sec <= 1'b0;
                end
            end else begin
                count_1 <= count_1 + 1'b1;
		count_5 <= count_5;
                time_1sec <= 1'b0;
                time_5sec <= 1'b0;
            end
        end
    end
endmodule

