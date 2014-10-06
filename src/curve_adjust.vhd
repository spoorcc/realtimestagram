--   This file is part of Realtimestagram.
--
--   Realtimestagram is free software: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 2 of the License, or
--   (at your option) any later version.
--
--   Realtimestagram is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License
--   along with Realtimestagram.  If not, see <http://www.gnu.org/licenses/>.

--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>
--! \class curve_adjust
--! \brief Applies a curve adjustment
--!
--! Description
--! -----------
--!
--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--============================================================================--

ENTITY curve_adjust IS
  GENERIC (
    wordsize:             integer  --! input image wordsize in bits
  );
  PORT (
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block
    input_pixel:          in std_logic_vector((wordsize-1) downto 0);       --! the input pixel

    output_pixel:         out std_logic_vector((wordsize-1) downto 0)       --! the output pixel
  );
END ENTITY;

--============================================================================--

ARCHITECTURE curve_adjust_stub OF curve_adjust IS

  -- signal declarations
  SIGNAL the_signal:       std_logic_vector((wordsize-1) downto 0);


BEGIN

  PROCESS(clk, rst)
  BEGIN

   output_pixel <= the_signal;

    IF rst = '1' THEN
      the_signal  <= (others => '0');

    ELSIF RISING_EDGE(clk) THEN

      IF enable = '1' THEN

        the_signal <= input_pixel;

      END IF; -- end if enable = '1'

    END IF; -- end if rst = '1'
  END PROCESS;
END ARCHITECTURE;

--============================================================================--
