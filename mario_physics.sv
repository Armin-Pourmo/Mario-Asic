// Mario physics MVP
// Coordinates are VGA screen pixels (640x480)


module mario_physics #(
    parameter STEP = 2, //pixels per frame, must be <= 3
    parameter X_MAX = 10'd608, //640 - 32
    parameter Y_MAX = 10'd448, //480 - 32
    parameter X_RST = 10'd32, //spawn x
    parameter Y_RST = 10'd416 //spawn y (standing on the bottom tile row)
) (
    input logic clk, en,
    input logic n_rst, //async, active low
    input logic frame_tick, //one clock pulse per frame, clk en
    input logic btn_left, //active high, sync
    input logic btn_right,
    input logic btn_up,
    input logic [299:0] map_array, 
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

//collision logic

//collision walls 
logic [9:0] x_edge; //pixel column on the side mario moving towards
logic [9:0] x_col; //final x after collision, stored

//xt = is there a solid tile at marios top corner
//xb = is there solid tile at mario bottom corner
//hitx = mario would move into a wall this frame
logic solid_xt, solid_xb, hit_x;

//tile map logic 
tilemap probe_xt (.pos_x(x_edge), .pos_y(mario_y), .map_array(map_array), .tile_type(solid_xt)); //top corner
tilemap probe_xb (.pos_x(x_edge), .pos_y(mario_y + 10'd31), .map_array(map_array), .tile_type(solid_xb)); //bottom corner

//only count it as a hit if mario is actually moving sideways
assign hit_x = (dx != 0) && (solid_xt || solid_xb);

//pick the final x 
always_comb begin
    if (!hit_x) begin
        //no wall, keep position from clamp
        x_col = x_next;
    end
    else if (dx > 0) begin
        //wall on the right, clears the low 5 bits = left ege of the tile he hit
        x_col = {x_edge[9:5], 5'd0} - 10'd32;
    end
    else begin
        //wall on the left, + 32 instead
        x_col = {x_edge[9:5], 5'd0} + 10'd32;
    end
end

//Y collision logic 
logic [9:0] y_edge; //pixel row on the side mario's moving towards
logic [9:0] y_col; //final y after the collision, get stored

//yl = is there a solid tile at marios left corner
//yr = is there a solid tile at marios right corner
//hit_y = mario would move into a floor or ceiling this frame
logic solid_yl, solid_yr, hit_y;

//falling, the leading side is marios bottom edge (y + 31)
assign y_edge = (dy > 0) ? y_next + 10'd31 : y_next;

//uses x_col so a wall hit is resolved before checking y
tilemap probe_yl (.pos_x(x_col), .pos_y(y_edge), .map_array(map_array), .tile_type(solid_yl)); //left corner
tilemap probe_yr (.pos_x(x_col + 10'd31), .pos_y(y_edge), .map_array(map_array), .tile_type(solid_yr)); //right corner

//mario rising or falling
assign hit_y = solid_yl || solid_yr;

//pick the final Y
always_comb begin
    if (!hit_y) begin
        //nothing then y_next
        y_col = y_next;
    end
    else if (dy > 0) begin
        //if top edge hit - mario height
        y_col = {y_edge[9:5], 5'd0} - 10'd32;
    end
    else begin
        y_col = {y_edge[9:5], 5'd0} + 10'd32;
    end
end

//move right (x + 31) or x = left
assign x_edge = (dx > 0) ? x_next + 10'd31 : x_next;

//register, the only state, updated once per frame
always_ff @(posedge clk, negedge n_rst) begin
    if (!n_rst) begin
        mario_x <= X_RST;
        mario_y <= Y_RST;
    end
    else if (frame_tick & en) begin
        mario_x <= x_col;
        mario_y <= y_col;
    end
end

endmodule
