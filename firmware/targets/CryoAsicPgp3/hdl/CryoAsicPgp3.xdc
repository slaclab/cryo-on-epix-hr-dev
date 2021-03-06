##############################################################################
## This file is part of 'EPIX HR Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'EPIX HR Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################
#######################
## Application Ports ##
#######################
# EVAL BOARD ONLY

#set_property -dict {PACKAGE_PIN H27 IOSTANDARD LVCMOS18} [get_ports userSmaP]
#set_property -dict {PACKAGE_PIN G27 IOSTANDARD LVCMOS18} [get_ports userSmaN]



####################################
## Application Timing Constraints ##
####################################

##########################
## Misc. Configurations ##
##########################
create_generated_clock -name appClk        [get_pins U_App/U_CoreClockGen/MmcmGen.U_Mmcm/CLKOUT0]
create_generated_clock -name idelayCtrlClk [get_pins U_App/U_CoreClockGen/MmcmGen.U_Mmcm/CLKOUT1]
create_generated_clock -name adcClk        [get_pins U_App/U_CoreClockGen/MmcmGen.U_Mmcm/CLKOUT2]
create_generated_clock -name bitClk        [get_pins U_App/U_iserdesClockGen/MmcmGen.U_Mmcm/CLKOUT0]
create_generated_clock -name deserClk      [get_pins U_App/U_iserdesClockGen/MmcmGen.U_Mmcm/CLKOUT1]
create_generated_clock -name byteClk       [get_pins U_App/U_iserdesClockGen/MmcmGen.U_Mmcm/CLKOUT2]
create_generated_clock -name asicRdClk     [get_pins U_App/U_iserdesClockGen/MmcmGen.U_Mmcm/CLKOUT3]

set_clock_groups -asynchronous -group [get_clocks sysClk]  -group [get_clocks appClk]
set_clock_groups -asynchronous -group [get_clocks sysClk]  -group [get_clocks bitClk]
set_clock_groups -asynchronous -group [get_clocks sysClk]  -group [get_clocks byteClk]
set_clock_groups -asynchronous -group [get_clocks sysClk]  -group [get_clocks asicRdClk]
set_clock_groups -asynchronous -group [get_clocks sysClk]  -group [get_clocks adcBitClkR]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks byteClk]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks deserClk]
set_clock_groups -asynchronous -group [get_clocks dnaClk]  -group [get_clocks byteClk]
set_clock_groups -asynchronous -group [get_clocks byteClk] -group [get_clocks deserClk]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks adcBitClkR]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks adcBitClkRD4]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks adcMonDoClkP]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks bitClk]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks asicRdClk]
set_clock_groups -asynchronous -group [get_clocks byteClk] -group [get_clocks adcBitClkR]
set_clock_groups -asynchronous -group [get_clocks byteClk] -group [get_clocks adcBitClkRD4]
set_clock_groups -asynchronous -group [get_clocks appClk]  -group [get_clocks idelayCtrlClk]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/U_Mmcm/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_App/U_CoreClockGen/MmcmGen.U_Mmcm/CLKOUT2]]

# ASIC Gbps Ports

