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
--! \class vignette
--! \brief Creates a faded vignette around the image
--!
--! \image html vignette.png
--!
--! \dot
--! digraph vignette{
--!   
--!   graph [rankdir=LR, splines=ortho, sep=5];
--!   edge  [penwidth=2.2, arrowsize=.5]
--!   node  [height=0.25,  style=filled, fontname=sans]
--! 
--!   /* single or multibit registers */
--! 
--!   
--!   subgraph inputs {
--!       node [fontcolor=white, fontname=serif, fillcolor=gray32, shape=box, tailport=e]
--!       rank=same; clk rst enable hcount vcount pixel_i
--!   }
--! 
--!   subgraph cluster_component {
--!         
--!       color=gray64
--!       label="vignette";
--!       fontcolor=black;
--!       fontname=sans;
--! 
--!     subgraph operators{
--!         node [ shape=circle, fillcolor=white, fontcolor=black, labelloc=c, fixedsize=true, tailport=e]
--!         and0 [label="&"] 
--! 
--!         mult0 [label="x"]
--!         mult1 [label="x"]
--!     }
--! 
--!   subgraph registers{
--!       node [fontcolor=white, fontname=serif, fillcolor=gray32, shape=box, headport=w]
--!       pixel_i_reg0 [label="p0"]
--!       pixel_i_reg1 [label="p1"]
--!     }
--! 
--!     subgraph function_blocks{
--!         node [ height=1, shape=box, fillcolor=gray96, fontcolor=black, headport=w, tailport=e]
--!         lut_x [label="lut x"] 
--!         lut_y [label="lut y"] 
--!     }
--!   }
--! 
--!   subgraph output{
--!       node [fontcolor=white, fontname=serif, fillcolor=gray32, shape=box, headport=w]
--!       rank=same; pixel_o
--!   }
--! 
--!   clk    -> and0
--!   enable -> and0
--!   rst    -> and0 [arrowhead=odot, arrowsize=0.6]
--! 
--!   and0   -> lut_x
--!   hcount -> lut_x -> mult0
--! 
--!   and0   -> lut_y
--!   vcount -> lut_y -> mult0
--! 
--!   pixel_i -> pixel_i_reg0 -> pixel_i_reg1 -> mult1
--!   mult0   -> mult1 -> pixel_o
--! }
--! \enddot
--!
--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Used for calculation of h_count and v_cunt port width
use ieee.math_real.all;

use work.curves_pkg.all;
--============================================================================--
--!
--!
--!
--!
entity lomo is
  generic (
    wordsize:             integer;    --! input image wordsize in bits
    image_width:          integer;    --! width of input image
    image_height:         integer     --! height of input image

  );
  port (
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block
 
    --! x-coordinate of input pixel 
    h_count:              in std_logic_vector((integer(ceil(log2(real(image_width))))-1) downto 0);
    --! y-coordinate of input pixel 
    v_count:              in std_logic_vector((integer(ceil(log2(real(image_height))))-1) downto 0);

    pixel_red_i:          in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_green_i:        in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_blue_i:         in std_logic_vector((wordsize-1) downto 0); --! the input pixel

    pixel_red_o:          out std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_green_o:        out std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_blue_o:         out std_logic_vector((wordsize-1) downto 0)  --! the input pixel
  );
end entity;

--============================================================================--

architecture behavioural of lomo is
    
    -- signal declarations
    signal lut_value_x:       std_logic_vector((wordsize-1) downto 0); --! Value from LUT_x
    signal lut_value_y:       std_logic_vector((wordsize-1) downto 0); --! Value from LUT_y

    signal lut_value_r_s:     std_logic_vector((wordsize-1) downto 0); --! Value from LUT_y
    signal lut_value_g_s:     std_logic_vector((wordsize-1) downto 0); --! Value from LUT_y
    signal lut_value_b_s:     std_logic_vector((wordsize-1) downto 0); --! Value from LUT_y

    signal lut_x_lut_y:       natural range 0 to 2**(2*wordsize); --! LUT_x * LUT_y

    signal p_r:               natural range 0 to 2**(wordsize); --! buffered pix_in
    signal p_g:               natural range 0 to 2**(wordsize); --! buffered pix_in
    signal p_b:               natural range 0 to 2**(wordsize); --! buffered pix_in

    constant lut_r:           array_pixel := create_straight_lut(2**wordsize);
    constant lut_g:           array_pixel := create_straight_lut(2**wordsize);
    constant lut_b:           array_pixel := create_straight_lut(2**wordsize);

    constant lut_x:           array_pixel := create_sine_lut(image_width,  1.0);
    constant lut_y:           array_pixel := create_sine_lut(image_height,  1.0);
begin

    --! \brief clocked process that outputs LUT-value on each rising edge if enable is true 
    --! \param[in] clk clock
    --! \param[in] rst asynchronous reset
    rgb_curve : process(clk, rst)
        variable pixel_o_r_slv : std_logic_vector(3*wordsize-1 downto 0) := (others => '0');
        variable pixel_o_g_slv : std_logic_vector(3*wordsize-1 downto 0) := (others => '0');
        variable pixel_o_b_slv : std_logic_vector(3*wordsize-1 downto 0) := (others => '0');
    begin
        if rst = '1' then
            lut_value_x  <= (others => '0');
            lut_value_y  <= (others => '0');

            lut_x_lut_y  <= 0;

            p_r  <= 0;
            p_g  <= 0;
            p_b  <= 0;

            lut_value_r_s  <= (others => '0');
            lut_value_g_s  <= (others => '0');
            lut_value_b_s  <= (others => '0');

        elsif rising_edge(clk) then

            if enable = '1' then

                -- Vignette calculation
                lut_value_x <= lut_x(to_integer(unsigned(h_count)));
                lut_value_y <= lut_y(to_integer(unsigned(v_count)));

                lut_x_lut_y <= to_integer(unsigned(lut_value_x)) * to_integer(unsigned(lut_value_y));

                -- Color channel adaption
                lut_value_r_s <= lut_r(to_integer(unsigned(pixel_red_i)));
                lut_value_g_s <= lut_g(to_integer(unsigned(pixel_green_i)));
                lut_value_b_s <= lut_b(to_integer(unsigned(pixel_blue_i)));

                p_r <= to_integer(unsigned(lut_value_r_s));
                p_g <= to_integer(unsigned(lut_value_g_s));
                p_b <= to_integer(unsigned(lut_value_b_s));

                -- Apply vignette
                pixel_o_r_slv := std_logic_vector(to_unsigned(lut_x_lut_y * p_r, 3*wordsize));
                pixel_o_g_slv := std_logic_vector(to_unsigned(lut_x_lut_y * p_g, 3*wordsize));
                pixel_o_b_slv := std_logic_vector(to_unsigned(lut_x_lut_y * p_b, 3*wordsize));

                pixel_red_o   <= pixel_o_r_slv(3*wordsize-1 downto 2*wordsize);
                pixel_green_o <= pixel_o_g_slv(3*wordsize-1 downto 2*wordsize);
                pixel_blue_o  <= pixel_o_b_slv(3*wordsize-1 downto 2*wordsize);

            else
                pixel_red_o   <= (others => '0');
                pixel_green_o <= (others => '0');
                pixel_blue_o  <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;

end architecture;
--============================================================================--
