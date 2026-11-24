# IC Design Laboratory (EE4292)

Homework and term project for **EE4292 IC Design Laboratory** (積體電路設計實驗) at National Tsing Hua University, Fall 2024. Each homework is a Verilog design that is simulated, linted (SpyGlass), and synthesized (Design Compiler). Designs are ranked by a performance index (PI) built from area, cycle time, and cycle count.

| Folder | Design | Highlights |
|---|---|---|
| [`HW1-ROP3`](HW1-ROP3) | **ROP3 raster-operation engine**: computes any of the 256 three-operand bitwise operations | Three implementations compared: 16-entry LUT, 256-entry LUT, and a "smart" Boolean-formula version. Self-checking testbenches compare the LUT and formula versions |
| [`HW2-Enigma`](HW2-Enigma) | **Enigma cipher machine** in hardware | Built up in four parts: rotor A and reflector, a switchable box, a plugboard, and a second rotor B. Each part comes with its own testbench and behavioral model |
| [`HW3-Pipelining`](HW3-Pipelining) | Pipelining and PPA trade-offs | Pipelined versions of ROP3 (LUT-256 vs. smart formula) and of the Enigma machine. The `performance_*.txt` files record the area, power, and timing comparison |
| [`HW4-QR-Code-Decoder`](HW4-QR-Code-Decoder) | **QR code decoder** that reads an image from SRAM | Locates the QR code (`find_qrcode`), removes the mask (`de_mask`), and decodes the data (`decode`) under a control FSM. Passed all pattern ranks (A–D). PI = A·T·C² = 8.49 × 10¹⁴ |
| [`Final-ECDSA`](Final-ECDSA) | **ECDSA signature engine on secp256k1** (term project, two-person team) | SHA-256, elliptic-curve scalar multiplication, and signing, over an AXI-Stream interface, with side-channel resistance. Taken through place-and-route (`ECDSA_layout*.png`); see `report.pdf` |

### Selected results

| Design | Area (µm²) | Cycle time (ns) | Notes |
|---|---|---|---|
| ROP3, LUT-256 (pipelined) | 6,339 | 1.8 | Power 0.47 |
| ROP3, smart formula (pipelined) | 3,621 | 1.7 | Power 0.40 |
| Enigma (pipelined) | 16,982 | 3.35 | PI = 56,890 |
| QR code decoder | 3,845 | 4.0 | 234,897 cycles for rank-A patterns |

The power column uses the units of the Design Compiler report.

## Notes

- The ECDSA RTL is kept in my teammate's repository. This repo holds the report and layout.
- Gate-level netlists, SDF files, synthesis reports, homework specs, lecture slides, and course-provided SRAM models and patterns are not included.
- HW5 (a CNN accelerator) is not included.

## Tools

- Verilog
- Synopsys VCS
- SpyGlass (lint)
- Synopsys Design Compiler
- Place-and-route (APR)

## Author

Yu-Shuo Chang (張育碩), Department of Electrical Engineering, NTHU
