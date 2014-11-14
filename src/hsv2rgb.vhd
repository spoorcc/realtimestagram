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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Used for calculation of h_count and v_count port width
use ieee.math_real.all;

--============================================================================--
--! \class hsv2rgb
--! \brief Creates Red Green and Blue channels from Hue Saturation Value inputs
--!
--! Calculation of RGB to HSV
--! ---------------
--! \f[I_{RGB} = \left\{\begin{matrix}
--! \{V,V-VS,V-VSH_{LSB}\}, & H_{MSB}=0 \\ 
--! \{V,V-VS(1-H_{LSB}),V-VS\}, & H_{MSB}=1 \\
--! \{V-VSH_{LSB},V,V-VS\}, & H_{MSB}=2 \\
--! \{V-VS,V,V-VS(1-H_{LSB})\}, & H_{MSB}=3 \\
--! \{V-VS,V-VSH_{LSB},V\}, & H_{MSB}=4 \\
--! \{V-VS(1-H_{LSB}),V-VS,V\}, & H_{MSB}=5 
--! \end{matrix}\right.\f]
--!

entity hsv2rgb is
  generic (
    wordsize:             integer := 8    --! input image wordsize in bits
  );
  port (

    -- inputs
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block

    -- inputs
    pixel_hue_i:          in std_logic_vector((wordsize-1) downto 0); --! hue value of pixel
    pixel_sat_i:          in std_logic_vector((wordsize-1) downto 0); --! saturation of pixel
    pixel_val_i:          in std_logic_vector((wordsize-1) downto 0); --! value of pixel

    pixel_red_o:          out std_logic_vector((wordsize-1) downto 0); --! red output pixel
    pixel_green_o:        out std_logic_vector((wordsize-1) downto 0); --! green output pixel
    pixel_blue_o:         out std_logic_vector((wordsize-1) downto 0)  --! blue output pixel
  );

    -- Types for radhakrishan architecture
    type s_t_v_delay       is array(0 to 2) of integer range 0 to 2**(wordsize*2);
    type s_t_v_min_v_delay is array(0 to 3) of integer range 0 to 2**(wordsize*2);
    type v_delay           is array(0 to 5) of integer range 0 to 2**wordsize;

    -- Types for bailey architecture
    type val_delay         is array(0 to 2) of integer range 0 to 2**wordsize;
    type h_msb_delay       is array(0 to 2) of integer range 0 to 6;

end entity;

--============================================================================--

architecture presentation of hsv2rgb is
    
    -- signal declarations
    signal hue_times_3:            integer range 0 to 3 * 2**wordsize;       --! Input Hue pixel * 3
    signal hue_t3_div128:          integer range 0 to 3 * 2**wordsize;       --! 128 / hue_times_3
    signal hue_t3_d128_t8192:      integer range 0 to 8192*3 * 2**wordsize;  --! 8192 * (128 / hue_times_3)
    
    signal hue_d0:                 integer range 0 to 2**wordsize;       --! Delayed input Hue
    signal hue_t255:               integer range 0 to 255*(2**wordsize); --! input Hue * 255
    signal hue_t255_d0:            integer range 0 to 255*(2**wordsize); --! Delayed input Hue * 255

    signal hue_min:                integer range 0 to 8192*3 * 2**wordsize; --! 8192 * (128 / hue_times_3) - 255 * Hue
    signal hue_min_d0:             integer range 0 to 8192*3 * 2**wordsize; --! 8192 * (128 / hue_times_3) - 255 * Hue
    signal hue_min_d1:             integer range 0 to 8192*3 * 2**wordsize; --! 8192 * (128 / hue_times_3) - 255 * Hue

    signal hue_times_val_sat:      integer range 0 to 8192*128*2**(wordsize+1); --! Hue * Val*Sat

    signal hue_t_val_sat_min_val:  integer range 0 to 8192*128*2**(wordsize+1); --! Hue*Val*Sat-Val

    signal hue_t_val_sat_plus_sat: integer range 0 to 8192*128*2**(wordsize+1)+2**wordsize; --! Hue*Val*Sat+Sat

    signal sat_times_val:          s_t_v_delay;

    signal sat_t_val_minus_val:    s_t_v_min_v_delay;

    signal val:                    v_delay;
begin

    hsv2rgb : process(clk, rst)

        variable hue_i_int : integer range 0 to 2**wordsize := 0;
        variable sat_i_int : integer range 0 to 2**wordsize := 0;
        variable val_i_int : integer range 0 to 2**wordsize := 0;
        
        variable hue_slv    : std_logic_vector((integer(ceil(log2(real(8192*128))))-1) downto 0) := (others => '0'); 
        variable mux_select : std_logic_vector(2 downto 0) := (others => '0');

    begin
        if rst = '1' then

           hue_times_3 <= 0;
           hue_t3_div128 <= 0;
           hue_t3_d128_t8192 <= 0;
    
           hue_d0 <= 0;
           hue_t255 <= 0;
           hue_t255_d0 <= 0;

           hue_min <= 0;
           hue_min_d0 <= 0;
           hue_min_d1 <= 0;

           hue_times_val_sat <= 0;

           hue_t_val_sat_min_val <= 0;

           hue_t_val_sat_plus_sat <= 0;

           sat_times_val <= (others => 0);
           sat_t_val_minus_val <= (others => 0);

           val <= (others => 0);

        elsif rising_edge(clk) then

            if enable = '1' then
                
                hue_i_int := to_integer(unsigned(pixel_hue_i));
                sat_i_int := to_integer(unsigned(pixel_sat_i));
                val_i_int := to_integer(unsigned(pixel_val_i));

                hue_times_3 <= hue_i_int * 3;
                hue_t3_div128 <= hue_times_3 / 128;
                hue_t3_d128_t8192 <= hue_t3_div128 * 8192;     
                                       
                hue_d0 <= hue_i_int;     
                hue_t255 <= hue_d0 * 255;   
                hue_t255_d0 <= hue_t255;
                                       
                if hue_t3_d128_t8192 >= hue_t255_d0 then
                    hue_min    <= hue_t3_d128_t8192 - hue_t255_d0;
                else
                    hue_min    <= 0;
                end if;

                hue_min_d0 <= hue_min;
                hue_min_d1 <= hue_min_d0;

                hue_times_val_sat <= hue_min * sat_times_val(2);

                if hue_times_val_sat /= 0 then
                    hue_t_val_sat_min_val <= hue_times_val_sat - val(4);
                else
                    hue_t_val_sat_min_val <= 0;
                end if;

                hue_t_val_sat_plus_sat <= hue_times_val_sat + sat_t_val_minus_val(2);

                sat_times_val(0) <= sat_i_int * val_i_int;
                sat_t_val_minus_val(0) <= sat_times_val(0) - val(1);

                val(0) <= val_i_int;

                sat_times_val(1 to 2) <= sat_times_val(0 to 1);

                sat_t_val_minus_val(1 to 3) <= sat_t_val_minus_val(0 to 2);

                val(1 to 5) <= val(0 to 4);

                -- Mux output selection
                hue_slv    := std_logic_vector(to_unsigned(hue_min_d1, hue_slv'length));
                mux_select := hue_slv(hue_slv'high downto hue_slv'high-2);

                output_mux: case mux_select is
                    when "000" =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(val(5), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(hue_t_val_sat_plus_sat, wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(sat_t_val_minus_val(3), wordsize));
                    when "001" =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(hue_t_val_sat_min_val, wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(val(5), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(sat_t_val_minus_val(3), wordsize));
                    when "010" =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(sat_t_val_minus_val(3), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(val(5), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(hue_t_val_sat_plus_sat, wordsize));
                    when "011" =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(sat_t_val_minus_val(3), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(hue_t_val_sat_min_val, wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(val(5), wordsize));
                    when "100" =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(hue_t_val_sat_plus_sat, wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(sat_t_val_minus_val(3), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(val(5), wordsize));
                    when "101" =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(val(5), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(sat_t_val_minus_val(3), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(hue_t_val_sat_min_val, wordsize));
                    when others =>
                        pixel_red_o   <= (others => '0');
                        pixel_green_o <= (others => '0');
                        pixel_blue_o  <= (others => '0');
                end case output_mux;
            else
                pixel_red_o <= (others => '0');
                pixel_green_o <= (others => '0');
                pixel_blue_o <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;

end architecture;
--============================================================================--

architecture bailey of hsv2rgb is

    constant degrees60:             integer := 60*256/360;
    
    signal val_times_sat:           integer range 0 to 2**(wordsize*2);

    signal val_min_valsat:          integer range 0 to 2**(wordsize*2);

    --signal hue_lsb:                 integer range 0 to degrees60;
    signal hue_lsb:                 integer range 0 to 2**wordsize;
    signal hue_msb:                 h_msb_delay;

    signal hue_msb_odd:             integer range 0 to 1;

    signal one_min_hue_lsb:         integer range 0 to 2**wordsize;

    signal valsat_t_hue_lsb:        integer range 0 to 2**(wordsize*3);
 
    signal val:                     val_delay;
begin

    hsv2rgb : process(clk, rst)

        variable hue_i_int : integer range 0 to 2**wordsize := 0;
        variable sat_i_int : integer range 0 to 2**wordsize := 0;
        variable val_i_int : integer range 0 to 2**wordsize := 0;
        
    begin
        if rst = '1' then

           val_times_sat <= 0;

           val_min_valsat <= 0;

           hue_lsb <= 0;
           hue_msb <= (others => 0);

           hue_msb_odd <= 0;

           one_min_hue_lsb <= 0;

           valsat_t_hue_lsb <= 0; 

           val <= (others => 0);

        elsif rising_edge(clk) then

            if enable = '1' then
                
                hue_i_int := to_integer(unsigned(pixel_hue_i));
                sat_i_int := to_integer(unsigned(pixel_sat_i));
                val_i_int := to_integer(unsigned(pixel_val_i));

                val_times_sat <= val_i_int * sat_i_int;

                val(0) <= val_i_int;
                val(1 to 2) <= val(0 to 1);

                val_min_valsat <= 2**wordsize * val(0) - val_times_sat;

                hue_lsb    <= (hue_i_int mod degrees60) * 6; 
                hue_msb(0) <= hue_i_int / degrees60; 

                hue_msb_odd <= hue_msb(0) mod 2;

                hue_msb(1 to 2) <= hue_msb(0 to 1);

                if hue_msb_odd = 1 then
                    one_min_hue_lsb <= 2**wordsize - hue_lsb;
                else
                    one_min_hue_lsb <= hue_lsb;
                end if;

                valsat_t_hue_lsb <= one_min_hue_lsb * val_times_sat; 

                -- Mux output selection
                output_mux: case hue_msb(2) is
                    when 5 =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(val(2), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(val_min_valsat/2**wordsize, wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(valsat_t_hue_lsb/2**(wordsize*2), wordsize));
                    when 0 =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(val(2), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(valsat_t_hue_lsb/2**(wordsize*2), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(val_min_valsat/2**wordsize, wordsize));
                    when 1 =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(valsat_t_hue_lsb/2**(wordsize*2), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(val(2), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(val_min_valsat/2**wordsize, wordsize));
                    when 2 =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(val_min_valsat, wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(val(2), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(valsat_t_hue_lsb/2**(wordsize*2), wordsize));
                    when 3 =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(val_min_valsat/2**wordsize, wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(valsat_t_hue_lsb/2**(wordsize*2), wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(val(2), wordsize));
                    when 4 =>
                        pixel_red_o   <= std_logic_vector(to_unsigned(valsat_t_hue_lsb/2**(wordsize*2), wordsize));
                        pixel_green_o <= std_logic_vector(to_unsigned(val_min_valsat/2**wordsize, wordsize));
                        pixel_blue_o  <= std_logic_vector(to_unsigned(val(2), wordsize));
                    when others =>
                        pixel_red_o   <= (others => '0');
                        pixel_green_o <= (others => '0');
                        pixel_blue_o  <= (others => '0');
                end case output_mux;
            else
                pixel_red_o   <= (others => '0');
                pixel_green_o <= (others => '0');
                pixel_blue_o  <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;

end architecture;
--============================================================================--
