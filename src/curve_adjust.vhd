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
--! \brief applies a curve adjustment
--!
--! \dot
--! digraph curve_adjust{
--!  
--!  graph [rankdir=lr, splines=ortho, sep=5];
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
--!      color=gray128;
--!      label=curve_adjust;
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
--! Curves
--! =========
--!
--! Multiple curves are possible:
--! * Straight (used for testing purposes) 
--! * Sigmoid (used for contrast enhancement)
--!
--! Straight
--! ---------- 
--! \image html straight.png
--!
--!
--! Sigmoid
--! ---------- 
--! The sigmoid function is \f[p_{out}=\frac{p_{max}}{1+\exp({-c/p_{max}*(p_{in}-p_{max})})} \f]
--! \image html sigmoid.png
--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--============================================================================--
--!
--!
--!
--!
entity curve_adjust is
  generic (
    wordsize:             integer  --! input image wordsize in bits
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

architecture curve_adjust of curve_adjust is

    --! \brief array of std_logic_vectors
    type array_pixel is array (natural range <>) of std_logic_vector(wordsize-1 downto 0);

	--! three types can be selected, these types are specified in the detailed description
	type curvetype is (straight, sigmoid);

    --! \fn create_lookup_table
    --! \brief creates a lookup table using some predefined formula 
    --! \description
    --!  calculates every value and after that returns and integer array 
    --! \param[in] size integer number of elements in returned array
    function create_lookup_table(size: integer; 
                                 curve_type: curvetype := sigmoid) 
        return array_pixel is

        variable return_value: array_pixel(0 to size - 1); --! Filled Look up table
        
        variable exponent: real := 0.0;
        variable calc_val: real := 0.0;
        constant max_val:  real := 255.0;
        constant c:        real := 8.0;
    begin
    --!TODO: Clean up
        for i in return_value'range loop

            curve_sel: case curve_type is
                when straight =>
                    calc_val := real(i);
                when sigmoid =>
                    exponent := (c/max_val)*(real(i) - max_val * 0.5 );
                    calc_val := ceil(max_val / (real(1) + exp(-exponent)));
                end case;

            report "LUT[" & integer'image(i) & "]: " & integer'image(integer(calc_val));
            assert(integer(calc_val) <= integer(max_val)) report "LUT filled with invalid value: " & integer'image(integer(calc_val)) severity failure;
            assert(integer(calc_val) > 0) report "LUT filled with invalid value" severity failure;

            return_value(i) := std_logic_vector(to_unsigned(integer(calc_val), wordsize));

        end loop;
        return return_value;
    end function create_lookup_table;
    
    -- signal declarations
    signal lut_value_s:       std_logic_vector((wordsize-1) downto 0);

    --! Look up table size  
    constant lut_size_c: natural := 2**wordsize;

    --! Generated lookup table
    constant lut_contents: array_pixel(0 to (lut_size_c-1)) := create_lookup_table(lut_size_c); 
begin
    
    --! \brief clocked process that outputs the curve on each rising edge if enable is true 
    --! \param[in] clk clock
    --! \param[in] rst asynchronous reset
    curve_adjustment : process(clk, rst)
    begin
        if rst = '1' then
            lut_value_s  <= (others => '0');

        elsif rising_edge(clk) then

            if enable = '1' then
                lut_value_s <= lut_contents(to_integer(unsigned(pixel_i)));
                pixel_o <= lut_value_s;
            else
                pixel_o <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;
end architecture;

--============================================================================--
