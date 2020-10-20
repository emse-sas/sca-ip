SCABox IPs
***************************************************************

Overview
===============================================================

This repository contains FPGA IPs related to side-channel analysis and used in the `SCABox <https://samibendou.github.io/sca_framework/>`_ project

- Cores : cryptographic accelerators
- Sensors : electrical power sensors
- Acquisition : synchronous sensors monitoring

Each IP in this repository is provided with all the interface needed to be reusable in any
Vivado block design 

- RTL designs
- AXI4-Lite interface
- IP customization GUI
- Embedded drivers

The IPs have been tested on the Zybo-Z7010 board but are meant to work on any Xilinx board
except for the power sensors. The targeted frequency is 200MHz on the Z7.


Install
===============================================================

To install the repository you must first clone the sources from GitHub

.. code-block:: shell

    $ git clone https://github.com/samiBendou/sca-ip

Then, launch Vivado and add each IP you need into your IP repositories.

Usage
===============================================================

Our IPs can be integrated to any Vivado block design as you can do with already existing IP blocks.
To integrate an IP just add the directory containing the IP to your IP repositories.
Use the customization GUI to change the parameters of each IP.

Documentation
===============================================================

The complete documentation of the IP repo is available `here <https://samibendou.github.io/sca-ip/>`_.
The project contains both hardware and software parts, 
therefore this documentation is split into two different websites.

Drivers
---------------------------------------------------------------

The documentation for the C drivers of the IPs can be found `here <../c/html/index.html>`_

Hardware
---------------------------------------------------------------

The documentation of the IPs RTL can be found `here <../hdl/html/index.html>`_

Build
---------------------------------------------------------------

You can generate the documentation of this repository from the sources using Doxygen and sphinx.
To do so, input the following commands from the root of the project :

.. code-block:: shell

    $ cd docs
    $ doxygen Doxyfile_c
    $ doxygen Doxyfile_vhd
    $ make html


More
===============================================================

SCABox is a project on the topic of side-channel analysis.
The goal of SCABox is to provide a cheap and efficient test-bench for side-channel analysis.

To know more about SCABox please visit our `website <https://samibendou.github.io/sca_framework/>`_.
It provides a full documentation of project and a wiki about side-channel analysis.

- `IP repository <https://github.com/samiBendou/sca-ip/>`_
- `Acquisition demo <https://github.com/samiBendou/sca-demo-tdc-aes/>`_
- `Attack demo <https://github.com/samiBendou/sca-automation/>`_