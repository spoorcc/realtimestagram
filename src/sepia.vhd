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
--! \class sepia
--! \brief Creates a sepia image
--!
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
entity sepia is
  generic (
    wordsize:             integer;    --! input image wordsize in bits
    image_width:          integer;    --! width of input image
    image_height:         integer;    --! height of input image

    amount:               real        --! amount of sepia effect [0.0 - 1.0]

  );
  port (
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block
 
    pixel_red_i:          in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_green_i:        in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_blue_i:         in std_logic_vector((wordsize-1) downto 0); --! the input pixel

    pixel_red_o:          out std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_green_o:        out std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_blue_o:         out std_logic_vector((wordsize-1) downto 0)  --! the input pixel
  );


--  constant RR  : real := 0.299 ;
--  constant RG  : real := 0.587 ;
--  constant RB  : real := 0.114 ;

--  constant GR  : real := 0.299 ;
--  constant GG  : real := 0.587 ;
--  constant GB  : real := 0.114 ;

--  constant BR  : real := 0.299 ;
--  constant BG  : real := 0.587 ;
--  constant BB  : real := 0.114 ;

    constant RR  : real := 0.393 ;
    constant RG  : real := 0.769 ;
    constant RB  : real := 0.189 ;
  
    constant GR  : real := 0.349 ;
    constant GG  : real := 0.686 ;
    constant GB  : real := 0.168 ;
  
    constant BR  : real := 0.272 ;
    constant BG  : real := 0.534 ;
    constant BB  : real := 0.131 ;

--  constant RR  : real := 0.291; --0.393 ;
--  constant RG  : real := 0.569; --0.769 ;
--  constant RB  : real := 0.140; --0.189 ;

--  constant GR  : real := 0.258; --0.349 ;
--  constant GG  : real := 0.508; --0.686 ;
--  constant GB  : real := 0.124; --0.168 ;

--  constant BR  : real := 0.201; --0.272 ;
--  constant BG  : real := 0.395; --0.534 ;
--  constant BB  : real := 0.097; --0.131 ;
end entity;

--============================================================================--

architecture behavioural of sepia is
    
    constant lut_rr:           array_pixel := create_straight_lut(2**wordsize, RR * amount);
    constant lut_rg:           array_pixel := create_straight_lut(2**wordsize, RG * amount);
    constant lut_rb:           array_pixel := create_straight_lut(2**wordsize, RB * amount);

    constant lut_gr:           array_pixel := create_straight_lut(2**wordsize, GR * amount);
    constant lut_gg:           array_pixel := create_straight_lut(2**wordsize, GG * amount);
    constant lut_gb:           array_pixel := create_straight_lut(2**wordsize, GB * amount);

    constant lut_br:           array_pixel := create_straight_lut(2**wordsize, BR * amount);
    constant lut_bg:           array_pixel := create_straight_lut(2**wordsize, BG * amount);
    constant lut_bb:           array_pixel := create_straight_lut(2**wordsize, BB * amount);

    signal red_0   : integer range 0 to 2**(wordsize + 1);
    signal green_0 : integer range 0 to 2**(wordsize + 1);
    signal blue_0  : integer range 0 to 2**(wordsize + 1);

begin

    --! \brief clocked process that outputs LUT-value on each rising edge if enable is true 
    --! \param[in] clk clock
    --! \param[in] rst asynchronous reset
    apply_rgb_luts : process(clk, rst)

        variable red_i_int   : integer range 0 to 2**wordsize := 0;
        variable green_i_int : integer range 0 to 2**wordsize := 0;
        variable blue_i_int  : integer range 0 to 2**wordsize := 0;

        variable red_o_int   : integer range 0 to 2**(wordsize + 2) := 0;
        variable green_o_int : integer range 0 to 2**(wordsize + 2) := 0;
        variable blue_o_int  : integer range 0 to 2**(wordsize + 2) := 0;

        variable pixel_red_slv   : std_logic_vector(wordsize+1 downto 0) := (others => '0');
        variable pixel_green_slv : std_logic_vector(wordsize+1 downto 0) := (others => '0');
        variable pixel_blue_slv  : std_logic_vector(wordsize+1 downto 0) := (others => '0');
    begin

        if rst = '1' then

            pixel_red_o   <= (others => '0');
            pixel_green_o <= (others => '0');
            pixel_blue_o  <= (others => '0');

            red_0   <= 0;
            green_0 <= 0;
            blue_0  <= 0;

        elsif rising_edge(clk) then

            if enable = '1' then

                red_i_int   := to_integer(unsigned(pixel_red_i));
                green_i_int := to_integer(unsigned(pixel_green_i));
                blue_i_int  := to_integer(unsigned(pixel_blue_i));

                -- first stage
                red_0   <= to_integer(unsigned(lut_rr(red_i_int)))   + to_integer(unsigned(lut_rg(red_i_int)));
                green_0 <= to_integer(unsigned(lut_gr(green_i_int))) + to_integer(unsigned(lut_gg(green_i_int)));
                blue_0  <= to_integer(unsigned(lut_br(blue_i_int)))  + to_integer(unsigned(lut_bg(blue_i_int)));

                -- Second stage
                red_o_int   := red_0   + to_integer(unsigned(lut_rb(red_i_int)));
                green_o_int := green_0 + to_integer(unsigned(lut_gb(green_i_int)));
                blue_o_int  := blue_0  + to_integer(unsigned(lut_bb(blue_i_int)));

                -- Clip and output red channel
                if red_o_int >= 2**wordsize then
                    pixel_red_slv := (others => '1');
                else
                    pixel_red_slv := std_logic_vector(to_unsigned(red_o_int, wordsize+2));
                end if; 
                pixel_red_o   <= pixel_red_slv(wordsize-1 downto 0);

                -- Clip and output green channel
                if green_o_int >= 2**wordsize then
                    pixel_green_slv := (others => '1');
                else
                    pixel_green_slv := std_logic_vector(to_unsigned(green_o_int, wordsize+2));
                end if;
                pixel_green_o   <= pixel_green_slv(wordsize-1 downto 0);

                -- Clip and output blue channel
                if blue_o_int >= 2**wordsize then
                    pixel_blue_slv := (others => '1');
                else
                    pixel_blue_slv := std_logic_vector(to_unsigned(blue_o_int, wordsize+2));
                end if;
                pixel_blue_o   <= pixel_blue_slv(wordsize-1 downto 0);

            else
              pixel_red_o   <= (others => '0');
              pixel_green_o <= (others => '0');
              pixel_blue_o  <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;

end architecture;
--============================================================================--
