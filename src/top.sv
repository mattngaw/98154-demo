typedef enum logic [1:0] {ADD, SUB, OR, EQ} Op;

module calculator_chip (
    output logic [7:0] NumOut,
    input logic [7:0] NumIn,
    input logic [1:0] OpIn,
    input logic Enter,
    input logic Reset,

    input logic clock
);

    logic [7:0] state;
    logic [7:0] nextState;
    logic       EnterOld;
    
    assign NumOut = state;

    always_comb begin
        case (OpIn)
            ADD : nextState = state + NumIn;
            SUB : nextState = state - NumIn;
            OR  : nextState = state | NumIn;
            EQ  : nextState = (state == NumIn) ? 8'd1 : 8'd0; 
        endcase
    end

    // async reset
    always_ff @(posedge clock, posedge Reset) begin
        if (Reset) begin
            state <= 8'd0;
        end
        else if (Enter && !EnterOld) begin
            state <= nextState;
        end
        EnterOld <= Enter;
    end

endmodule

module tt_um_calculator (
    input  logic [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output logic [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  logic [7:0] uio_in,   // IOs: Bidirectional Input path
    output logic [7:0] uio_out,  // IOs: Bidirectional Output path
    output logic [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  logic       ena,      // will go high when the design is enabled
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);

    assign uio_oe[2:0] = 3'b111;

    calculator_chip calc (
        .NumOut(uo_out),
        .NumIn(ui_in),
        .OpIn(uio_in[1:0]),
        .Enter(uio_in[2]),
        .Reset(!rst_n),
        .clock(clk)
    );

endmodule : tt_um_calculator
