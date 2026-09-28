module VGA_Signals
#(parameter int X_BITS = 10,
  parameter int Y_BITS = 10 )
(
    input logic clk,rst,
    output logic X_SYNC, Y_SYNC, de, frame_tick,
    output logic [X_BITS - 1:0] X_COUNT,
    output logic [Y_BITS - 1:0] Y_COUNT
);

localparam int X_DISP       = 640; //Visible Area Pixel Count
localparam int X_FP         = 16;  //X Front Porch
localparam int X_SYNC_PULSE = 96;  //X Sync Pulse of timing
localparam int X_BP         = 48;  //X Back Porch
localparam int X_TOTAL      = 800; //Total Pixel Count

localparam int Y_DISP       = 480; //Visible Area Pixel Count
localparam int Y_FP         = 10;  //Y Front Porch
localparam int Y_SYNC_PULSE = 2;   //Y Sync Pulse of timing
localparam int Y_BP         = 33;  //Y Back Porch
localparam int Y_TOTAL      = 525; //Total Pixel Count




always_comb begin
    frame_tick = (X_COUNT == 0) && (Y_COUNT == 480);

    if(X_COUNT >= (X_DISP + X_FP) && X_COUNT < (X_TOTAL - X_BP)) begin
        X_SYNC = 0;
    end
    else begin
        X_SYNC = 1;
    end

    if(Y_COUNT >= (Y_DISP + Y_FP) && Y_COUNT < (Y_TOTAL - Y_BP)) begin
        Y_SYNC = 0;
    end
    else begin
        Y_SYNC = 1;
    end

    de = (X_COUNT < X_DISP) && (Y_COUNT < Y_DISP);


end

always_ff @(posedge clk) begin

    if (rst) begin
        X_COUNT <= 0;
        Y_COUNT <= 0;
    end

    else begin

        if (X_COUNT == X_TOTAL - 1) begin
            X_COUNT <= 0;

            if (Y_COUNT == Y_TOTAL - 1) begin
                Y_COUNT <= 0;
            end

            else begin
                Y_COUNT <= Y_COUNT + 1;
            end
            
        end
        else begin
            X_COUNT <= X_COUNT + 1;
        end
    end
end

endmodule