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

--! use standard library
library ieee;
--! use std_logic_vector
use ieee.std_logic_1164.all;
--! needed for colorscheme calculations
use ieee.numeric_std.all;
--! used for writing and reading images
use std.textio.all;
--! used only for calculation of constants
use ieee.math_real.all;

use work.image_io_pkg.all;
use work.config_const_pkg.all;

entity test_bench_driver is
    generic (
        wordsize:             integer; --! size of input pixel value in bits

        input_file:           string;
        output_file:          string
    );
    port (
        clk:                in std_logic;       --! completely clocked process
        rst:                in std_logic;       --! asynchronous reset

        pixel_from_file:    out std_logic_vector((wordsize-1) downto 0);       --! the input pixel

        pixel_to_file:      in std_logic_vector((wordsize-1) downto 0)       --! the output pixel
    );
end entity;


architecture behavioural of test_bench_driver is

    --===================signal declaration===================--
    signal enable:                    std_logic := '0';
    signal start:                     std_logic := '0';
    signal end_of_file:               std_logic := '0';

    --===================file declaration===================--
    --! File containing pixels for input of the testbench
    file file_input_pixel: text open read_mode is input_file;

    --! File used as output for the tesbench
    file file_output_pixel: text open write_mode is output_file;

begin

    --=================== release ===============--
    release_process: process(rst, end_of_file)
    begin
        if rst = '1' then
        start <= '1';
        enable <= '1';  -- enable tb
        end if;

        if end_of_file = '1' then
            enable <= '0';
            start <= '0';
            
            assert(1 = 0) report "Input file done" severity failure;
        end if;
    end process;

    --===================process for reading input_pixels ===============--
    reading_input_pixels: process(clk)
        variable li: line;
        variable pixel_value: integer;
    begin
        if rising_edge(clk) then
        if rst = '0' then
            if enable = '1' then

            read_pixel(file_input_pixel, pixel_from_file, end_of_file);

            end if;
        end if;
        end if;
    end process;

    --===================process for writing output ===================================--
    writing_output_file: process( clk )

        constant pgm_width         : integer := const_imagewidth;
        constant pgm_height        : integer := const_imageheight;
        constant max_pixel_value   : integer := 2**wordsize-1;

        variable writeheader: std_logic := '1';

        variable val: integer := 0;

    begin
        if rising_edge(clk) then

        if writeheader = '1' then

            write_pbmplus_header( pgm_width, pgm_height, max_pixel_value, pgm, file_output_pixel );
            writeheader := '0';

        end if;

        -- write output image 
        val := to_integer(unsigned(pixel_to_file));

        write_pixel( val, file_output_pixel);

        end if;
    end process;
end architecture;