set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVDS} [get_ports {asicDataP[0]}]
set_property -dict {PACKAGE_PIN V21 IOSTANDARD LVDS} [get_ports {asicDataN[0]}]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS18} [get_ports {asicDataP[1]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS18} [get_ports {asicDataN[1]}]
set_property -dict {PACKAGE_PIN R21 IOSTANDARD LVDS} [get_ports {asicDataP[2]}]
set_property -dict {PACKAGE_PIN R22 IOSTANDARD LVDS} [get_ports {asicDataN[2]}]
set_property -dict {PACKAGE_PIN U25 IOSTANDARD LVDS} [get_ports {asicDataP[3]}]
set_property -dict {PACKAGE_PIN U26 IOSTANDARD LVDS} [get_ports {asicDataN[3]}]
set_property -dict {PACKAGE_PIN R27 IOSTANDARD LVCMOS18} [get_ports {asicDataP[4]}]
set_property -dict {PACKAGE_PIN R28 IOSTANDARD LVCMOS18} [get_ports {asicDataN[4]}]
set_property -dict {PACKAGE_PIN T24 IOSTANDARD LVDS} [get_ports {asicDataP[5]}]
set_property -dict {PACKAGE_PIN T25 IOSTANDARD LVDS} [get_ports {asicDataN[5]}]
set_property -dict {PACKAGE_PIN R23 IOSTANDARD LVCMOS18} [get_ports {asicDataP[6]}]
set_property -dict {PACKAGE_PIN P23 IOSTANDARD LVCMOS18} [get_ports {asicDataN[6]}]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS18} [get_ports {asicDataP[7]}]
set_property -dict {PACKAGE_PIN P21 IOSTANDARD LVCMOS18} [get_ports {asicDataN[7]}]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVDS} [get_ports {asicDataP[8]}]
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVDS} [get_ports {asicDataN[8]}]
set_property -dict {PACKAGE_PIN P28 IOSTANDARD LVCMOS18} [get_ports {asicDataP[9]}]
set_property -dict {PACKAGE_PIN N28 IOSTANDARD LVCMOS18} [get_ports {asicDataN[9]}]
set_property -dict {PACKAGE_PIN P25 IOSTANDARD LVCMOS18} [get_ports {asicDataP[10]}]
set_property -dict {PACKAGE_PIN P26 IOSTANDARD LVCMOS18} [get_ports {asicDataN[10]}]
set_property -dict {PACKAGE_PIN M24 IOSTANDARD LVCMOS18} [get_ports {asicDataP[11]}]
set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS18} [get_ports {asicDataN[11]}]
set_property -dict {PACKAGE_PIN K20 IOSTANDARD LVCMOS18} [get_ports {asicDataP[12]}]
set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS18} [get_ports {asicDataN[12]}]
set_property -dict {PACKAGE_PIN K23 IOSTANDARD LVCMOS18} [get_ports {asicDataP[13]}]
set_property -dict {PACKAGE_PIN J24 IOSTANDARD LVCMOS18} [get_ports {asicDataN[13]}]
set_property -dict {PACKAGE_PIN H24 IOSTANDARD LVCMOS18} [get_ports {asicDataP[14]}]
set_property -dict {PACKAGE_PIN G24 IOSTANDARD LVCMOS18} [get_ports {asicDataN[14]}]
set_property -dict {PACKAGE_PIN K27 IOSTANDARD LVCMOS18} [get_ports {asicDataP[15]}]
set_property -dict {PACKAGE_PIN K28 IOSTANDARD LVCMOS18} [get_ports {asicDataN[15]}]
set_property -dict {PACKAGE_PIN H27 IOSTANDARD LVCMOS18} [get_ports {asicDataP[16]}]
set_property -dict {PACKAGE_PIN H28 IOSTANDARD LVCMOS18} [get_ports {asicDataN[16]}]
set_property -dict {PACKAGE_PIN G25 IOSTANDARD LVCMOS18} [get_ports {asicDataP[17]}]
set_property -dict {PACKAGE_PIN G26 IOSTANDARD LVCMOS18} [get_ports {asicDataN[17]}]
set_property -dict {PACKAGE_PIN E25 IOSTANDARD LVCMOS18} [get_ports {asicDataP[18]}]
set_property -dict {PACKAGE_PIN E26 IOSTANDARD LVCMOS18} [get_ports {asicDataN[18]}]
set_property -dict {PACKAGE_PIN F28 IOSTANDARD LVCMOS18} [get_ports {asicDataP[19]}]
set_property -dict {PACKAGE_PIN E28 IOSTANDARD LVCMOS18} [get_ports {asicDataN[19]}]
set_property -dict {PACKAGE_PIN D24 IOSTANDARD LVCMOS18} [get_ports {asicDataP[20]}]
set_property -dict {PACKAGE_PIN D25 IOSTANDARD LVCMOS18} [get_ports {asicDataN[20]}]
set_property -dict {PACKAGE_PIN C26 IOSTANDARD LVCMOS18} [get_ports {asicDataP[21]}]
set_property -dict {PACKAGE_PIN C27 IOSTANDARD LVCMOS18} [get_ports {asicDataN[21]}]
set_property -dict {PACKAGE_PIN A27 IOSTANDARD LVCMOS18} [get_ports {asicDataP[22]}]
set_property -dict {PACKAGE_PIN A28 IOSTANDARD LVCMOS18} [get_ports {asicDataN[22]}]
set_property -dict {PACKAGE_PIN B25 IOSTANDARD LVCMOS18} [get_ports {asicDataP[23]}]
set_property -dict {PACKAGE_PIN A25 IOSTANDARD LVCMOS18} [get_ports {asicDataN[23]}]

# ASIC Control Ports

set_property -dict {PACKAGE_PIN AH14 IOSTANDARD LVCMOS25} [get_ports asicR0]
set_property -dict {PACKAGE_PIN AF14 IOSTANDARD LVCMOS25} [get_ports asicPpmat]
set_property -dict {PACKAGE_PIN AF12 IOSTANDARD LVCMOS25} [get_ports asicGlblRst]
set_property -dict {PACKAGE_PIN AG15 IOSTANDARD LVCMOS25} [get_ports asicSync]
set_property -dict {PACKAGE_PIN AG14 IOSTANDARD LVCMOS25} [get_ports asicAcq]

