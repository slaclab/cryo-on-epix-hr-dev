#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : cryo DAQ top module (based on ePix HR readout)
#-----------------------------------------------------------------------------
# File       : cryoDAQ.py evolved from evalBoard.py
# Created    : 2018-06-12
# Last update: 2018-06-12
#-----------------------------------------------------------------------------
# Description:
# Rogue interface to cryo ASIC based on ePix HR boards
#-----------------------------------------------------------------------------
# This file is part of the rogue_example software. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue_example software, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import threading
import signal
import atexit
import yaml
import time
import sys
import argparse

import PyQt4.QtGui
import PyQt4.QtCore
import pyrogue.utilities.prbs
import pyrogue.utilities.fileio
import pyrogue.gui
import rogue.hardware.pgp
import rogue.hardware.data

import surf
import surf.axi
import surf.protocols.ssi

import ePixViewer as vi
import ePixFpga as fpga
from XilinxKcu1500Pgp3.XilinxKcu1500Pgp3 import *

# Set the argument parser
parser = argparse.ArgumentParser()

# Add arguments
parser.add_argument(
    "--type", 
    type     = str,
    required = True,
    help     = "define the PCIe card type (either pgp-gen3 or kcu1500)",
)  

parser.add_argument(
    "--start_gui", 
    type     = bool,
    required = False,
    default  = True,
    help     = "true to show gui",
)  

parser.add_argument(
    "--verbose", 
    type     = bool,
    required = False,
    default  = False,
    help     = "true for verbose printout",
)  

# Get the arguments
args = parser.parse_args()

# Add PGP virtual channels
if ( args.type == 'pgp-gen3' ):
    # Create the PGP interfaces for ePix hr camera
    pgpL0Vc0 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,0) # Data & cmds
    pgpL0Vc1 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,1) # Registers for ePix board
    pgpL0Vc2 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,2) # PseudoScope
    pgpL0Vc3 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,3) # Monitoring (Slow ADC)

    #pgpL1Vc0 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',0,0) # Data (when using all four lanes it should be swapped back with L0)
    pgpL2Vc0 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',2,0) # Data
    pgpL3Vc0 = rogue.hardware.pgp.PgpCard('/dev/pgpcard_0',3,0) # Data

    print("")
    print("PGP Card Version: %x" % (pgpL0Vc0.getInfo().version))
    
#elif ( args.type == 'kcu1500' ):
    # Create the PGP interfaces for ePix hr camera
#    pgpL0Vc0 = rogue.hardware.data.DataCard('/dev/datadev_0',(0*32)+0) # Data & cmds
#    pgpL0Vc1 = rogue.hardware.data.DataCard('/dev/datadev_0',(0*32)+1) # Registers for ePix board
#    pgpL0Vc2 = rogue.hardware.data.DataCard('/dev/datadev_0',(0*32)+2) # PseudoScope
#    pgpL0Vc3 = rogue.hardware.data.DataCard('/dev/datadev_0',(0*32)+3) # Monitoring (Slow ADC)

    #pgpL1Vc0 = rogue.hardware.data.DataCard('/dev/datadev_0',(0*32)+0) # Data (when using all four lanes it should be swapped back with L0)
#    pgpL2Vc0 = rogue.hardware.data.DataCard('/dev/datadev_0',(2*32)+0) # Data
#    pgpL3Vc0 = rogue.hardware.data.DataCard('/dev/datadev_0',(3*32)+0) # Data
#else:
#    raise ValueError("Invalid type (%s)" % (args.type) )

# Add data stream to file as channel 1 File writer
dataWriter = pyrogue.utilities.fileio.StreamWriter(name='dataWriter')
#pyrogue.streamConnect(pgpL2Vc0, dataWriter.getChannel(0x1))

cmd = rogue.protocols.srp.Cmd()
#pyrogue.streamConnect(cmd, pgpL0Vc0)

# Create and Connect SRP to VC1 to send commands
srp = rogue.protocols.srp.SrpV3()
#pyrogue.streamConnectBiDir(pgpL0Vc1,srp)

#############################################
# Microblaze console printout
#############################################
class MbDebug(rogue.interfaces.stream.Slave):

    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)
        self.enable = False

    def _acceptFrame(self,frame):
        if self.enable:
            p = bytearray(frame.getPayload())
            frame.read(p,0)
            print('-------- Microblaze Console --------')
            print(p.decode('utf-8'))

class EventReader(rogue.interfaces.stream.Slave):
    def __init__(self):
        rogue.interfaces.stream.Slave.__init__(self)
        self.enable = True
        self.numAcceptedFrames = 0
        self.lastFrame = rogue.interfaces.stream.Frame
	

    def _acceptFrame(self,frame):
        self.lastFrame = frame
        if self.enable:
            self.numAcceptedFrames += 1
            # Get the channel number
            chNum = (frame.getFlags() >> 24)
            print('-------- Frame ',self.numAcceptedFrames,'Channel',frame.getFlags() , ' Accepeted --------' , chNum)
            # Check if channel number is 0x1 (streaming data channel)
            if (chNum == 0x0) :
                print('-------- Event --------')
                # Collect the data
                p = bytearray(frame.getPayload())
                frame.read(p,0)
                cnt = 0
                while (cnt < len(p)):
                    value = 0
                    for x in range(0,4):
                        if (cnt < len(p)): 
                            value += (p[cnt] << (x*8))
                        cnt += 1
                    #print ('data[%d]: 0x%.8x' % ( (cnt/4), value ))
                print ('frame[%d]: %d' % ( (self.numAcceptedFrames), cnt ))        

