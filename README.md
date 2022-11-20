playground for verilog on a papilio one 500 with a logicstart megawing

useful links:
* papilio quickstart: http://www.papilio.cc/index.php?n=Papilio.QuickStartGuide
* papilio loader: https://forum.gadgetfactory.net/files/file/10-papilio-loader-gui/
* board overview: https://store.gadgetfactory.net/papilio-one-500k-spartan-3e-fpga-dev-board/
* logicstart megawing overview: http://papilio.cc/index.php?n=Papilio.LogicStartMegaWing
* hamster's fpga intro: https://github.com/hamsternz/IntroToSpartanFPGABook/blob/master/IntroToSpartanFPGABook.pdf?raw=true
* verilog tutorial: https://www.chipverify.com/verilog/verilog-tutorial
* verilog tutorial: https://www.javatpoint.com/verilog

setup notes:
* xilinx ise is a redhat enterprise VM that installs into virtualbox
    * NOTE: virtualbox doesn't work on Win10 if Hyper-V / WSL2 are enabled
    * check those things are off in "Turn Windows Features On or Off"
    * might also need `bcdedit / set hypervisorlaunchtype off` from an admin cmd.exe
* i couldn't get the papilio loader to work within that VM, so i had to disable the three Xilinx USB Cable options within the VM USB device options and then use it from windows

flash to SPI -- writing to FPGA didn't seem to work
### after flashing to SPI, power-cycle the board for it to use the new flash! ###

