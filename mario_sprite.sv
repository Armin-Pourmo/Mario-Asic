module mario_sprite #() (
    input logic [9:0] pos_x,
    input logic [9:0] pos_y,
    input logic [9:0] mario_x,
    input logic [9:0] mario_y,
    output logic [11:0] color
);
logic in_mario_box;
assign in_mario_box = (pos_x >= mario_x) && (pos_x < mario_x + 10'd32) && (pos_y >= mario_y) && (pos_y < mario_y + 10'd32); // checks if the pixel is within mario's box

logic [4:0] local_x;
logic [4:0] local_y;
assign local_x = pos_x - mario_x; // the x value within mario's sprite
assign local_y = pos_y - mario_y; // the y value within mario's sprite

logic [9:0] address;
assign address = (local_y[4:1] * 16) + local_x[4:1]; // slices the first three bits to scale the 16x16 sprite to the 32x32 area

always_comb begin
    if (in_mario_box) begin
        case (address)
            default: color = 12'hF00; // paints a red color in all pixels in mario's area for the trial run
        endcase
    end else begin
        color = 12'hF0F; // transparent outside mario's box
    end
end

endmodule