module color_mux #(
    input logic clk, de, X_SYNC, Y_SYNC,
    input logic[11:0] m_rgb, b_rgb, o_rgb, //mario rgb, background rgb, obstacle rgb
    output logic[11:0] f_rgb,               //final outputted rgb
    output logic X_SYNC_OUT, Y_SYNC_OUT, de_out
);

localparam logic[11:0] MAGENTA = 12'b 1111_0000_1111;
localparam logic[11:0] BLACK = 12'b 0000_0000_0000;

always_ff @( clk ) begin 

    X_SYNC_OUT = X_SYNC;
    Y_SYNC_OUT = Y_SYNC;
    de_out = de;

    if(de & !rst) begin

        if (m_rgb != MAGENTA) begin
            f_rgb = m_rgb;
        end

        else if (o_rgb != MAGENTA) begin
            f_rgb = o_rgb;
        end

        else begin
            f_rgb = b_rgb;
        end

    end

    else begin
        f_rgb = BLACK;
    end

end



endmodule