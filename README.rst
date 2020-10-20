sca-ip : SCABox IP repository
***************************************************************

Overview
===============================================================

This repository contains IPs related to side-channel analysis used in the SCABox project

- Cores : cryptographic accelerators
- Sensors : power sensors
- Acquisition : synchronous sensors monitoring

Each IP in this repository is provided with all the interface needed to be reusable in any
Vivado block design 

- RTL designs
- AXI4-Lite interface
- IP custom GUI
- Embedded drivers

The IPs have been tested on the Zybo-Z7010 board but are meant to work on any Xilinx board
expect for the power sensors. The targeted frequency is 200MHz.

Usage
===============================================================

Our IP can be integrated to any Vivado block design as you can do why already existing IPs.
To integrate an IP just add the directory containing the IP to your IP repositories.
The IPs also provide various customization parameters that can be changed when adding the IP.

More
===============================================================

SCABox is a project on the topic of side-channel analysis.
The goal of SCABox is to provide a cheap and efficient test-bench for side-channel analysis.

To know more about SCABox please visit our website, it provides a full documentation on the project
and a introduction about side-channel analysis.
