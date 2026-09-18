/*
 * Copyright (c) 2026 Judy Yu
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ece298a_8_bit_counter (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  /*
    To allow for tri-state output, must use the bidirectional
    uio_out as output so that uio_oe = 0 which disables output,
    resulting in high impedance

    Since also need count enable, tri-state enable, and load signals
    as inputs, cannot use ui_in for 8-bit counter load thus data to load
    in will be shared on the bidirectional pins on uio_in[7:0]

    Assignments:
    ui_in[0] = enable_count
    ui_in[1] = enable_output
      - 1 for outputting counter value on uio_out
      - 0 for high Z output on uio_out
    ui_in[2] = load
      - 1 for loading in data on uio_in (also requires enable_output = 0)

    uio_in[7:0] = data_to_load
    uio_out[7:0] = counter - tri-state counter output

    clk, rst_n used as is
   */

  wire enable_count = ui_in[0];
  wire enable_output = ui_in[1];
  wire load = ui_in[2];

  wire[7:0] data_to_load = uio_in[7:0];

  // Want counter to retain value over clock cycles
  // since enable_count might not always be high
  // so use reg instead of wire
  reg[7:0] counter;
  assign uio_out[7:0] = counter;

  // IOs: Enable path (active high: 0=input, 1=output)
  // Using all 8 bits
  assign uio_oe[7:0] = enable_output ? 8'hFF : '0;

  always @(posedge clk or negedge rst_n) begin
      // Asynchronous reset
      if (!rst_n) begin
          counter <= '0;
      end else begin
        // If !rst_n is not true, then this must be at
        // posedge clk so remaining logic is synchronous

        // Can only load when enable_output is low because
        // otherwise IOs are set to output
        if (load && !enable_output) begin
          counter <= data_to_load;
        end else if (enable_count) begin
          counter <= counter + 1;
        end
      end
  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
