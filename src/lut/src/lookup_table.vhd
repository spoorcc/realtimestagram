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
--! \class lookup_table
--! \brief returns a value from a pre generated lookup table
--!
--! \dot
--! digraph lookup_table{
--!  
--!  graph [rankdir=LR, splines=ortho, sep=5];
--!  edge  [penwidth=2.2, arrowsize=.5]
--!  node  [height=0.25, width=0.25, style=filled, fontname=sans]
--!
--!  /* single or multibit registers */
--!  subgraph registers{
--!      node [fontcolor=white, fontname=serif, fillcolor=gray32, shape=box, headport=w, tailport=e]
--!      clk rst enable pixel_i pixel_o
--!  }
--!
--!  subgraph cluster_0 {
--!
--!      color=gray100;
--!      label=lookup_table;
--!      fontcolor=black;
--!      fontname=sans;
--!
--!      lut  [label="lut", height=2, shape=box, fillcolor=gray96, fontcolor=black, tailport=e]
--!      and0 [label="&", shape=circle, fillcolor=white, fontcolor=black, fixedsize=true]
--!  }
--!
--!  clk -> and0
--!  enable -> and0
--!  rst -> and0 [arrowhead=odot, arrowsize=0.6]
--!  and0 -> lut 
--!  pixel_i -> lut -> pixel_o
--!
--!}
--! \enddot
--!
--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common;
use common.curves_pkg.all;
--============================================================================--
--!
--!
--!
--!
entity lookup_table is
  generic (
    wordsize:             integer;    --! input image wordsize in bits
    lut:                  array_pixel --! pre generated lookup table
  );
  port (
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block
    pixel_i:              in std_logic_vector((wordsize-1) downto 0);       --! the input pixel

    pixel_o:              out std_logic_vector((wordsize-1) downto 0)       --! the output pixel
  );
end entity;

--============================================================================--

architecture behavioural of lookup_table is
    
    -- signal declarations
    signal lut_value_s:       std_logic_vector((wordsize-1) downto 0);

begin
    
    --! \brief clocked process that outputs LUT-value on each rising edge if enable is true 
    --! \param[in] clk clock
    --! \param[in] rst asynchronous reset
    curve_adjustment : process(clk, rst)
    begin
        if rst = '1' then
            lut_value_s  <= (others => '0');

        elsif rising_edge(clk) then

            if enable = '1' then
                lut_value_s <= lut(to_integer(unsigned(pixel_i)));
                pixel_o <= lut_value_s;
            else
                pixel_o <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;
end architecture;

--============================================================================--
