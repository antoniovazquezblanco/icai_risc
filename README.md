ICAI-RiSC
=========

VHDL description of a microprocessor for educational purposes.


Building
--------

In order to sintetyze the hardware just `make`. You will need to have Quartus II installed in order to use the Makefile. If you prefer to use any other tool just copy the `.src.vhd` files with the VHDL code.

In order to run the tests type `make test` and modelsim will run the testbenches in the `.tst.vhd` files.

If you want to program the DE1 development board directly you can type `make program` and the code will be downloaded to the board after being sintetyzed.
