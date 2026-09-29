`default_nettype none
module Mario_Top (
    input logic btn_left,btn_right,btn_up,btn_rst,
    input logic clock_12m,
    output logic X_SYNC_OUT, Y_SYNC_OUT, 
    output logic[11:0] color_out
);

`include "Sprites/level_1.svh"

logic clk, rst, locked; //clock signals
logic X_SYNC, Y_SYNC, de, frame_tick; //VGA signals
logic[9:0] X_COUNT, Y_COUNT, mario_x, mario_y;
//color signals
logic[11:0] m_rgb, o_rgb, b_rgb;
logic tile_type;
logic [1:0] rst_sync = 2'b11;



always_ff @(posedge clk) begin
    rst_sync <= {rst_sync[0], (~locked | btn_rst)};   // use ~btn_rst if the button is active-low
end

assign rst = rst_sync[1];

vga_pll clk_main (
    .clock_in(clock_12m), //input
    .clock_out(clk),     //outputs
    .locked(locked)
);

VGA_Signals vga_main (
    .rst(rst),
    .clk(clk),          //input
    .X_SYNC(X_SYNC),    //outputs
    .Y_SYNC(Y_SYNC),
    .de(de),
    .frame_tick(frame_tick),
    .X_COUNT(X_COUNT),
    .Y_COUNT(Y_COUNT)
);

mario_physics#(.Y_MAX(10'd416)) physics_main (
    .clk(clk),
    .rst(rst),
    .frame_tick(frame_tick),
    .btn_left(btn_left),
    .btn_right(btn_right),
    .btn_up(btn_up),

    .mario_x(mario_x),
    .mario_y(mario_y)
);


//-----------------Sprite Fun---------------------

background background_main (
    .b_rgb(b_rgb)
);

mario_sprite mario_main (
    .pos_x(X_COUNT),
    .pos_y(Y_COUNT),
    .mario_x(mario_x),
    .mario_y(mario_y),

    .color(m_rgb)
);

tilemap tilemap_main (
    .pos_x(X_COUNT),
    .pos_y(Y_COUNT),
    .map_array(LEVEL_1),

    .tile_type(tile_type)
);

tile_sprite tile_sprite_main(

    .pos_x(X_COUNT),
    .pos_y(Y_COUNT),
    .tile_type(tile_type),
    .color(o_rgb)


);

color_mux mux_main (

    .clk(clk),
    .de(de),
    .X_SYNC(X_SYNC),
    .Y_SYNC(Y_SYNC),
    .rst(rst),
    .m_rgb(m_rgb),
    .o_rgb(o_rgb),
    .b_rgb(b_rgb),

    .f_rgb(color_out),
    .X_SYNC_OUT(X_SYNC_OUT),
    .Y_SYNC_OUT(Y_SYNC_OUT)
);




endmodule

`default_nettype wire
