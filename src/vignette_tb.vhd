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

use work.config_const_pkg.all;
use work.curves_pkg.all;

--======================================================================================--

entity vignette_tb is
    generic (
        input_file:           string  := "tst/input_pixel.txt";     --! Input file of test 
        output_file:          string  := "tst/vignette_output.pgm"; --! Output file of test 

        image_width:          integer := 512; --! Width of input image
        image_height:         integer := 512  --! Height of input image
    );
end entity;

--======================================================================================--

architecture structural of vignette_tb is

  --===================component declaration===================--

    component test_bench_driver is
        generic (
            wordsize:           integer := const_wordsize;

            input_file:         string := input_file;
            output_file:        string := output_file;

            clk_period_ns:      time := 1 ns;
            rst_after:          time := 10 ns;
            rst_duration:       time := 10 ns
        );
        port (
            clk:                out std_logic;
            rst:                out std_logic;
            enable:             out std_logic;

            h_count:            out std_logic_vector;
            v_count:            out std_logic_vector;

            pixel_from_file:    out std_logic_vector;

            pixel_to_file:      in std_logic_vector
        );
    end component;

    ----------------------------------------------------------------------------------------------

    component vignette is
        generic (
            wordsize:             integer := const_wordsize;
            width:                integer := image_width;
            height:               integer := image_height;

            lut_x:                array_pixel := create_sine_lut(image_width,  1.0);
            lut_y:                array_pixel := create_sine_lut(image_height, 1.0)
        );
        port (
            clk:                  in std_logic;
            rst:                  in std_logic;
            enable:               in std_logic;

            h_count:              in std_logic_vector;
            v_count:              in std_logic_vector;

            pixel_i:              in std_logic_vector;

            pixel_o:              out std_logic_vector
         );
    end component;

    ----------------------------------------------------------------------------------------------

    --===================signal declaration===================--
    signal clk:                std_logic := '0';
    signal rst:                std_logic := '0';
    signal enable:             std_logic := '0';

    signal h_count:            std_logic_vector((integer(ceil(log2(real(image_width))))-1) downto 0) := (others => '0');
    signal v_count:            std_logic_vector((integer(ceil(log2(real(image_height))))-1) downto 0) := (others => '0');

    signal pixel_from_file:    std_logic_vector((const_wordsize-1) downto 0) := (others => '0');
    signal pixel_to_file:      std_logic_vector((const_wordsize-1) downto 0) := (others => '0');

begin

    --===================component instantiation===================--
    tst_driver: test_bench_driver
        port map(
            clk             => clk,
            rst             => rst,
            enable          => enable,
        
            h_count         => h_count,
            v_count         => v_count,

            pixel_from_file => pixel_from_file,
            pixel_to_file   => pixel_to_file
        );

    device_under_test: vignette
        port map(
            clk             => clk,
            rst             => rst,
            enable          => enable,

            h_count         => h_count,
            v_count         => v_count,

            pixel_i         => pixel_from_file,
            pixel_o         => pixel_to_file
        );

end architecture;
