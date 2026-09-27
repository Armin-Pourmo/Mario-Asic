module tilemap #(
    parameter MAP_COLS = 20,
    parameter MAP_ROWS = 15
) (
    input logic [9:0] pos_x,
    input logic [9:0] pos_y,
    input logic [(MAP_COLS * MAP_ROWS)-1:0] map_array,
    output logic tile_type 
);

logic [4:0] tile_x;
logic [4:0] tile_y;
assign tile_x = pos_x / 32;
assign tile_y = pos_y / 32;

logic [9:0] tile_idx;
assign tile_idx = ((MAP_ROWS - 1 - tile_y) * MAP_COLS) + tile_x; 

assign tile_type = map_array[tile_idx];

endmodule