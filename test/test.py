# SPDX-FileCopyrightText: © 2026 Judy Yu
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_counter(dut):
    # Project always enabled whenever powered
    dut.ena.value = 1

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    await test_reset(dut)
    await test_tristate_output(dut)
    await test_count_increment(dut, num_counts=17) # Arbitrary num_counts value
    await test_load(dut, value_to_load=89) # Arbitrary value_to_load

async def test_reset(dut):
    dut._log.info("Testing reset")

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=0,
                                   load=0)
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=1,
                                   load=0)

    assert int(dut.uio_out.value) == 0, f"Expected counter value == 0 after reset, instead got {int(dut.uio_out)}"
    
async def test_count_increment(dut, num_counts):
    dut._log.info("Testing counter increments when enable_count enabled")

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=1,
                                   load=0)
    await ClockCycles(dut.clk, 1)

    initial_value = int(dut.uio_out.value)

    dut.ui_in.value = format_ui_in(enable_count=1,
                                   enable_output=1,
                                   load=0)

    # One clock cycle for enable_count to update
    await ClockCycles(dut.clk, 1)

    await ClockCycles(dut.clk, num_counts)

    assert int(dut.uio_out.value) == initial_value + num_counts, \
        f"Expected counter value to increment by {num_counts}, instead incremented by {int(dut.uio_out.value) - initial_value}"

    # -------------------------------------------------------------------- #

    dut._log.info("Testing counter holds value when enable_count disabled")

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=1,
                                   load=0)
    # One clock cycle for enable_count to update
    await ClockCycles(dut.clk, 1)

    hold_value = int(dut.uio_out.value)
    
    await ClockCycles(dut.clk, 10)

    assert int(dut.uio_out.value) == hold_value, \
        f"Expected counter value to stay constant but instead changed from {hold_value} to {int(dut.uio_out.value)}"

async def test_tristate_output(dut):
    dut._log.info("Testing disabled output")

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=0,
                                   load=0)
    await ClockCycles(dut.clk, 1)
    assert int(dut.uio_oe.value) == 0, f"Expected disabled output"

    # -------------------------------------------------------------------- #

    dut._log.info("Testing enabled output")

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=1,
                                   load=0)
    await ClockCycles(dut.clk, 1)
    assert int(dut.uio_oe.value) == 0xFF, f"Expected enabled output"

async def test_load(dut, value_to_load):
    dut._log.info("Testing load when output disabled")

    initial_value = int(dut.uio_out.value)

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=0,
                                   load=1)

    dut.uio_in.value = value_to_load
    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=1,
                                   load=0)

    # Need to then enable output so we can check value
    await ClockCycles(dut.clk, 1)

    assert int(dut.uio_out.value) == value_to_load, \
        f"Expected counter value to be {value_to_load}, \
        instead got {int(dut.uio_out.value)}. For reference, initial value was {initial_value}"

    # -------------------------------------------------------------------- #
    
    dut._log.info("Testing load when output enabled")

    initial_value = int(dut.uio_out.value)

    dut.ui_in.value = format_ui_in(enable_count=0,
                                   enable_output=1,
                                   load=1)

    dut.uio_in.value = value_to_load
    
    await ClockCycles(dut.clk, 1)
    assert int(dut.uio_out.value) == initial_value, \
        f"Expected counter value to not change ({initial_value}), \
        instead got {int(dut.uio_out.value)}. For reference, load value was {value_to_load}"
    
def format_ui_in(enable_count, enable_output, load):
    return (load << 2) | (enable_output << 1) | enable_count