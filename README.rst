sca-ip
***************************************************************

Overview
===============================================================

This repository contains IPs for the SCABox project :

- Cores : cryptographic accelerators
- Sensors : power sensors
- Acquisition : synchronous sensors monitoring

Each IP in this repository contains the following :

- RTL designs
- AXI4-Lite interface
- Embedded drivers

The IPs have been tested on the Zybo-Z7010 board but are meant to work on any Xilinx board
expect for the power sensors. The targeted frequency is 200MHz.

Usage
===============================================================

Our IP can be integrated to any Vivado block design as you can do why already existing IPs.
The IPs also provide various customization parameters that can be changed when adding the IP.

More
===============================================================

SCABox is a project on the topic of side-channel analysis.
The goal of SCABox is to provide a cheap and efficient test-bench for side-channel analysis.

To know more about SCABox please visit our website, it provides a full documentation on the project
and a introduction about side-channel analysis.
