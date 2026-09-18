<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
Task 1 for ECE298A

8 bit programmable binary counter with asynch reset, synchronous load, and tri-state output.

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

## How to test

Simulated tests: make sure you're in the test/ directory, then run `make -B` in the terminal

## External hardware

N/A