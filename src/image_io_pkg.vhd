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
--! \class image_io_pkg
--! \brief Provides functionality for easy reading and writing of netbpm images
--!
--! Supported image types
--! ---------------------
--!
--!    Type | Description
--!    -----|----------------------------------------------------------
--!    pbm  | Supports monochrome bitmaps (1 bit per pixel).
--!    pgm  | Supports greyscale images.  Reads  either  pbm  or  pgm formats and writes pgm format.
--!    ppm  | Supports full-color images.  Reads either pbm, pgm,  or ppm formats, writes ppm format.
--!    pnm  | Supports content-independent manipulations  on  any  of the  three  formats  listed  above,
--!    .    | as well as external formats having multiple types.  Reads either pbm,  pgm, or  ppm  formats,
--!    .    | and generally writes the same type as it read (whenever a pnm tool  makes  an  exception
--!    .    | and "promotes"  a  file  to a higher format, it informs the user).
--!
--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>

--! Use standard library
library ieee;
--! Use std_logic_vector
use ieee.std_logic_1164.all;
--! Needed for colorscheme calculations
use ieee.numeric_std.all;
--! Used for writing and reading images
USE std.textio.all;


package image_io_pkg is

	--! Three types can be selected, these types are specified in the detailed description
	TYPE pbmplustype IS (PBM, PGM, PPM);

	--! To accomodate for unknown arrays of pixels array writing is also possible
	TYPE pixel_array IS ARRAY ( INTEGER RANGE <> ) OF INTEGER;

	--! Generic procedure for writing pbm plus headers
	--! @param[in] p_width     Width of image in pixels
	--! @param[in] p_height    Height of image in pixels
	--! @param[in] max_value   Maximum pixel value possible
	--! @param[in] type_of_pbm Image type used to determine magic identifier
	--! @param[in] p_file      Opened target file to write header to

	PROCEDURE write_pbmplus_header( CONSTANT p_width  : IN INTEGER;			
                                	CONSTANT p_height : IN INTEGER;
                                	CONSTANT max_value  : IN INTEGER;
                                	CONSTANT type_of_pbm : IN pbmplustype;

                                	FILE p_file : TEXT           	);

    ----------------------------------------------------------------------     								
    --! Generic procedure for writing single pixel value from variable to pbm file                  								
	PROCEDURE write_pixel( VARIABLE pixel:  IN INTEGER;                      							
                            FILE pbmplus_file : TEXT       );

	--! Generic procedure for writing single pixel value from signal to pbm file
	PROCEDURE write_pixel( SIGNAL pixel:  IN STD_LOGIC_VECTOR;                      							
                           FILE pbmplus_file : TEXT       );

	----------------------------------------------------------------------

	--! Generic procedure to write binary variable of a file
	--! The header must be written with PBM  as image type
	PROCEDURE write_bin_pixel( VARIABLE pixel:  IN BOOLEAN;                      							
                           	   FILE pbmplus_file : TEXT       );

	--! Generic procedure to write binary signal of a file
	--! The header must be written with PBM  as image type
	PROCEDURE write_bin_pixel( SIGNAL pixel:  IN STD_LOGIC;                      							
                           	   FILE pbmplus_file : TEXT       );

    ------------------------------------------------------------------------

	--! Generic procedure to write rgb variable of a file
	--! The header must be written with PPM as image type
    PROCEDURE write_rgb_pixel( VARIABLE pixel_r:  IN INTEGER;
    						   VARIABLE pixel_g:  IN INTEGER;
    						   VARIABLE pixel_b:  IN INTEGER;	

                           	   FILE pbmplus_file : TEXT       );

	--! Generic procedure to write rgb signal of a file
	--! The header must be written with PPM as image type
	PROCEDURE write_rgb_pixel( 	SIGNAL pixel_r:  IN UNSIGNED(7 DOWNTO 0);
								SIGNAL pixel_g:  IN UNSIGNED(7 DOWNTO 0);
								SIGNAL pixel_b:  IN UNSIGNED(7 DOWNTO 0);

                           	   	FILE pbmplus_file : TEXT       );

	------------------------------------------------------------------------

	--! Generic procedure to write ycbcr variable of a file
	--! The header must be written with PPM as image type
	PROCEDURE write_ycbcr_pixel( 	VARIABLE pixel_y:   IN INTEGER;
    						   		VARIABLE pixel_cb:  IN INTEGER;
    						   		VARIABLE pixel_cr:  IN INTEGER;	

                           	   		FILE pbmplus_file : TEXT       );

	--! Generic procedure to write ycbcr signal of a file
	--! The header must be written with PPM as image type
	PROCEDURE write_ycbcr_pixel( 	SIGNAL pixel_y:   IN UNSIGNED(9 DOWNTO 0);
									SIGNAL pixel_cb:  IN UNSIGNED(9 DOWNTO 0);
									SIGNAL pixel_cr:  IN UNSIGNED(9 DOWNTO 0);

                           	   		FILE pbmplus_file : TEXT       );	

	---------------------------------------------------------------------------

	--! Procedure to convert rgb variables into corresponding ycbcr components
	PROCEDURE rgb_to_ycbcr( VARIABLE R : IN UNSIGNED(7 DOWNTO 0);
							VARIABLE G : IN UNSIGNED(7 DOWNTO 0);
							VARIABLE B : IN UNSIGNED(7 DOWNTO 0);

							VARIABLE Y  : OUT UNSIGNED(9 DOWNTO 0);
							VARIABLE Cb : OUT UNSIGNED(9 DOWNTO 0);
							VARIABLE Cr : OUT UNSIGNED(9 DOWNTO 0)	);

	--! Procedure to convert ycbcr variables into corresponding rgb components
	PROCEDURE ycbcr_to_rgb( VARIABLE Y  : IN UNSIGNED(9 DOWNTO 0);
							VARIABLE Cb : IN UNSIGNED(9 DOWNTO 0);
							VARIABLE Cr : IN UNSIGNED(9 DOWNTO 0);

							VARIABLE R : OUT UNSIGNED(7 DOWNTO 0);
							VARIABLE G : OUT UNSIGNED(7 DOWNTO 0);
							VARIABLE B : OUT UNSIGNED(7 DOWNTO 0)	);

	--! Function to pad strings with a fill character
	--! \param[in] arg_str      The input string that has to be padded
	--! \param[in] ret_len_c    The length of the output string. (Must be larger than length of the input string)
	--! \param[in] fill_char_c  The filling character that should be used to pad the input string
	--! \returns  string arg_str padded up to length ret_len_c with charachter fill_char_c
	FUNCTION pad_string( 	arg_str : 		string;
							ret_len_c : 	natural   := 10;
							fill_char_c : 	character := ' ' )

							RETURN string;

