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

entity test_bench_driver_color is
    generic (
        wordsize:             integer; --! size of input pixel value in bits

        input_file:           string;
        output_file:          string;

        clk_period_ns:        time  := 2 ns;
        rst_after:            time  := 10 ns;
        rst_duration:         time  := 10 ns;

        --! Number of clk pulses of delay of a Device Under Test between input and output 
        dut_delay:            integer := 1; 

        h_count_size:         integer := integer(ceil(log2(real(const_imagewidth))));
        v_count_size:         integer := integer(ceil(log2(real(const_imageheight))))
    );
    port (
        clk:                out std_logic;       --! completely clocked process
        rst:                out std_logic;       --! asynchronous reset
        enable:             out std_logic;
       
        h_count:            out std_logic_vector(h_count_size-1 downto 0) := (others => '0');
        v_count:            out std_logic_vector(v_count_size-1 downto 0) := (others => '0');

        red_pixel_from_file:    out std_logic_vector((wordsize-1) downto 0);       --! the input pixel
        green_pixel_from_file:  out std_logic_vector((wordsize-1) downto 0);       --! the input pixel
        blue_pixel_from_file:   out std_logic_vector((wordsize-1) downto 0);       --! the input pixel

        red_pixel_to_file:      in std_logic_vector((wordsize-1) downto 0);       --! the output pixel
        green_pixel_to_file:    in std_logic_vector((wordsize-1) downto 0);       --! the output pixel
        blue_pixel_to_file:     in std_logic_vector((wordsize-1) downto 0)       --! the output pixel
    );
end entity;


architecture behavioural of test_bench_driver_color is

    --===================signal declaration===================--
    signal tb_clk:                    std_logic := '0';
    signal tb_rst:                    std_logic := '0';
    signal tb_enable:                 std_logic := '0';

    signal tb_done:                   std_logic := '0';
    signal dut_data_valid:            std_logic := '0';

    signal end_of_file:               std_logic := '0';

    signal red_pixel_tmp:   std_logic_vector(wordsize-1 downto 0) := (others => '0');
    signal green_pixel_tmp: std_logic_vector(wordsize-1 downto 0) := (others => '0');
    signal blue_pixel_tmp:  std_logic_vector(wordsize-1 downto 0) := (others => '0');

    --===================file declaration===================--
    --! File containing pixels for input of the testbench
    file file_input_pixel: text open read_mode is input_file;

    --! File used as output for the tesbench
    file file_output_pixel: text open write_mode is output_file;

begin
     --===================rst===================--
     tb_rst <= '0', '1' after rst_after, '0' after rst_after+rst_duration when (tb_done = '0');
     rst <= tb_rst;

     --===================clock===================--
     tb_clk <= not tb_clk after clk_period_ns when (tb_done = '0');
     clk <= tb_clk;

    --=================== enable ===============--
    enable <= tb_enable;

    --=================== release ===============--
    release_process: process(tb_clk, tb_rst, end_of_file)

        variable pre_delay_count  : integer := dut_delay;
        variable post_delay_count : integer := dut_delay - 1;
    begin
        
        if rising_edge(tb_clk) then

            if tb_rst = '1' then
                tb_enable <= '1';  -- enable tb
            end if;

            if tb_enable = '1' and tb_rst = '0' then

                if pre_delay_count > 0 then
                    pre_delay_count := pre_delay_count - 1;
                else
                    dut_data_valid <= '1';
                end if;    

            end if;

            if end_of_file = '1' or post_delay_count < dut_delay-1 then

                if post_delay_count > 0 then
                    post_delay_count := post_delay_count - 1;
                else
                    tb_enable <= '0';
                    tb_done <= '1';
                end if;
                
            end if;
        end if;
    end process;

    --===================process for reading input_pixels ===============--
    reading_input_pixels: process(tb_clk)

        constant pgm_width         : integer := const_imagewidth;
        constant pgm_height        : integer := const_imageheight;
        constant max_pixel_value   : integer := 2**wordsize-1;

        variable readheader: std_logic := '1';
    begin

        red_pixel_from_file   <= red_pixel_tmp;
        green_pixel_from_file <= green_pixel_tmp;
        blue_pixel_from_file  <= blue_pixel_tmp;

        if rising_edge(tb_clk) then

            if readheader = '1' then

                read_pbmplus_header( pgm_width, pgm_height, max_pixel_value, ppm, file_input_pixel );
                readheader := '0';

            end if;

            if tb_rst = '0' then
                if tb_enable = '1' and end_of_file = '0' then

                    read_rgb_pixel(file_input_pixel, red_pixel_tmp, green_pixel_tmp, blue_pixel_tmp, end_of_file);

                end if;
            end if;
        end if;
    end process;

    --===================process for writing output ===================================--
    writing_output_file: process( tb_clk )

        constant pgm_width         : integer := const_imagewidth;
        constant pgm_height        : integer := const_imageheight;
        constant max_pixel_value   : integer := 2**wordsize-1;

        variable writeheader: std_logic := '1';

        variable r_val: integer := 0;
        variable g_val: integer := 0;
        variable b_val: integer := 0;

    begin
        if rising_edge(tb_clk) then

            if writeheader = '1' then

                write_pbmplus_header( pgm_width, pgm_height, max_pixel_value, ppm, file_output_pixel );
                writeheader := '0';

            end if;

            if tb_enable = '1' and tb_rst = '0' and dut_data_valid = '1' then
                
                -- write output image 
                r_val := to_integer(unsigned(red_pixel_to_file));
                g_val := to_integer(unsigned(green_pixel_to_file));
                b_val := to_integer(unsigned(blue_pixel_to_file));

                write_rgb_pixel( r_val, g_val, b_val, file_output_pixel);

            end if;

        end if;
    end process;

    --=================== process for pixel counts ===================================--
    h_and_v_counters: process( tb_clk )

        constant pgm_width         : integer := const_imagewidth;
        constant pgm_height        : integer := const_imageheight;

        variable h_count_var       : integer range 0 to const_imagewidth := 0;
        variable v_count_var       : integer range 0 to const_imageheight := 0;

    begin
        if rising_edge(tb_clk) then

            if  tb_enable = '1' and tb_rst = '0' then
            
                if h_count_var < const_imagewidth-1 then
                    h_count_var := h_count_var + 1;
                else
                    h_count_var := 0;

                    if v_count_var < const_imageheight-1 then
                        v_count_var := v_count_var + 1;
                    else
                        v_count_var := 0;
                    end if;
                end if;

                h_count <= std_logic_vector(to_unsigned(h_count_var, h_count_size)); 
                v_count <= std_logic_vector(to_unsigned(v_count_var, v_count_size)); 

            end if;

        end if;
    end process;
end architecture;
