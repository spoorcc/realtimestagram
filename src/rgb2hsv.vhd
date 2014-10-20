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
--! \class rgb2hsv
--! \brief Creates seperate Hue Saturation Value channels from rgb signal
--!
--!
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
entity rgb2hsv is
  generic (
    wordsize:             integer := 8    --! input image wordsize in bits
  );
  port (

    -- inputs
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block
 
    pixel_red_i:          in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_green_i:        in std_logic_vector((wordsize-1) downto 0); --! the input pixel
    pixel_blue_i:         in std_logic_vector((wordsize-1) downto 0); --! the input pixel

    -- outputs
    pixel_hue_o:          out std_logic_vector((wordsize-1) downto 0);
    pixel_sat_o:          out std_logic_vector((wordsize-1) downto 0);
    pixel_val_o:          out std_logic_vector((wordsize-1) downto 0)
  );
end entity;

--============================================================================--

architecture behavioural of rgb2hsv is
    
    -- signal declarations
    signal r_min_g:                 integer range 0 to 2**wordsize;   
    signal b_min_r:                 integer range 0 to 2**wordsize;      
    signal g_min_b:                 integer range 0 to 2**wordsize;     

    signal c_x_r_min_g:             integer range 0 to (2**wordsize)*43;   
    signal c_x_b_min_r:             integer range 0 to (2**wordsize)*43;      
    signal c_x_g_min_b:             integer range 0 to (2**wordsize)*43;     

    signal div_c_x_r_min_g:         integer range 0 to (2**wordsize)*43;   
    signal div_c_x_b_min_r:         integer range 0 to (2**wordsize)*43;      
    signal div_c_x_g_min_b:         integer range 0 to (2**wordsize)*43;     

    signal rg_mux_in:               integer range 0 to (2**wordsize)*43;   
    signal br_mux_in:               integer range 0 to (2**wordsize)*43;      
    signal gb_mux_in:               integer range 0 to (2**wordsize)*43;     

    signal mux_select0:             integer range 0 to 2;
    signal mux_select1:             integer range 0 to 2;
    signal mux_select2:             integer range 0 to 2;
    signal mux_select3:             integer range 0 to 2;

    signal comp_max_out:            std_logic_vector(wordsize-1 downto 0);
    signal comp_mid_out:            std_logic_vector(wordsize-1 downto 0);
    signal comp_min_out:            std_logic_vector(wordsize-1 downto 0);

    signal comp_max0:               std_logic_vector(wordsize-1 downto 0);
    signal comp_max1:               std_logic_vector(wordsize-1 downto 0);
    signal comp_max2:               std_logic_vector(wordsize-1 downto 0);
    signal comp_max3:               std_logic_vector(wordsize-1 downto 0);

    signal max_min_min:             integer range 0 to 2**wordsize;     

    signal range_times_255:         integer range 0 to 2**wordsize * 255;     
    signal range_255_div_by_max:    integer range 0 to 2**wordsize * 255;

begin

    hsv2rgb : process(clk, rst)

        variable red_i_int   : integer := 0;
        variable green_i_int : integer := 0;
        variable blue_i_int  : integer := 0;

        variable red_max : boolean := false;
        variable red_min : boolean := false;
        variable green_max : boolean := false;
        variable green_min : boolean := false;
    begin
        if rst = '1' then
            r_min_g <= 0;
            b_min_r <= 0;
            g_min_b <= 0;

            c_x_r_min_g <= 0;
            c_x_b_min_r <= 0;
            c_x_g_min_b <= 0;

            div_c_x_r_min_g <= 0;
            div_c_x_b_min_r <= 0;
            div_c_x_g_min_b <= 0;

            rg_mux_in <= 0;
            br_mux_in <= 0;
            gb_mux_in <= 0;

            mux_select0 <= 0;
            mux_select1 <= 0;
            mux_select2 <= 0;
            mux_select3 <= 0;

            comp_max_out <= (others => '0');
            comp_mid_out <= (others => '0');
            comp_min_out <= (others => '0');

            comp_max0 <= (others => '0');
            comp_max1 <= (others => '0');
            comp_max2 <= (others => '0');
            comp_max3 <= (others => '0');

            max_min_min <= 0;

            range_times_255 <= 0;
            range_255_div_by_max <= 0;

        elsif rising_edge(clk) then

            if enable = '1' then
                
                red_i_int   := to_integer(unsigned(pixel_red_i));
                green_i_int := to_integer(unsigned(pixel_green_i));
                blue_i_int  := to_integer(unsigned(pixel_blue_i));

                -- Comparator
                red_max := (red_i_int > green_i_int) and (red_i_int > blue_i_int);
                red_min := (red_i_int < green_i_int) and (red_i_int < blue_i_int);

                green_max := (green_i_int > red_i_int) and (green_i_int > blue_i_int);
                green_min := (green_i_int < red_i_int) and (green_i_int < blue_i_int);

                -- Determine largest value
                if red_max then
                    comp_max_out <= pixel_red_i;
                    mux_select0 <= 0; 
                elsif green_max then
                    comp_max_out <= pixel_green_i;
                    mux_select0 <= 1;
                else
                    comp_max_out <= pixel_blue_i;
                    mux_select0 <= 2;
                end if;
             
                -- Determine smallest value
                if red_min then
                    comp_min_out <= pixel_red_i;
                elsif green_min then
                    comp_min_out <= pixel_green_i;
                else
                    comp_min_out <= pixel_blue_i;
                end if;

                -- Hue calculation
                r_min_g <= red_i_int - green_i_int;
                b_min_r <= blue_i_int - red_i_int;
                g_min_b <= green_i_int - blue_i_int;

                c_x_r_min_g <= 43 * r_min_g;
                c_x_b_min_r <= 43 * b_min_r;
                c_x_g_min_b <= 43 * g_min_b;

                div_c_x_r_min_g <= c_x_r_min_g / max_min_min;
                div_c_x_b_min_r <= c_x_b_min_r / max_min_min;
                div_c_x_g_min_b <= c_x_g_min_b / max_min_min;

                rg_mux_in <=       div_c_x_r_min_g;
                br_mux_in <=  85 + div_c_x_r_min_g;
                gb_mux_in <= 171 + div_c_x_g_min_b;

                -- mux delay
                mux_select1 <= mux_select0;
                mux_select2 <= mux_select1;
                mux_select3 <= mux_select2;

                -- mux
                if mux_select3 = 1 then
                    pixel_hue_o <= std_logic_vector(to_unsigned(rg_mux_in, wordsize));
                elsif mux_select3 = 2 then
                    pixel_hue_o <= std_logic_vector(to_unsigned(br_mux_in, wordsize));
                else
                    pixel_hue_o <= std_logic_vector(to_unsigned(gb_mux_in, wordsize));
                end if;

                -- Saturation calculation
                range_times_255 <= max_min_min * 255;
                range_255_div_by_max <= range_times_255 / to_integer(unsigned(comp_max3));
                pixel_sat_o <= std_logic_vector(to_unsigned(range_255_div_by_max, wordsize));
 
                -- Value calculation
                comp_max0   <= comp_max_out; 
                comp_max1   <= comp_max0; 
                comp_max2   <= comp_max1; 
                comp_max3   <= comp_max2; 
                pixel_val_o <= comp_max3;

            else
                pixel_hue_o <= (others => '0');
                pixel_sat_o <= (others => '0');
                pixel_val_o <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;

end architecture;
--============================================================================--
