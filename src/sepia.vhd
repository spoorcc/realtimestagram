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

--============================================================================--
--!
--!
--!
--!
entity sepia is
  generic (
    wordsize:             integer;    --! input image wordsize in bits
    image_width:          integer;    --! width of input image
    image_height:         integer     --! height of input image

  );
  port (
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block
 
    pixel_red_i:          in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_green_i:        in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_blue_i:         in std_logic_vector((wordsize-1) downto 0); --! the input pixel

    threshold:            in std_logic_vector((wordsize-1) downto 0); --! Amount of sepia effect

    pixel_red_o:          out std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_green_o:        out std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_blue_o:         out std_logic_vector((wordsize-1) downto 0)  --! the input pixel
  );

end entity;

--============================================================================--

architecture behavioural of sepia is

    constant max_value  : integer := 2**wordsize - 1;
 
    signal red_0        : integer range 0 to max_value;
    signal green_0      : integer range 0 to max_value;
    signal blue_0       : integer range 0 to max_value;
     
    signal r_g_max      : integer range 0 to max_value;
    signal b_delay      : integer range 0 to max_value;
    signal intensity    : integer range 0 to max_value;

    signal th_delay_d0  : integer range 0 to max_value;
    signal th_delay_d1  : integer range 0 to max_value;

    signal th_diff_6    : integer range 0 to max_value/6;
    signal th_d6_delay  : integer range 0 to max_value/6;
    signal th_d6_times7 : integer range 0 to (max_value/6)*7;

    signal max_min_th   : integer range 0 to max_value;

    signal tone         : integer range 0 to max_value / 7;

    signal red_o_int   : integer range 0 to max_value;
    signal green_o_int : integer range 0 to max_value;
    signal blue_o_int  : integer range 0 to max_value;

begin

    sepia_process : process(clk, rst)

        variable red_i_int   : integer range 0 to max_value := 0;
        variable green_i_int : integer range 0 to max_value := 0;
        variable blue_i_int  : integer range 0 to max_value := 0;

        variable threshold_i_int  : integer range 0 to max_value := 0;

        variable red_o_int_d0   : integer range 0 to max_value := 0;
        variable green_o_int_d0 : integer range 0 to max_value := 0;
        variable blue_o_int_d0  : integer range 0 to max_value := 0;

    begin

        if rst = '1' then

            pixel_red_o   <= (others => '0');
            pixel_green_o <= (others => '0');
            pixel_blue_o  <= (others => '0');

            r_g_max      <= 0;
            b_delay      <= 0;
            intensity    <= 0;

            th_delay_d0  <= 0;
            th_delay_d1  <= 0;

            th_diff_6    <= 0;
            th_d6_delay  <= 0;
            th_d6_times7 <= 0;

            max_min_th   <= 0;

            tone         <= 0;

            red_o_int    <= 0;
            green_o_int  <= 0;
            blue_o_int   <= 0;

            red_o_int_d0   := 0;    
            green_o_int_d0 := 0;
            blue_o_int_d0  := 0;

        elsif rising_edge(clk) then

            if enable = '1' then

                red_i_int   := to_integer(unsigned(pixel_red_i));
                green_i_int := to_integer(unsigned(pixel_green_i));
                blue_i_int  := to_integer(unsigned(pixel_blue_i));

                -- Convert to gray, by finding largest value
                if red_i_int >= green_i_int then
                    r_g_max <= red_i_int;
                else
                    r_g_max <= green_i_int;
                end if;
                b_delay <= blue_i_int;

                if r_g_max >= b_delay then
                    intensity <= r_g_max;
                else
                    intensity <= b_delay;
                end if;

                -- Calculate threshold
                threshold_i_int := to_integer(unsigned(threshold));

                th_diff_6 <= threshold_i_int / 6;
                th_d6_delay <= th_diff_6;

                th_d6_times7 <= th_diff_6 * 7;

                th_delay_d0 <= threshold_i_int;                
                th_delay_d1 <= th_delay_d0;

                max_min_th <= max_value - th_delay_d0;

                -- Calculate red pixel
                if intensity > th_delay_d1 then
                    red_o_int <= max_value;
                else
                    red_o_int <= intensity + max_min_th;
                end if;

                -- Calculate green pixel
                if intensity > th_d6_times7 then
                    green_o_int <= max_value;
                else
                    green_o_int <= intensity + max_value - th_d6_times7;
                end if;

                -- Calculate blue pixel
                if intensity < th_d6_delay then
                    blue_o_int <= 0;
                else
                    blue_o_int <= intensity - th_d6_delay;
                end if;

                -- Check ranges
                tone <= th_delay_d1 / 7;

                red_o_int_d0 := red_o_int;

                if green_o_int < tone then
                    green_o_int_d0 := tone;
                else
                    green_o_int_d0 := green_o_int;
                end if;

                if blue_o_int < tone then
                    blue_o_int_d0 := tone;
                else
                    blue_o_int_d0 := blue_o_int;
                end if;
 
                pixel_red_o   <= std_logic_vector(to_unsigned(red_o_int_d0, wordsize));
                pixel_green_o <= std_logic_vector(to_unsigned(green_o_int_d0, wordsize));
                pixel_blue_o  <= std_logic_vector(to_unsigned(blue_o_int_d0, wordsize));

            else
              pixel_red_o   <= (others => '0');
              pixel_green_o <= (others => '0');
              pixel_blue_o  <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;

end architecture;
--============================================================================--
