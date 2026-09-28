module background (
    output logic[11:0] b_rgb
);

localparam logic[11:0] SKY_BLUE = 12'h5AF;

assign b_rgb = SKY_BLUE;


endmodule