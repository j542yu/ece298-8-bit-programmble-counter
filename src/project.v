/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ece298a_task_1 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Want uio_oe[1:0] to be input so set to 0
  // Remaining bits also set to 0 because unused so don't care
  assign uio_oe  = 0; 

  assign uio_out = 0; // Unused so assign 0

  eight_bit_counter eight_bit_counter_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(uio_in[0]),
    .load(uio_in[1]),
    .data(ui_in),
    .value_buf(uo_out)
  );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule
