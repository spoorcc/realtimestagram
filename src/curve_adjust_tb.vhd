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



PACKAGE config_const_pkg is

    CONSTANT const_wordsize :integer := 8;

    CONSTANT const_imageheight :integer := 480;
    CONSTANT const_imagewidth  :integer := 640;
    
    CONSTANT const_hor_start_activeimage : integer := 10;
    CONSTANT const_activeimagewidth: integer := const_imagewidth;

    CONSTANT const_blanking_horizontal_left: integer := 10;
END config_const_pkg;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

USE work.image_io_pkg.ALL;
USE work.config_const_pkg.ALL;

--======================================================================================--

ENTITY curve_adjust_tb IS
  GENERIC (
    wordsize:             INTEGER := const_wordsize; -- size of input pixel value in bits

    -- Image dimensions
    imageheight:          INTEGER := const_imageheight;
    imagewidth:           INTEGER := const_imagewidth
  );
END ENTITY;

--======================================================================================--

ARCHITECTURE curve_adjust_tb OF curve_adjust_tb IS

  --===================component declaration===================--
  --the design to test
  COMPONENT curve_adjust IS
    GENERIC (
        wordsize:             integer  --! input image wordsize in bits
    );
    PORT (
        clk:                  in std_logic;       --! completely clocked process
        rst:                  in std_logic;       --! asynchronous reset
        enable:               in std_logic;       --! enables block
        input_pixel:          in std_logic_vector((wordsize-1) downto 0);       --! the input pixel

        output_pixel:         out std_logic_vector((wordsize-1) downto 0)        --! the output pixel
    );
  END COMPONENT;

  ----------------------------------------------------------------------------------------------

  --===================signal declaration===================--
  SIGNAL tb_clk:                    STD_LOGIC := '0';
  SIGNAL rst:                       STD_LOGIC := '0';
  SIGNAL enable:                    STD_LOGIC := '0';
  SIGNAL start:                     STD_LOGIC := '0';

  SIGNAL tb_input_pixel:            STD_LOGIC_VECTOR((wordsize-1) DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, const_wordsize));
  SIGNAL tb_output_pixel:           STD_LOGIC_VECTOR((wordsize-1) DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, const_wordsize));

  SIGNAL hcount:                    STD_LOGIC_VECTOR(12 DOWNTO 0);
  SIGNAL vcount:                    STD_LOGIC_VECTOR(10 DOWNTO 0);

  --===================file declaration===================--
  --opening a file in read mode for input pixels
  FILE file_input_pixel: TEXT OPEN READ_MODE IS "../tst/input_pixel.txt";

  --opening a file in write mode for output
  FILE file_output_pixel: TEXT OPEN WRITE_MODE IS "../tst/output_pixel.pgm";

BEGIN
  --===================component instantiation===================--

  -- instantiate a
  dut: curve_adjust
    GENERIC MAP(
      wordsize          => wordsize -- size of input pixel value in bits
    )

    PORT MAP(
      clk               => tb_clk,
      rst               => rst,
      enable            => enable,

      input_pixel       => tb_input_pixel,

      output_pixel      => tb_output_pixel
    );

  --===================clock===================--
  tb_clk <= NOT tb_clk AFTER 1 ns;

  --===================rst===================--
  rst <= '0', '1' AFTER 42 ns, '0' AFTER 85 ns;

  --=================== release ===============--
  RELEASE_PROCESS: PROCESS(rst)
  BEGIN
    IF rst = '1' THEN
      start <= '1';
      enable <= '1';  -- ENABLE tb
    END IF;
  END PROCESS;

  --===================line counters===================--
  LINE_COUNTERS: PROCESS(tb_clk)
    variable hcount_temp: unsigned(hcount'high downto 0) := "0000000000000";
    variable vcount_temp: unsigned(vcount'high downto 0) := "00000010011";
  BEGIN
    IF RISING_EDGE(tb_clk) THEN
      IF rst = '1' THEN
        hcount      <= (others => '0');
        vcount      <= STD_LOGIC_VECTOR(to_unsigned(19, vcount'length));--"00000010011";--(OTHERS => '0');

      ELSE -- rst = '0'
        IF hcount = STD_LOGIC_VECTOR(to_unsigned(const_hor_start_activeimage+const_activeimagewidth-1, hcount'length)) then --"1000111011111" THEN -- 4575
          hcount_temp := to_unsigned(0, hcount_temp'length); --"0000000000000";
          IF vcount = STD_LOGIC_VECTOR(to_unsigned(1124, vcount'length)) then --"10001100100" THEN  --1124
            vcount_temp := to_unsigned(0, vcount_temp'length);--(OTHERS => '0');
          ELSE
            vcount_temp := unsigned(vcount) + 1;
          END IF;
        ELSIF hcount = STD_LOGIC_VECTOR(to_unsigned(const_blanking_horizontal_left-1, hcount'length)) THEN --"0001011001111" THEN  --719
          hcount_temp := to_unsigned(0, hcount'length); --"0000000000000";
          hcount_temp(12) := '1';
        ELSE
          hcount_temp := unsigned(hcount) + 1;
        END IF;

        hcount <= STD_LOGIC_VECTOR(hcount_temp);
        vcount <= STD_LOGIC_VECTOR(vcount_temp);

      END IF;
    END IF;
  END PROCESS;

  --===================process for reading input_pixels ===============--
  READING_INPUT_PIXELS: PROCESS(tb_clk)
    VARIABLE li: LINE;
    VARIABLE pixel_value: INTEGER;
  BEGIN
    IF RISING_EDGE(tb_clk) THEN
      IF rst = '0' THEN
        IF enable = '1' THEN

          IF (NOT ENDFILE(file_input_pixel)) THEN
            READLINE(file_input_pixel, li);
            READ(li, pixel_value);
            tb_input_pixel<= STD_LOGIC_VECTOR(to_unsigned(pixel_value, tb_input_pixel'length));
          END IF;

        END IF;
      END IF;
    END IF;
  END PROCESS;

  --===================process for writing output ===================================--
  WRITING_OUTPUT_FILE: PROCESS( tb_clk )

    CONSTANT pgm_width         : INTEGER := const_imagewidth;
    CONSTANT pgm_height        : INTEGER := const_imageheight;
    CONSTANT max_pixel_value   : INTEGER := 2**wordsize-1;

    VARIABLE writeheader: STD_LOGIC := '1';

    VARIABLE val: INTEGER := 0;

  BEGIN
    IF RISING_EDGE(tb_clk) THEN

      IF writeheader = '1' THEN

        write_pbmplus_header( pgm_width, pgm_height, max_pixel_value, pgm, file_output_pixel );

        writeheader := '0';

      END IF;

    -- write depth map...
    val := to_INTEGER(unsigned(tb_output_pixel));
    write_pixel( val, file_output_pixel);

    END IF;
  END PROCESS;

END ARCHITECTURE;
