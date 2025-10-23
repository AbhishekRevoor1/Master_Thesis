# 🧠 A Complete Tool-chain for RWU RV64I Processor - Master Thesis  
### *A Complete RISC-V Toolchain and Verification Framework for the RWU-RV64I Core*

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()
[![Toolchain](https://img.shields.io/badge/toolchain-RISCV64--ELF-blue.svg)]()
[![License](https://img.shields.io/badge/license-Academic-lightgrey.svg)]()
[![Platform](https://img.shields.io/badge/platform-Zybo--Zynq--7000-orange.svg)]()

---

## 📘 Overview

This repository contains the **Master’s Thesis project** of **Abhishek Revoor**, conducted at  
**Ravensburg-Weingarten University of Applied Sciences (RWU)** under the supervision of  
**Prof. Soggelkow** and **Prof. Pfeil**.  

The thesis implements a **complete bare-metal toolchain**, **linker/startup setup**, and **simulation environment** for the custom **RWU-RV64I RISC-V processor core**.  
The project integrates compilation, simulation, and FPGA deployment, enabling **end-to-end testing of RISC-V instructions** using GPIO-based feedback and waveform verification.

---

## 🚀 Project Goals

- Develop a **standalone cross-compilation toolchain** for RV64I architecture.  
- Implement a **linker script** and **startup code (crt0.s)** for bare-metal applications.  
- Verify correct instruction execution via **GPIO-based testbench output**.  
- Measure **code size and behavior** across GCC optimization levels.  
- Demonstrate hardware execution on **Zybo Zynq-7000 FPGA**.

---

## 🧩 Key Features

- 🧰 **Custom RISC-V GCC Toolchain Integration**  
  Configured `riscv64-unknown-elf-gcc` for RV64I ISA with `-march=rv64i`.

- ⚙️ **CMake / Makefile Build System**  
  Flexible compilation setup for both simulation and FPGA builds.

- 🧱 **Startup and Linker Implementation**  
  Includes `crt0.s`, `link.ld`, and interrupt stubs for a freestanding environment.

- 🔍 **GPIO Execution Markers**  
  Each instruction’s completion is verified using GPIO toggles in simulation.

- 🧪 **Comprehensive Instruction Tests**  
  Test suites for arithmetic, logical, memory, and branch instructions.

- 🔧 **FPGA Synthesis on Zybo Zynq 7000**  
  Verified the custom RISC-V softcore on actual hardware.

---

## 🏗️ Repository Structure
  ├── C_compile/ # ToolChain source files (startup, linker, headers, make).\
  ├── C_Files/ # Test programs in C.\
  ├── ECLIPSE/ # Project carried out in Eclipse.\
  ├── ip_jtag/ # Processor JTAG Core source files.\
  ├── ip_uart/ # Processor Core UART source files.\
  ├── Report/ # Thesis report, images, and related documents.\
  ├── rv64Sim/ # Minimal toolchain for Assembly Language.\
  ├── sim/ # Simulation scripts(XSIM).\
  ├── spec/ # Processor core related documents.\
  ├── src/ # RWU RV64I processor core files(*.sv).\
  ├── syn/ # Files related to Vivado.\
  ├── tb/ # Testbench's for XSIM simulation.\
  ├── Vivado/ # Xilinx Vivado Projects.\
  └── README.md # Project overview (this file)


---

## 🧰 Toolchain Setup

To build and simulate locally:

```bash
# Clone the repository
git clone https://github.com/AbhishekRevoor1/Master_Thesis.git
cd Master_Thesis

# Set up RISC-V GCC path
export PATH=$PATH:/opt/riscv/bin

# Build all test programs
make

# Run simulation
make run-sim

```

---

✅ Requirements

- riscv64-unknown-elf-gcc

- make or cmake

- Eclipse C/C++ IDE

- Xilinx XSIM

- Xilinx Vivado Webpack

---

🧬 Example Test: GPIO Output Trace

Example test program (test_simple_gpio.c):

```bash
#include "rwu-rv64i.h"
#include <stdint.h>

static inline void gout(uint8_t v) { rwu_print(v); }

int main(void) {
    gout(1);  // start marker
    uint32_t a = 10, b = 5;
    uint32_t c = a + b;  // ADD
    gout(2);
    uint32_t d = c - 2;  // SUB
    gout(3);
    return 0;
}
```
💡 Each gout() call toggles a GPIO output visible in simulation logs or waveform, confirming instruction flow and correctness.

---

🧩 FPGA Integration

The validated binaries can be executed on the Zybo Zynq 7000 FPGA board.
The RWU-RV64I core is instantiated and programmed using Xilinx Vivado, enabling real hardware evaluation of instruction behavior.

---

📚 Documentation

All results, experiments, and analysis are documented in the thesis report:
📄 doc/Thesis_Report.pdf

---

🧑‍💻 Author

Abhishek Revoor\
M.Sc. Embedded Systems Engineering\
Ravensburg-Weingarten University of Applied Sciences\
🔗 LinkedIn: https://www.linkedin.com/in/abhishek-revoor/ \
🔗 GitHub: https://github.com/AbhishekRevoor1

---

 🏁 Acknowledgements

Special thanks to:

Prof. Soggelkow — Supervisor and academic advisor

Prof. Pfeil — Co-examiner and reviewer

---
📜 License

This repository is provided for academic and educational purposes.
© 2025 Abhishek Revoor. All rights reserved.

---

🌟 Star This Repo

If you found this work helpful or inspiring, please ⭐ the repository — it helps others discover it!


