# Cyclone V (CV) Golden Hardware Reference Design (GHRD)

The GHRD is part of the Golden System Reference Design (GSRD), which provides a complete solution, including exercising soft IP in the fabric, booting to U-Boot, then Linux, and running sample Linux applications.

## Build Steps
1) Customize the GHRD settings in Makefile. Only necessary when the defaults are not suitable.
2) Generate the Quartus Project and source files.
   - Use target from [Supported Designs](#supported-designs)
3) Compile Quartus Project and generate the configuration file
   - $ `make sof` or $ `make all`

## Supported Designs
### Baseline
```bash
make generate-cyclonev-soc-devkit-baseline
```

## GHRD Overview

### Hard Processor System (HPS)
The GHRD HPS configuration matches the board schematic. Refer to [Cyclone V Hard Processor System Technical Reference Manual](https://www.intel.com/content/www/us/en/docs/programmable/683126/current) for more information on HPS configuration.

### HPS External Memory Interfaces (EMIF)
The GHRD HPS EMIF configuration matches the board schematic. Refer to
[External Memory Interfaces in Cyclone V Devices](https://www.intel.com/content/www/us/en/docs/programmable/683375/current/external-memory-interfaces-in-devices-81117.html)
for more information on HPS EMIF configuration.

### HPS-to-FPGA Address Map
The memory map of soft IP peripherals, as viewed by the microprocessor unit (MPU) of the HPS, starts at HPS-to-FPGA base address of 0xC000_0000.

Refer to [Cyclone V HPS Register Address Map and Definitions](https://www.intel.com/content/www/us/en/programmable/hps/cyclone-v/hps.html) for details.

| Peripheral | Address Offset | Size (bytes) | Attribute |
| :-- | :-- | :-- | :-- |
| onchip_memory2_0 | 0x0 | 64K | On-chip RAM as scratch pad |

### System peripherals
The memory map of system peripherals in the FPGA portion of the SoC as viewed by the MPU, which starts at the lightweight HPS-to-FPGA base address of 0xFF20_0000, is listed in the following table.

Note: All interrupt sources are also connected to an interrupt latency counter (ILC) module in the system, which enables System Console to be aware of the interrupt status of each peripheral in the FPGA portion of the SoC.

#### Lightweight HPS-to-FPGA Address Map for all designs
| Peripheral | Address Offset | Size (bytes) | Attribute | Interrupt Num |
| :-- | :-- | :-- | :-- | :-- |
| jtag_uart | 0x0006_0000 | 8 | JTAG Uart | 2 |
| sysid | 0x0000_0008 | 8 | Unique system ID   | None |
| led_pio | 0x0006_0040 | 32 | 4 x LED outputs   | None |
| button_pio | 0x0006_00C0 | 16 | 2 x Push button inputs | 1 |
| dipsw_pio | 0x0006_0080 | 16 | 4 x DIP switch inputs | 0 |
| ILC | 0x0007_0000 | 256 | Interrupt latency counter | None |

### JTAG master interfaces
The GHRD JTAG master interfaces allows you to access peripherals in the FPGA with System Console, through the JTAG master module. This access does not rely on HPS software drivers.

Refer to this [Guide](https://www.intel.com/content/www/us/en/docs/programmable/683819/current/analyzing-and-debugging-designs-with-84752.html) for information about system console.

## Binaries location
After build, the design files (sof and rbf) can be found in output_files folder.
