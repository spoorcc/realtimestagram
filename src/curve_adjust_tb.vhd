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
use std.textio.all;

use work.image_io_pkg.all;
use work.config_const_pkg.all;
use work.curves_pkg.all;

--======================================================================================--

entity curve_adjust_tb is
    generic (
        wordsize:             integer := const_wordsize; --! size of input pixel value in bits

        -- image dimensions
        --! TODO: Make image dimensions dependent on the input image
        imageheight:          integer := const_imageheight; --! Image height used of the test_image
        imagewidth:           integer := const_imagewidth   --! Image width used for the test_image
    );
end entity;

--======================================================================================--

architecture curve_adjust_tb of curve_adjust_tb is

  --===================component declaration===================--
  --the design to test
    component lookup_table is
    generic (
        wordsize:             integer;  --! input image wordsize in bits
        lut:                  array_pixel --! pre generated lookup table
    );
    port (
        clk:           in std_logic;       --! completely clocked process
        rst:           in std_logic;       --! asynchronous reset
        enable:        in std_logic;       --! enables block

        pixel_i:       in std_logic_vector((wordsize-1) downto 0);       --! the input pixel

        pixel_o:       out std_logic_vector((wordsize-1) downto 0)       --! the output pixel
    );
    end component;

    ----------------------------------------------------------------------------------------------

    --===================signal declaration===================--
    signal tb_clk:                    std_logic := '0';
    signal rst:                       std_logic := '0';
    signal enable:                    std_logic := '0';
    signal start:                     std_logic := '0';
    signal end_of_file:               std_logic := '0';

    signal tb_input_pixel:            std_logic_vector((wordsize-1) downto 0) := std_logic_vector(to_unsigned(0, const_wordsize));
    signal tb_output_pixel:           std_logic_vector((wordsize-1) downto 0) := std_logic_vector(to_unsigned(0, const_wordsize));


    --===================file declaration===================--
    --! File containing pixels for input of the testbench
    file file_input_pixel: text open read_mode is "tst/input_pixel.txt";

    --! File used as output for the tesbench
    file file_output_pixel: text open write_mode is "tst/output_pixel.pgm";

begin
  --===================component instantiation===================--

  --! Device Under Test
  dut: lookup_table
    generic map(
      wordsize          => wordsize, -- size of input pixel value in bits
      lut               => create_sigmoid_lut(2**wordsize, 5.0)
    )

    port map(
      clk               => tb_clk,
      rst               => rst,
      enable            => enable,

      pixel_i           => tb_input_pixel,
      pixel_o           => tb_output_pixel
    );

  --===================clock===================--
  tb_clk <= not tb_clk after 1 ns;

  --===================rst===================--
  rst <= '0', '1' after 42 ns, '0' after 85 ns;

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
    end if;
  end process;

  --===================process for reading input_pixels ===============--
  reading_input_pixels: process(tb_clk)
    variable li: line;
    variable pixel_value: integer;
  begin
    if rising_edge(tb_clk) then
      if rst = '0' then
        if enable = '1' then

          read_pixel(file_input_pixel, tb_input_pixel, end_of_file);
          assert(end_of_file = '0');

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

    variable val: integer := 0;

  begin
    if rising_edge(tb_clk) then

      if writeheader = '1' then

        write_pbmplus_header( pgm_width, pgm_height, max_pixel_value, pgm, file_output_pixel );

        writeheader := '0';

      end if;

    -- write output image 
    val := to_integer(unsigned(tb_output_pixel));
    write_pixel( val, file_output_pixel);

    end if;
  end process;

end architecture;
