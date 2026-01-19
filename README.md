# Nand2Tetris Hack Computer on Cyclone V FPGA

A full Verilog implementation of the Hack Computer architecture from the Nand2Tetris course (The Elements of Computing Systems), running on the Terasic Cyclone V GX Starter Kit.

This project ports the theoretical Hack CPU, RAM, and ROM into physical hardware, bridging the gap between software simulation and FPGA logic.

## Features

*   **Hack CPU Core**: 16-bit processor running at 10 MHz.
*   **Memory**: 32K Instruction ROM (M10K blocks) + 16K Data RAM.
*   **I/O Mapping**:
    *   **TODO** **Keyboard**: Mapped to UART RX (0x6000). Type in a PC terminal to send keys to the Hack OS.
    *   **Debug Dashboard**:
        *   **HEX3-0**: Displays Program Counter (PC) and current Instruction.
        *   **LEDR**: Real-time visualization of the Address Bus.
        *   **SW[0]**: Toggle for manual Single-Step clocking.

## Hardware Used

*   **Board**: Terasic Cyclone V GX Starter Kit (C5GX)
*   **FPGA**: Altera (Intel) Cyclone V 5CGXFC5C6F27C7
*   **Toolchain**: Quartus Prime Lite Edition (v25.1 or compatible)

## Quick Start

### 1. Prerequisites
*   Quartus Prime Lite
*   Python 3 (for ROM conversion tools)
*   USB-Blaster drivers installed

### 2. Build and Run
This project uses a standard Makefile workflow wrapping the Quartus CLI.

1. Assemble your HaCK! code and copy/link the resulting machine code into [rom.hack](./tools/test_io.hack)

2. Compile the Bitstream (Synthesis & Routing):
   make

3. Program the FPGA:
   make upload

### 3. Simulation
To verify logic before hardware deployment:

# Runs the testbench in ModelSim/Questa
make sim

## References

*   **Nand2Tetris**: The original course by Noam Nisan and Shimon Schocken.
*   **Terasic**: Manufacturer of the Cyclone V GX Starter Kit.
*   **Altera/Intel**: FPGA architecture documentation.
*   **Michael Schröder**: Thanks to Micha for the email support - see [nand2tetris-fpga](https://gitlab.com/x653/nand2tetris-fpga/
)
