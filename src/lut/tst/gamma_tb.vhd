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

library test;
use test.test_bench_driver;

--! Use the default constants from the project
library common;
use common.config_const_pkg.all;
--! Use the create_gamma_lut function to generate the lookup table
use common.curves_pkg.all;

--======================================================================================--
--! \entity gamma_tb
--! Testbench for gamma design
--! \param [in] input_file  Input file used for test, must be plain text pnm file with pixel per line
--! \param [in] output_file Output file used for test, will be plain text pnm file with pixel per line
--! \param [in] gamma       Amount of contrast adjustment, see create_gamma_lut for more details.
--! \param [in] c_factor    Amount of contrast adjustment, see create_gamma_lut for more details.
entity gamma_tb is
    generic (
        input_file:           string  := "tst/input/amersfoort_gray.pgm";
        output_file:          string  := "tst/output/gamma_output.pgm";

        gamma:                real    := 0.5;
        c_factor:             real    := 1.0
    );
end entity;

--======================================================================================--
--! Architecture using test_bench_driver to supply input image and write out output image
architecture structural of gamma_tb is

  --===================component declaration===================--
    --! \component test_bench_driver
    component test_bench_driver is
        generic (
            wordsize:           integer := const_wordsize;

            input_file:         string := input_file;
            output_file:        string := output_file;

            clk_period_ns:      time := 1 ns;
            rst_after:          time := 9 ns;
            rst_duration:       time := 8 ns;

            dut_delay:          integer := 3
        );
        port (
            clk:                out std_logic;
            rst:                out std_logic;
            enable:             out std_logic;

            pixel_from_file:    out std_logic_vector((wordsize-1) downto 0);

            pixel_to_file:      in std_logic_vector((wordsize-1) downto 0)
        );
    end component;

    ----------------------------------------------------------------------------------------------

    component lookup_table is
        generic (
            wordsize:      integer     := const_wordsize;
            lut:           array_pixel := create_gamma_lut(2**const_wordsize, gamma, c_factor)
        );
        port (
            clk:           in std_logic;
            rst:           in std_logic;
            enable:        in std_logic;

            pixel_i:       in std_logic_vector((wordsize-1) downto 0);

            pixel_o:       out std_logic_vector((wordsize-1) downto 0)
        );
    end component;

    ----------------------------------------------------------------------------------------------

    --===================signal declaration===================--
    signal clk:                std_logic := '0';
    signal rst:                std_logic := '0';
    signal enable:             std_logic := '0';

    signal pixel_from_file:    std_logic_vector((const_wordsize-1) downto 0) := (others => '0');
    signal pixel_to_file:      std_logic_vector((const_wordsize-1) downto 0) := (others => '0');

begin

    --===================component instantiation===================--
    tst_driver: test_bench_driver
        port map(
            clk             => clk,
            rst             => rst,
            enable          => enable,
        
            pixel_from_file => pixel_from_file,
            pixel_to_file   => pixel_to_file
        );

    device_under_test: lookup_table
        port map(
            clk               => clk,
            rst               => rst,
            enable            => enable,

            pixel_i           => pixel_from_file,
            pixel_o           => pixel_to_file
        );

end architecture;
