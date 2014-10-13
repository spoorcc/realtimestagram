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

use work.config_const_pkg.all;
use work.curves_pkg.all;

--======================================================================================--

entity curve_adjust_tb is
    generic (
        wordsize:             integer := const_wordsize; --! size of input pixel value in bits

        input_file:           string  := "tst/input_pixel.txt"; 
        output_file:          string  := "tst/sigmoid_output.pgm";

        c_factor:             real    := 5.0
    );
end entity;

--======================================================================================--

architecture structural of curve_adjust_tb is

  --===================component declaration===================--

    component test_bench_driver is
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
    end component;

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
    signal tb_clk:                std_logic := '0';
    signal rst:                   std_logic := '0';
    signal enable:                std_logic := '0';

    signal tb_input_pixel:        std_logic_vector((wordsize-1) downto 0) := std_logic_vector(to_unsigned(0, const_wordsize));
    signal tb_output_pixel:       std_logic_vector((wordsize-1) downto 0) := std_logic_vector(to_unsigned(0, const_wordsize));

begin
  --===================component instantiation===================--


  tst_driver: test_bench_driver
    generic map(
        wordsize     => wordsize,

        input_file   => input_file,
        output_file  => output_file
    )

    port map(
        clk          => tb_clk,
        rst          => rst,
    
        pixel_from_file => tb_input_pixel,
        pixel_to_file   => tb_output_pixel
    );

  --! Device Under Test
  dut: lookup_table
    generic map(
      wordsize          => wordsize, -- size of input pixel value in bits
      lut               => create_sigmoid_lut(2**wordsize, c_factor)
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

    process(tb_clk)
    begin
        if rst = '1' then
            enable <= '1';
        end if;
        
    end process;

end architecture;