END;

package body image_io_pkg is

--======================================================================================--

	PROCEDURE write_pbmplus_header (

		CONSTANT p_width  : IN INTEGER;				
		CONSTANT p_height : IN INTEGER;				
		CONSTANT max_value  : IN INTEGER;			

		CONSTANT type_of_pbm : IN pbmplustype;

		FILE p_file : TEXT

		) IS
		
	    CONSTANT width_height     : STRING := INTEGER'IMAGE(p_width) & " " & INTEGER'IMAGE(p_height);
	    CONSTANT maximum_value    : STRING := INTEGER'IMAGE(max_value);

	    VARIABLE magic_identifier : STRING(1 TO 2) := "P0";
	    VARIABLE text_line:    LINE;

	BEGIN
	
	  	CASE type_of_pbm IS
	  		WHEN PBM  	=> magic_identifier := "P1";
	  		WHEN PGM  	=> magic_identifier := "P2";
	  		WHEN PPM  	=> magic_identifier := "P3";
	  		WHEN OTHERS => magic_identifier := "P1";
	  	END CASE;

		--Write the header
		WRITE( text_line, magic_identifier);
		WRITELINE( p_file, text_line);

		WRITE( text_line, width_height);
		WRITELINE( p_file, text_line);

		WRITE( text_line, maximum_value);
		WRITELINE( p_file, text_line );
	
	END PROCEDURE write_pbmplus_header;

