// Mario physics MVP
// Coordinates are VGA screen pixels (640x480)


module mario_physics #(
    parameter STEP = 2, //pixels per frame, must be <= 3
    parameter X_MAX = 10'd608, //640 - 32
    parameter Y_MAX = 10'd448, //480 - 32
    parameter X_RST = 10'd32, //spawn x
    parameter Y_RST = 10'd416 //spawn y (standing on the bottom tile row)
) (
    input logic clk,
    input logic rst, //sync, active high
    input logic frame_tick, //one clock pulse per frame, clk en
    input logic btn_left, //active high, sync
    input logic btn_right,
    input logic btn_up,
    output logic [9:0] mario_x,
    output logic [9:0] mario_y
);

//delta Select, left+right cancel, up moves up mario falls without holding up
logic signed [2:0] dx;
logic signed [2:0] dy;

always_comb begin
    if (btn_right && !btn_left) begin
        dx = STEP;
    end
    else if (btn_left && !btn_right) begin
        dx = -STEP;
    end
    else begin
        dx = 0;
    end

    //fall logic
    if (btn_up) begin
        dy = -STEP;
    end
    else begin
        dy = STEP;
    end
end

//adder, extra bit stops going past 0 making it wrap to 1022
logic [10:0] x_sum;
logic [10:0] y_sum;
assign x_sum = {1'b0, mario_x} + {{8{dx[2]}}, dx};
assign y_sum = {1'b0, mario_y} + {{8{dy[2]}}, dy};

//clamp logic, two comparators + mux
//keep mario on screen, check negative first or if it looks too big it pushes right
logic [9:0] x_next;
logic [9:0] y_next;

always_comb begin
    if (x_sum[10]) begin
        x_next = 10'd0;
    end
    else if (x_sum > X_MAX) begin
        x_next = X_MAX;
    end
    else begin
        x_next = x_sum[9:0];
    end

    if (y_sum[10]) begin
        y_next = 10'd0;
    end
    else if (y_sum > Y_MAX) begin
        y_next = Y_MAX;
    end
    else begin
        y_next = y_sum[9:0];
    end
end

//register, the only state, updated once per frame
always_ff @(posedge clk) begin
    if (rst) begin
        mario_x <= X_RST;
        mario_y <= Y_RST;
    end
    else if (frame_tick) begin
        mario_x <= x_next;
        mario_y <= y_next;
    end
end

endmodule
