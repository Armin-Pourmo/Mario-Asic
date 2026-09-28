module tile_sprite (
    input logic [9:0] pos_x,
    input logic [9:0] pos_y,
    input logic tile_type,
    output logic [11:0] color
);

logic [4:0] local_x;
logic [4:0] local_y;
assign local_x = pos_x[4:0];
assign local_y = pos_y[4:0]; // selecting the first 5 bits has the same effect as a modulo 32 operation for local coordinates

logic [9:0] address;
assign address = (local_y[4:1] * 16) + local_x[4:1]; // selects bits 4:1 to scale 16x16 sprite for 32x32 tiles

always_comb begin
    case (tile_type)
        1'b0: color = 12'hF0F;
        1'b1: color = 12'h000;
        default: color = 12'hF0F;
    endcase
end

endmodule