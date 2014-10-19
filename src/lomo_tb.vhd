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

entity lomo_tb is
    generic (
        input_file:           string  := "tst/amersfoort.pnm"; --! Input file of test 
        output_file:          string  := "tst/lomo_output.pnm"; --! Output file of test 

        image_width:          integer := const_imagewidth; --! Width of input image
        image_height:         integer := const_imageheight  --! Height of input image
    );
end entity;

--======================================================================================--

architecture structural of lomo_tb is

  --===================component declaration===================--

    component test_bench_driver_color is
        generic (
            wordsize:           integer := const_wordsize;

            input_file:         string := input_file;
            output_file:        string := output_file;

            clk_period_ns:      time := 1 ns;
            rst_after:          time := 9 ns;
            rst_duration:       time := 8 ns;

            dut_delay:          integer := 4
        );
        port (
            clk:                out std_logic;
            rst:                out std_logic;
            enable:             out std_logic;

            h_count:            out std_logic_vector;
            v_count:            out std_logic_vector;

            red_pixel_from_file:    out std_logic_vector;
            green_pixel_from_file:  out std_logic_vector;
            blue_pixel_from_file:   out std_logic_vector;

            red_pixel_to_file:      in std_logic_vector;
            green_pixel_to_file:    in std_logic_vector;
            blue_pixel_to_file:     in std_logic_vector
        );
    end component;

    ----------------------------------------------------------------------------------------------

    component lomo is
    generic (
        wordsize:             integer := wordsize;    --! input image wordsize in bits
        image_width:          integer := image_width;   --! width of input image
        image_height:         integer := image_height   --! height of input image

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
    end component;

    ----------------------------------------------------------------------------------------------

    --===================signal declaration===================--
    signal clk:                      std_logic := '0';
    signal rst:                      std_logic := '0';
    signal enable:                   std_logic := '0';

    signal h_count:                  std_logic_vector((integer(ceil(log2(real(image_width))))-1) downto 0) := (others => '0');
    signal v_count:                  std_logic_vector((integer(ceil(log2(real(image_height))))-1) downto 0) := (others => '0');

    signal red_pixel_from_file:      std_logic_vector((const_wordsize-1) downto 0) := (others => '0');
    signal green_pixel_from_file:    std_logic_vector((const_wordsize-1) downto 0) := (others => '0');
    signal blue_pixel_from_file:     std_logic_vector((const_wordsize-1) downto 0) := (others => '0');

    signal red_pixel_to_file:        std_logic_vector((const_wordsize-1) downto 0) := (others => '0');
    signal green_pixel_to_file:      std_logic_vector((const_wordsize-1) downto 0) := (others => '0');
    signal blue_pixel_to_file:       std_logic_vector((const_wordsize-1) downto 0) := (others => '0');

begin

    --===================component instantiation===================--
    tst_driver: test_bench_driver_color
        port map(
            clk             => clk,
            rst             => rst,
            enable          => enable,
        
            h_count         => h_count,
            v_count         => v_count,

            red_pixel_from_file   => red_pixel_from_file,
            green_pixel_from_file => green_pixel_from_file,
            blue_pixel_from_file  => blue_pixel_from_file,

            red_pixel_to_file   => red_pixel_to_file,
            green_pixel_to_file => green_pixel_to_file,
            blue_pixel_to_file  => blue_pixel_to_file
        );

    device_under_test: lomo
        port map(
            clk             => clk,
            rst             => rst,
            enable          => enable,

            h_count         => h_count,
            v_count         => v_count,

            pixel_red_i     => red_pixel_from_file,
            pixel_green_i   => green_pixel_from_file,
            pixel_blue_i    => blue_pixel_from_file,

            pixel_red_o     => red_pixel_to_file,
            pixel_green_o   => green_pixel_to_file,
            pixel_blue_o    => blue_pixel_to_file

        );

end architecture;
