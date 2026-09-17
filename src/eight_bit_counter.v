/*
    ECE298A Task 1:
    8-bit programmable binary counter with asynchronous reset,
    synchronous load, and tri-state output
*/

`default_nettype none

module eight_bit_counter (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire load,

    input wire[7:0] data,

    // Value of counter after tri-state buffer
    // (high impedance when enable low)
    output reg[7:0] value_buf
);

    reg [7:0] value;

    always @(posedge clk or negedge rst_n) begin
        // Asynchronous reset
        if (!rst_n) begin
            value <= '0;
            value_buf <= '0;
        end

        // If !rst_n is not true, then this must be at
        // posedge clk so remaining logic is synchronous
        else if (load) begin
            value <= data;
        end else begin
            value <= value + 1;
        end
    end

    // Tri-state output
    assign value_buf = enable ? value : 'Z;

endmodule