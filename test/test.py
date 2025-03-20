# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start Traffic Light Controller Test")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Reset complete, starting test")

    # Initial State Check (RST)
    await ClockCycles(dut.clk, 5)
    assert dut.uo_out.value == 0b01010101, "Initial state after reset is incorrect"


    # Move to S0: North Green, Others Red
    await ClockCycles(dut.clk, 50_000)  # Wait 5 seconds for S0 to complete
    assert dut.uo_out.value == 8'b10000000, "S0: North Green not set correctly"

    # Move to S1: North Yellow, Others Red
    await ClockCycles(dut.clk, 10_000)  # Wait 1 second for S1 to complete
    assert dut.uo_out.value == 8'b01000000, "S1: North Yellow not set correctly"

    # Move to S2: East Green, Others Red
    await ClockCycles(dut.clk, 50_000)
    assert dut.uo_out.value == 8'b00100000, "S2: East Green not set correctly"

    # Move to S3: East Yellow, Others Red
    await ClockCycles(dut.clk, 10_000)
    assert dut.uo_out.value == 8'b00010000, "S3: East Yellow not set correctly"

    # Move to S4: South Green, Others Red
    await ClockCycles(dut.clk, 50_000)
    assert dut.uo_out.value == 8'b00001000, "S4: South Green not set correctly"

    # Move to S5: South Yellow, Others Red
    await ClockCycles(dut.clk, 10_000)
    assert dut.uo_out.value == 8'b00000100, "S5: South Yellow not set correctly"

    # Move to S6: West Green, Others Red
    await ClockCycles(dut.clk, 50_000)
    assert dut.uo_out.value == 8'b00000010, "S6: West Green not set correctly"

    # Move to S7: West Yellow, Others Red
    await ClockCycles(dut.clk, 10_000)
    assert dut.uo_out.value == 8'b00000001, "S7: West Yellow not set correctly"

    dut._log.info("Traffic Light Test Completed Successfully")

