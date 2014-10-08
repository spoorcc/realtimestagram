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
--! \dot
--! digraph curve_adjust{
--!  
--!  graph [rankdir=LR, splines=ortho, sep=5];
--!  edge  [penwidth=2.2, arrowsize=.5]
--!  node  [height=0.25, width=0.25, style=filled, fontname=sans]
--!
--!  /* Single or multibit registers */
--!  subgraph registers{
--!      node [fontcolor=white, fontname=serif, fillcolor=gray32, shape=box, headport=w, tailport=e]
--!      clk rst enable input_pixel output_pixel
--!  }
--!
--!  subgraph cluster_0 {
--!
--!      color=gray128;
--!      label=CURVE_ADJUST;
--!      fontcolor=black;
--!      fontname=sans;
--!
--!      LUT  [label="LUT", height=2, shape=box, fillcolor=gray96, fontcolor=black, tailport=e]
--!      and0 [label="&", shape=circle, fillcolor=white, fontcolor=black, fixedsize=true]
--!  }
--!
--!  clk -> and0
--!  enable -> and0
--!  rst -> and0 [arrowhead=odot, arrowsize=0.6]
--!  and0 -> LUT 
--!  input_pixel -> LUT -> output_pixel
--!
--!}
--! \enddot
--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--============================================================================--
--!
--!
--!
--!
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

--! \brief Array of integers
type array_integer is array (natural range <>) of integer;

--! 
--! \fn create_lookup_table
--! \brief Creates a lookup table using some predefined formula 
--! \description
--!  Calculates every value and after that returns and integer array 
--! \param[in] size Integer number of elements in returned array

function create_lookup_table(size: integer) return array_integer is
    variable return_value: array_integer(0 to size - 1);
begin
    for i in return_value'range loop
        array_integer(i) := INTEGER(i);
    end loop;
end function create_lookup_table;

constant LUT_SIZE: natural := 2**wordsize; --! Size of the lookup-tables
constant LUT_CONTENTS: array_integer(0 to (LUT_SIZE-1)) := create_lookup_table(LUT_SIZE); --! generated lookup table

BEGIN

  --! \brief Clocked process that outputs the curve on each rising edge if enable is true 
  --! \param[in] clk clock
  --! \param[in] rst asynchronous reset
  curve_adjustment : PROCESS(clk, rst)
  BEGIN
    IF rst = '1' THEN
      the_signal  <= (others => '0');

    ELSIF RISING_EDGE(clk) THEN

      IF enable = '1' THEN

        the_signal <= STD_LOGIC_VECTOR(TO_UNSIGNED(LUT_CONTENTS(INTEGER(input_pixel)), wordsize-1));
        output_pixel <= the_signal;

      END IF; -- end if enable = '1'

    END IF; -- end if rst = '1'
  END PROCESS;
END ARCHITECTURE;

--============================================================================--
