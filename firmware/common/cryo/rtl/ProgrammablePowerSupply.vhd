-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Programable Power supply
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 04/26/2016
-- Last update: 2020-05-12
-- Platform   : Vivado 2014.4
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Change log:
-- 
-------------------------------------------------------------------------------
-- Description: cryo ASIC adapter board registers for the Programable Power
-- Supply.
-------------------------------------------------------------------------------
-- This file is part of 'EpixHR Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'EpixHR Development Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

use work.AppPkg.all;

library unisim;
use unisim.vcomponents.all;

entity ProgrammablePowerSupply is
   generic (
      TPD_G             : time := 1 ns;
      CLK_PERIOD_G      : real := 10.0e-9
   );
   port (
      -- Global Signals
      axiClk         : in  sl;
      axiRst         : in  sl;
      -- AXI-Lite Register Interface (axiClk domain)
      axiReadMaster  : in  AxiLiteReadMasterType;
      axiReadSlave   : out AxiLiteReadSlaveType;
      axiWriteMaster : in  AxiLiteWriteMasterType;
      axiWriteSlave  : out AxiLiteWriteSlaveType;
      -- Static control IO interface
      enableLDO      : out slv(1 downto 0);
      -- DAC interfaces
      dacSclk        : out sl;
      dacDin         : out sl;
      dacCsb         : out slv(1 downto 0);
      dacClrb        : out sl
   );
end ProgrammablePowerSupply;

architecture rtl of ProgrammablePowerSupply is
   
   type RegType is record
      vDacSetting       : Slv16Array(1 downto 0);
      enableLDO         : slv(1 downto 0);
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;
   
   constant REG_INIT_C : RegType := (
      vDacSetting       => (others => (others=>'0')),
      enableLDO         => (others=>'0'),
      axiReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;
    
   signal axiReset : sl;
   
   signal dacDinSig  : slv(1 downto 0);  -- common signals
   signal dacSclkSig : slv(1 downto 0);  -- common signals
   signal dacClrbSig : slv(1 downto 0);  -- common signals
   
begin

   axiReset <= axiRst;
   dacDin   <= dacDinSig(0)  or dacDinSig(1);
   dacSclk  <= dacSclkSig(0) or dacSclkSig(1);
   dacClrb  <= dacClrbSig(0) or dacClrbSig(1);

   -------------------------------
   -- Configuration Register
   -------------------------------  
   comb : process (axiReadMaster, axiReset, axiWriteMaster, r) is
      variable v           : RegType;
      variable regCon      : AxiLiteEndPointType;
      
   begin
      -- Latch the current value
      v := r;
      
      -- Reset data and strobes
      v.axiReadSlave.rdata       := (others => '0');
            
      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave);
      
      -- Map out standard registers
      axiSlaveRegister(regCon,  x"000000",  0, v.enableLDO); -- Guard ring dac
      axiSlaveRegister(regCon,  x"000004",  0, v.vDacSetting(0));
      axiSlaveRegister(regCon,  x"000008",  0, v.vDacSetting(1));
      
      axiSlaveDefault(regCon, v.axiWriteSlave, v.axiReadSlave, AXI_RESP_OK_C);
      
      -- Synchronous Reset
      if axiReset = '1' then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      axiWriteSlave   <= r.axiWriteSlave;
      axiReadSlave    <= r.axiReadSlave;

      -- outputs
      enableLDO <= r.enableLDO;
      
   end process comb;

   seq : process (axiClk) is
   begin
      if rising_edge(axiClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;
   
   -----------------------------------------------
   -- DAC Controller
   -----------------------------------------------
   G_MAX5443 : for i in 0 to 1 generate
       U_DacCntrl : entity work.DacCntrl 
       generic map (
          TPD_G => TPD_G
       )
       port map ( 
          sysClk      => axiClk,
          sysClkRst   => axiReset,
          dacData     => r.vDacSetting(i),
          dacDin      => dacDinSig(i),
          dacSclk     => dacSclkSig(i),
          dacCsL      => dacCsb(i),
          dacClrL     => dacClrbSig(i)
       );
   end generate;      
   
end rtl;
