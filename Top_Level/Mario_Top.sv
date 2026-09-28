`default_nettype none
module Mario_Top (
    input logic clock_12m,
    output logic X_SYNC_OUT, Y_SYNC_OUT, 
    output logic[11:0] color_out
);

logic clk, rst, locked; //clock signals
logic X_SYNC, Y_SYNC, de, frame_tick; //VGA signals
logic[9:0] X_COUNT, Y_COUNT;

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
    .clk(clk),          //input
    .X_SYNC(X_SYNC),    //outputs
    .Y_SYNC(Y_SYNC),
    .de(de),
    .frame_tick(frame_tick)
);





endmodule