set_property -dict {PACKAGE_PIN AE11 IOSTANDARD LVCMOS25} [get_ports {asicRoClkP[0]}]
set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVCMOS25} [get_ports {asicRoClkN[0]}]
set_property -dict {PACKAGE_PIN AF10 IOSTANDARD LVCMOS25} [get_ports {asicRoClkP[1]}]
set_property -dict {PACKAGE_PIN AF9  IOSTANDARD LVCMOS25} [get_ports {asicRoClkN[1]}]
set_property -dict {PACKAGE_PIN AC13 IOSTANDARD LVCMOS25} [get_ports {asicRoClkP[2]}]
set_property -dict {PACKAGE_PIN AC12 IOSTANDARD LVCMOS25} [get_ports {asicRoClkN[2]}]
set_property -dict {PACKAGE_PIN AD14 IOSTANDARD LVCMOS25} [get_ports {asicRoClkP[3]}]
set_property -dict {PACKAGE_PIN AD13 IOSTANDARD LVCMOS25} [get_ports {asicRoClkN[3]}]

# SACI Ports

set_property -dict {PACKAGE_PIN AE15 IOSTANDARD LVCMOS25} [get_ports asicSaciCmd]
set_property -dict {PACKAGE_PIN AF15 IOSTANDARD LVCMOS25} [get_ports asicSaciClk]
set_property -dict {PACKAGE_PIN AH12 IOSTANDARD LVCMOS25} [get_ports {asicSaciSel[0]}]
set_property -dict {PACKAGE_PIN AG12 IOSTANDARD LVCMOS25} [get_ports {asicSaciSel[1]}]
set_property -dict {PACKAGE_PIN AE12 IOSTANDARD LVCMOS25} [get_ports {asicSaciSel[2]}]
set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVCMOS25} [get_ports {asicSaciSel[3]}]
set_property -dict {PACKAGE_PIN AH13 IOSTANDARD LVCMOS25} [get_ports asicSaciRsp]

# Spare Ports

set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS18} [get_ports {spareHpP[0]}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS18} [get_ports {spareHpN[0]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS18} [get_ports {spareHpP[1]}]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS18} [get_ports {spareHpN[1]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS18} [get_ports {spareHpP[2]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS18} [get_ports {spareHpN[2]}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS18} [get_ports {spareHpP[3]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS18} [get_ports {spareHpN[3]}]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS18} [get_ports {spareHpP[4]}]
set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS18} [get_ports {spareHpN[4]}]
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS18} [get_ports {spareHpP[5]}]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS18} [get_ports {spareHpN[5]}]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS18} [get_ports {spareHpP[6]}]
set_property -dict {PACKAGE_PIN C21 IOSTANDARD LVCMOS18} [get_ports {spareHpN[6]}]
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS18} [get_ports {spareHpP[7]}]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS18} [get_ports {spareHpN[7]}]
set_property -dict {PACKAGE_PIN D23 IOSTANDARD LVCMOS18} [get_ports {spareHpP[8]}]
set_property -dict {PACKAGE_PIN C23 IOSTANDARD LVCMOS18} [get_ports {spareHpN[8]}]
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS18} [get_ports {spareHpP[9]}]
set_property -dict {PACKAGE_PIN H21 IOSTANDARD LVCMOS18} [get_ports {spareHpN[9]}]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS18} [get_ports {spareHpP[10]}]
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS18} [get_ports {spareHpN[10]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS18} [get_ports {spareHpP[11]}]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS18} [get_ports {spareHpN[11]}]

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS25} [get_ports {spareHrP[0]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS25} [get_ports {spareHrN[0]}]
set_property -dict {PACKAGE_PIN AC9 IOSTANDARD LVCMOS25} [get_ports {spareHrP[1]}]
set_property -dict {PACKAGE_PIN AD9 IOSTANDARD LVCMOS25} [get_ports {spareHrN[1]}]
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVCMOS25} [get_ports {spareHrP[2]}]
set_property -dict {PACKAGE_PIN AD10 IOSTANDARD LVCMOS25} [get_ports {spareHrN[2]}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS25} [get_ports {spareHrP[3]}]
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS25} [get_ports {spareHrN[3]}]
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS25} [get_ports {spareHrP[4]}]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS25} [get_ports {spareHrN[4]}]
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS25} [get_ports {spareHrP[5]}]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS25} [get_ports {spareHrN[5]}]


# # GTH Ports

# set_property PACKAGE_PIN R4  [get_ports {smaTxP}]
# set_property PACKAGE_PIN R3  [get_ports {smaTxN}]
# set_property PACKAGE_PIN P2  [get_ports {smaRxP}]
# set_property PACKAGE_PIN P1  [get_ports {smaRxN}]

# set_property PACKAGE_PIN AA4 [get_ports {gtTxP}]
# set_property PACKAGE_PIN AA3 [get_ports {gtTxN}]
# set_property PACKAGE_PIN Y2  [get_ports {gtRxP}]
# set_property PACKAGE_PIN Y1  [get_ports {gtRxN}]

# set_property PACKAGE_PIN V6  [get_ports {gtRefP}]
# set_property PACKAGE_PIN V5  [get_ports {gtRefN}]
