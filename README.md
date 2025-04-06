# Cyclone V (CV) Golden Hardware Reference Design (GHRD)

The GHRD is part of the Golden System Reference Design (GSRD), which provides a complete solution, including exercising soft IP in the fabric, booting to U-Boot, then Linux, and running sample Linux applications.

Refer to the [Cyclone V SoC GSRD](https://www.rocketboards.org/foswiki/Documentation/CycloneVSoCGSRD) for information about GSRD.

This reference design demonstrating the following system integration between Hard Processor System (HPS) and FPGA IPs:
## Baseline feature
This is applicable to all designs.
- Hard Processor System enablement and configuration
  - HPS Peripheral and I/O (eg, NAND, SD/MMC, EMAC, USB, SPI, I2C, UART, and GPIO)
  - HPS Clock and Reset
  - HPS FPGA Bridge and Interrupt
- HPS EMIF configuration
- System integration with FPGA IPs
  - SYSID
  - Programmable I/O (PIO) IP for controlling DIPSW, PushButton, and LEDs)
  - FPGA On-Chip Memory

## Dependency
* Altera Quartus Prime 24.1std
* Supported Board
  - Intel Cyclone V SoC Development Kit

## Tested Platform for the GHRD Make flow
* SUSE Linux Enterprise Server 12 SP5

## Supported Designs
### Baseline
This design boots from SD/MMC.
```bash
make cyclonev-soc-devkit-baseline-all
```

## Install location
After build, the design files (zip, sof and rbf) can be found in install/designs folder.