#######################################
# Custom run control
#######################################
class MyRunControl(pyrogue.RunControl):
    def __init__(self,name):
        pyrogue.RunControl.__init__(self,name, description='Run Controller ePix HR empty',  rates={1:'1 Hz', 2:'2 Hz', 4:'4 Hz', 8:'8 Hz', 10:'10 Hz', 30:'30 Hz', 60:'60 Hz', 120:'120 Hz'})
        self._thread = None

    def _setRunState(self,dev,var,value,changed):
        if changed: 
            if self.runState.get(read=False) == 'Running': 
                self._thread = threading.Thread(target=self._run) 
                self._thread.start() 
            else: 
                self._thread.join() 
                self._thread = None 


    def _run(self):
        self.runCount.set(0) 
        self._last = int(time.time()) 
 
 
        while (self.runState.value() == 'Running'): 
            delay = 1.0 / ({value: key for key,value in self.runRate.enum.items()}[self._runRate]) 
            time.sleep(delay) 
            self._root.ssiPrbsTx.oneShot() 
  
            self._runCount += 1 
            if self._last != int(time.time()): 
                self._last = int(time.time()) 
                self.runCount._updated() 
                
##############################
# Set base
##############################
class Board(pyrogue.Root):
    def __init__(self, guiTop, cmd, dataWriter, srp, **kwargs):
        super().__init__(name='cryoAsicGen1',description='cryo ASIC', **kwargs)
        self.add(dataWriter)
        self.guiTop = guiTop
        self.cmd = cmd

        @self.command()
        def Trigger():
            self.cmd.sendCmd(0, 0)

        # Add Devices
        #if ( args.type == 'kcu1500' ):
            #coreMap = rogue.hardware.axi.AxiMemMap('/dev/datadev_0')
            #self.add(XilinxKcu1500Pgp3(memBase=coreMap))        
        self.add(fpga.EpixHRGen1Cryo(name='EpixHRGen1Cryo', offset=0, memBase=srp, hidden=False, enabled=True))

if (args.verbose): dbgData = rogue.interfaces.stream.Slave()
if (args.verbose): dbgData.setDebug(60, "DATA Verbose 0[{}]".format(0))
if (args.verbose): pyrogue.streamTap(pgpL0Vc0, dbgData)

if (args.verbose): dbgData = rogue.interfaces.stream.Slave()
if (args.verbose): dbgData.setDebug(60, "DATA Verbose 1[{}]".format(0))
# if (args.verbose): pyrogue.streamTap(pgpL1Vc0, dbgData)

if (args.verbose): dbgData = rogue.interfaces.stream.Slave()
if (args.verbose): dbgData.setDebug(60, "DATA Verbose 2[{}]".format(0))
if (args.verbose): pyrogue.streamTap(pgpL2Vc0, dbgData)

if (args.verbose): dbgData = rogue.interfaces.stream.Slave()
if (args.verbose): dbgData.setDebug(60, "DATA Verbose 3[{}]".format(0))
if (args.verbose): pyrogue.streamTap(pgpL3Vc0, dbgData)

# Create GUI
appTop = PyQt4.QtGui.QApplication(sys.argv)
guiTop = pyrogue.gui.GuiTop(group='cryoAsicGui')
cryoAsicBoard = Board(guiTop, cmd, dataWriter, srp)
cryoAsicBoard.start(pollEn=False, pyroGroup=None)
guiTop.addTree(cryoAsicBoard)
guiTop.resize(800,800)

# Create the objects            
fileReader  = rogue.utilities.fileio.StreamReader()
eventReader = EventReader()


# Viewer gui
onlineViewer = vi.Window(cameraType='HrAdc32x32')
onlineViewer.eventReader.frameIndex = 0
onlineViewer.setReadDelay(0)
#pyrogue.streamTap(pgpL0Vc0, onlineViewer.eventReader)
#pyrogue.streamTap(pgpL0Vc2, onlineViewer.eventReaderScope)# PseudoScope
#pyrogue.streamTap(pgpL0Vc3, onlineViewer.eventReaderMonitoring) # Slow Monitoring
pyrogue.streamTap(fileReader, onlineViewer.eventReader) 

# Create GUI
if (args.start_gui):
    appTop.exec_()

# Close window and stop polling
def stop():
    mNode.stop()
    cryoAsicBoard.stop()
    exit()

# Start with: ipython -i scripts/epix10kaDAQ.py for interactive approach
print("Started rogue mesh and epics V3 server. To exit type stop()")



# Connect the fileReader to our event processor
#pyrogue.streamConnect(fileReader,eventReader)

# Open the data file
print('-------- Openning file --------')
fileReader.open('/u1/ddoering/testData4.dat')
    
time.sleep(1)