--======================================================================================--

	PROCEDURE write_pixel(
	
	   VARIABLE pixel:  IN INTEGER;
                      							
    	FILE pbmplus_file : TEXT
    ) IS

	  	CONSTANT pixel_string :  STRING := INTEGER'IMAGE( pixel );
    	VARIABLE text_line    :  LINE;

	BEGIN
	
		--Write the header
		WRITE( text_line, pixel_string );
		WRITELINE( pbmplus_file, text_line);
	
	END PROCEDURE write_pixel;

	-----------------------------------------------------------------------------------------

	PROCEDURE write_pixel(
	
	   SIGNAL pixel:  IN STD_LOGIC_VECTOR;
                      							
    	FILE pbmplus_file : TEXT
    ) IS

	  	CONSTANT pixel_string :  STRING := INTEGER'IMAGE( TO_INTEGER( UNSIGNED(pixel) ) );
    	VARIABLE text_line    :  LINE;

	BEGIN
	
		--Write the header
		WRITE( text_line, pixel_string );
		WRITELINE( pbmplus_file, text_line);
	
	END PROCEDURE write_pixel;

	--======================================================================================--


	PROCEDURE write_bin_pixel(

		VARIABLE pixel:  IN BOOLEAN;                      							
        FILE pbmplus_file : TEXT

    ) IS
		VARIABLE pixel_val : INTEGER;
    BEGIN

    	CASE pixel IS
    		WHEN TRUE 	=> pixel_val := 1;
    		WHEN FALSE	=> pixel_val := 0;
    		WHEN OTHERS => pixel_val := 255;
    	END CASE;

    	write_pixel(pixel_val, pbmplus_file);

    END PROCEDURE write_bin_pixel;


	-----------------------------------------------------------------------------------------

	PROCEDURE write_bin_pixel(

		SIGNAL pixel:  IN STD_LOGIC;                      							
        FILE pbmplus_file : TEXT

    ) IS
		VARIABLE pixel_val : INTEGER;
    BEGIN

    	CASE pixel IS
    		WHEN '1' 	=> pixel_val := 1;
    		WHEN '0'	=> pixel_val := 0;
    		WHEN OTHERS => pixel_val := 255;
    	END CASE;

    	write_pixel(pixel_val, pbmplus_file);

    END PROCEDURE write_bin_pixel;

	--======================================================================================--	

	 PROCEDURE write_rgb_pixel(

	 	VARIABLE pixel_r:  IN INTEGER;
	 	VARIABLE pixel_g:  IN INTEGER;
	    VARIABLE pixel_b:  IN INTEGER;	

   	    FILE pbmplus_file : TEXT
   	 ) IS
		
		CONSTANT pixel_r_string : STRING := INTEGER'IMAGE( pixel_r );
		CONSTANT pixel_g_string : STRING := INTEGER'IMAGE( pixel_g );
   	  	CONSTANT pixel_b_string : STRING := INTEGER'IMAGE( pixel_b );
    	VARIABLE text_line    : LINE;

	BEGIN
	
		WRITE( text_line, pixel_r_string );
		WRITELINE( pbmplus_file, text_line);

		WRITE( text_line, pixel_g_string );
		WRITELINE( pbmplus_file, text_line);  	

		WRITE( text_line, pixel_b_string );
		WRITELINE( pbmplus_file, text_line);
	
	END PROCEDURE write_rgb_pixel;

	------------------------------------------------------------------------------------------

	PROCEDURE write_rgb_pixel( 	

		SIGNAL pixel_r:  IN UNSIGNED(7 DOWNTO 0);
		SIGNAL pixel_g:  IN UNSIGNED(7 DOWNTO 0);
		SIGNAL pixel_b:  IN UNSIGNED(7 DOWNTO 0);

   	   	FILE pbmplus_file : TEXT

   	) IS
		
		CONSTANT pixel_r_string : STRING := INTEGER'IMAGE( TO_INTEGER( UNSIGNED(pixel_r) ) );
		CONSTANT pixel_g_string : STRING := INTEGER'IMAGE( TO_INTEGER( UNSIGNED(pixel_g) ) );
   	  	CONSTANT pixel_b_string : STRING := INTEGER'IMAGE( TO_INTEGER( UNSIGNED(pixel_b) ) );
    	VARIABLE text_line    : LINE;

	BEGIN
	
		WRITE( text_line, pixel_r_string );
		WRITELINE( pbmplus_file, text_line);

		WRITE( text_line, pixel_g_string );
		WRITELINE( pbmplus_file, text_line);  	

		WRITE( text_line, pixel_b_string );
		WRITELINE( pbmplus_file, text_line);
	
	END PROCEDURE write_rgb_pixel;

	------------------------------------------------------------------------

	PROCEDURE write_ycbcr_pixel( 	

		VARIABLE pixel_y:   IN INTEGER;
		VARIABLE pixel_cb:  IN INTEGER;
		VARIABLE pixel_cr:  IN INTEGER;	

   		FILE pbmplus_file : TEXT

	) IS
	  	VARIABLE var_pixel_y:  UNSIGNED(9 DOWNTO 0);
		VARIABLE var_pixel_cb: UNSIGNED(9 DOWNTO 0);
		VARIABLE var_pixel_cr: UNSIGNED(9 DOWNTO 0);

		VARIABLE pixel_r : UNSIGNED(7 DOWNTO 0);
		VARIABLE pixel_g : UNSIGNED(7 DOWNTO 0);
   	  	VARIABLE pixel_b : UNSIGNED(7 DOWNTO 0);	

	BEGIN
		
		var_pixel_y		:= TO_UNSIGNED(pixel_y, 10);
		var_pixel_cb	:= TO_UNSIGNED(pixel_cb, 10);
		var_pixel_cr	:= TO_UNSIGNED(pixel_cr, 10);

		ycbcr_to_rgb( var_pixel_y, var_pixel_cb, var_pixel_cr, pixel_r, pixel_g, pixel_b);
		write_rgb_pixel( TO_INTEGER(pixel_r), TO_INTEGER(pixel_g), TO_INTEGER(pixel_b), pbmplus_file );
			
	END PROCEDURE write_ycbcr_pixel;

	------------------------------------------------------------------------

	PROCEDURE write_ycbcr_pixel( 	

		SIGNAL pixel_y:   IN UNSIGNED(9 DOWNTO 0);
		SIGNAL pixel_cb:  IN UNSIGNED(9 DOWNTO 0);
		SIGNAL pixel_cr:  IN UNSIGNED(9 DOWNTO 0);

        FILE pbmplus_file : TEXT

    ) IS

	    VARIABLE var_pixel_y:  UNSIGNED(9 DOWNTO 0);
		VARIABLE var_pixel_cb: UNSIGNED(9 DOWNTO 0);
		VARIABLE var_pixel_cr: UNSIGNED(9 DOWNTO 0);

		VARIABLE pixel_r : UNSIGNED(7 DOWNTO 0);
		VARIABLE pixel_g : UNSIGNED(7 DOWNTO 0);
   	  	VARIABLE pixel_b : UNSIGNED(7 DOWNTO 0);

	BEGIN

		var_pixel_y		:= pixel_y;
		var_pixel_cb	:= pixel_cb;
		var_pixel_cr	:= pixel_cr;

		ycbcr_to_rgb( var_pixel_y, var_pixel_cb, var_pixel_cr, pixel_r, pixel_g, pixel_b);
		write_rgb_pixel( TO_INTEGER(pixel_r), TO_INTEGER(pixel_g), TO_INTEGER(pixel_b), pbmplus_file );

	END PROCEDURE write_ycbcr_pixel;

	--======================================================================================--

	PROCEDURE rgb_to_ycbcr(

		VARIABLE R : IN UNSIGNED(7 DOWNTO 0);
		VARIABLE G : IN UNSIGNED(7 DOWNTO 0);
		VARIABLE B : IN UNSIGNED(7 DOWNTO 0);

		VARIABLE Y  : OUT UNSIGNED(9 DOWNTO 0);
		VARIABLE Cb : OUT UNSIGNED(9 DOWNTO 0);
		VARIABLE Cr : OUT UNSIGNED(9 DOWNTO 0)

		) IS

		VARIABLE TR : REAL;
	BEGIN

	--CONVERSION AS ADVICED BY  ITU-R BT.601	

	TR := 0.257 * REAL(TO_INTEGER(R)) + 0.504 * REAL(TO_INTEGER(G)) + 0.098 * REAL(TO_INTEGER(B)) + 16.0;
    Y :=  TO_UNSIGNED(INTEGER(TR * 4.0 + 0.5), Y'LENGTH);

    TR := -0.148 * REAL(TO_INTEGER(R)) - 0.291 * REAL(TO_INTEGER(G)) + 0.439 * REAL(TO_INTEGER(B)) + 128.0;
    Cb := TO_UNSIGNED(INTEGER(TR * 4.0 + 0.5), Cb'LENGTH);

    TR := 0.439 * REAL(TO_INTEGER(R)) - 0.368 * REAL(TO_INTEGER(G)) + 0.071 * REAL(TO_INTEGER(B)) + 128.0;
    Cr := TO_UNSIGNED(INTEGER(TR * 4.0 + 0.5), Cr'LENGTH);

	END PROCEDURE rgb_to_ycbcr;

	--======================================================================================--

	PROCEDURE ycbcr_to_rgb(

		VARIABLE Y  : IN UNSIGNED(9 DOWNTO 0);
		VARIABLE Cb : IN UNSIGNED(9 DOWNTO 0);
		VARIABLE Cr : IN UNSIGNED(9 DOWNTO 0);

		VARIABLE R : OUT UNSIGNED(7 DOWNTO 0);
		VARIABLE G : OUT UNSIGNED(7 DOWNTO 0);
		VARIABLE B : OUT UNSIGNED(7 DOWNTO 0)

		) IS

		VARIABLE TR : REAL;
	BEGIN

	--CONVERSION AS ADVICED BY  ITU-R BT.601	
	
	TR := 1.164 * REAL(TO_INTEGER(Y) - 16*4) + 1.596 * REAL(TO_INTEGER(Cr) - 128*4);
    R :=  TO_UNSIGNED(INTEGER(TR)/4, R'LENGTH);

    TR := 1.164 * REAL(TO_INTEGER(Y) - 16*4) - 0.813 * REAL(TO_INTEGER(Cr) - 128*4) - 0.392 * REAL(TO_INTEGER(Cb) - 128*4);
    G :=  TO_UNSIGNED(INTEGER(TR)/4, G'LENGTH);

    TR := 1.164 * REAL(TO_INTEGER(Y) - 16*4) + 2.017 * REAL(TO_INTEGER(Cb) - 128*4);
    B :=  TO_UNSIGNED(INTEGER(TR)/4, B'LENGTH);

	END PROCEDURE ycbcr_to_rgb;

	FUNCTION pad_string( 	arg_str : 		string;
							ret_len_c : 	natural   := 10;
							fill_char_c : 	character := ' ' )

							RETURN string IS

		VARIABLE ret_v : 		STRING (1 TO ret_len_c);
		CONSTANT pad_len_c : 	INTEGER := ret_len_c - arg_str'LENGTH ;
		VARIABLE pad_v : 		STRING (1 TO ABS(pad_len_c));
		
	BEGIN
	
		IF pad_len_c < 1 THEN
			ret_v := arg_str(ret_v'RANGE);
		ELSE
			pad_v := (OTHERS => fill_char_c);
			ret_v := pad_v & arg_str;
		END IF;
		RETURN ret_v;
	
	END pad_string;

END PACKAGE BODY;
