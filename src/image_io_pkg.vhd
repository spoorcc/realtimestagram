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

package image_io_pkg is

    constant wordsize   : integer := 8; 

	--! three types can be selected, these types are specified in the detailed description
	type pbmplustype is (pbm, pgm, ppm);

	--! to accomodate for unknown arrays of pixels array writing is also possible
	type pixel_array is array ( integer range <> ) of integer;

	--! generic procedure for writing pbm plus headers
	--! @param[in] p_width     width of image in pixels
	--! @param[in] p_height    height of image in pixels
	--! @param[in] max_value   maximum pixel value possible
	--! @param[in] type_of_pbm image type used to determine magic identifier
	--! @param     p_file      opened target file to write header to

	procedure write_pbmplus_header( constant p_width     : in integer;			
                                	constant p_height    : in integer;
                                	constant max_value   : in integer;
                                	constant type_of_pbm : in pbmplustype;
                                	file p_file : text           	);
    ----------------------------------------------------------------------     								
    --! generic procedure for reading single pixel value from pbm file to variable
    procedure read_pixel( file pbmplus_file : text;
                    	  variable pixel : out integer;
                          signal end_of_file: out std_logic );
	--! generic procedure for reading single pixel value from pbm file to signal
	procedure read_pixel( file pbmplus_file : text;
                          signal pixel:  out std_logic_vector;                      							
                          signal end_of_file: out std_logic );

    ----------------------------------------------------------------------     								
    --! generic procedure for writing single pixel value from variable to pbm file                  								
	procedure write_pixel( variable pixel:  in integer;                      							
                           file pbmplus_file : text       );

	--! generic procedure for writing single pixel value from signal to pbm file
	procedure write_pixel( signal pixel:  in std_logic_vector;                      							
                           file pbmplus_file : text       );

	----------------------------------------------------------------------

	--! generic procedure to write binary variable of a file
	--! the header must be written with pbm  as image type
	procedure write_bin_pixel( variable pixel:  in boolean;                      							
                           	   file pbmplus_file : text       );

	--! generic procedure to write binary signal of a file
	--! the header must be written with pbm  as image type
	procedure write_bin_pixel( signal pixel:  in std_logic;                      							
                           	   file pbmplus_file : text       );

    ------------------------------------------------------------------------

	--! generic procedure to write rgb variable of a file
	--! the header must be written with ppm as image type
    procedure write_rgb_pixel( variable pixel_r:  in integer;
    						   variable pixel_g:  in integer;
    						   variable pixel_b:  in integer;	

                           	   file pbmplus_file : text       );

	--! generic procedure to write rgb signal of a file
	--! the header must be written with ppm as image type
	procedure write_rgb_pixel( 	signal pixel_r:  in unsigned(7 downto 0);
								signal pixel_g:  in unsigned(7 downto 0);
								signal pixel_b:  in unsigned(7 downto 0);

                           	   	file pbmplus_file : text       );

	------------------------------------------------------------------------

	--! generic procedure to write ycbcr variable of a file
	--! the header must be written with ppm as image type
	procedure write_ycbcr_pixel( 	variable pixel_y:   in integer;
    						   		variable pixel_cb:  in integer;
    						   		variable pixel_cr:  in integer;	

                           	   		file pbmplus_file : text       );

	--! generic procedure to write ycbcr signal of a file
	--! the header must be written with ppm as image type
	procedure write_ycbcr_pixel( 	signal pixel_y:   in unsigned(9 downto 0);
									signal pixel_cb:  in unsigned(9 downto 0);
									signal pixel_cr:  in unsigned(9 downto 0);

                           	   		file pbmplus_file : text       );	

	---------------------------------------------------------------------------

	--! procedure to convert rgb variables into corresponding ycbcr components
	procedure rgb_to_ycbcr( variable r : in unsigned(7 downto 0);
							variable g : in unsigned(7 downto 0);
							variable b : in unsigned(7 downto 0);

							variable y  : out unsigned(9 downto 0);
							variable cb : out unsigned(9 downto 0);
							variable cr : out unsigned(9 downto 0)	);

	--! procedure to convert ycbcr variables into corresponding rgb components
	procedure ycbcr_to_rgb( variable y  : in unsigned(9 downto 0);
							variable cb : in unsigned(9 downto 0);
							variable cr : in unsigned(9 downto 0);

							variable r : out unsigned(7 downto 0);
							variable g : out unsigned(7 downto 0);
							variable b : out unsigned(7 downto 0)	);

	--! function to pad strings with a fill character
	--! \param[in] arg_str      the input string that has to be padded
	--! \param[in] ret_len_c    the length of the output string. (must be larger than length of the input string)
	--! \param[in] fill_char_c  the filling character that should be used to pad the input string
	--! \returns  string arg_str padded up to length ret_len_c with charachter fill_char_c
	function pad_string( 	arg_str : 		string;
							ret_len_c : 	natural   := 10;
							fill_char_c : 	character := ' ' )

							return string;

end;

package body image_io_pkg is

--======================================================================================--

	procedure write_pbmplus_header (

		constant p_width  : in integer;				
		constant p_height : in integer;				
		constant max_value  : in integer;			

		constant type_of_pbm : in pbmplustype;

		file p_file : text

		) is
		
	    constant width_height     : string := integer'image(p_width) & " " & integer'image(p_height);
	    constant maximum_value    : string := integer'image(max_value);

	    variable magic_identifier : string(1 to 2) := "p0";
	    variable text_line:    line;

	begin
	
	  	case type_of_pbm is
	  		when pbm  	=> magic_identifier := "P1";
	  		when pgm  	=> magic_identifier := "P2";
	  		when ppm  	=> magic_identifier := "P3";
	  		when others => magic_identifier := "P1";
	  	end case;

		--write the header
		write( text_line, magic_identifier);
		writeline( p_file, text_line);

		write( text_line, width_height);
		writeline( p_file, text_line);

		write( text_line, maximum_value);
		writeline( p_file, text_line );
	
	end procedure write_pbmplus_header;

--======================================================================================--

	procedure read_pixel(
	
       file pbmplus_file : text;

	   variable pixel:     out integer;
       signal end_of_file: out std_logic
    ) is

    	variable text_line    : line;

	begin
	
        if (not endfile(pbmplus_file)) then
            end_of_file <= '0';
            readline(pbmplus_file, text_line);
            read(text_line, pixel);
        else
            pixel := 0;
            end_of_file <= '1';
        end if;
	
	end procedure read_pixel;

	-----------------------------------------------------------------------------------------
	procedure read_pixel(
	
       file pbmplus_file : text;

	   signal pixel:       out std_logic_vector;
       signal end_of_file: out std_logic
    ) is

	  	variable pixel_int :  integer;
    	variable text_line    :  line;

	begin
        if (not endfile(pbmplus_file)) then
            end_of_file <= '0';
            readline(pbmplus_file, text_line);
            read(text_line, pixel_int);

            pixel <= std_logic_vector(to_unsigned(pixel_int, wordsize));
        else
            assert(1 = 0) report "End of file" severity failure;
            pixel <= std_logic_vector(to_unsigned(0, wordsize));
            end_of_file <= '1';
        end if;
	
	end procedure read_pixel;

	-----------------------------------------------------------------------------------------

	procedure write_pixel(
	
	   variable pixel:  in integer;
                      							
    	file pbmplus_file : text
    ) is

	  	constant pixel_string :  string := integer'image( pixel );
    	variable text_line    :  line;

	begin
	
		--write the header
		write( text_line, pixel_string );
		writeline( pbmplus_file, text_line);
	
	end procedure write_pixel;

	-----------------------------------------------------------------------------------------

	procedure write_pixel(
	
	   signal pixel:  in std_logic_vector;
                      							
    	file pbmplus_file : text
    ) is

	  	constant pixel_string :  string := integer'image( to_integer( unsigned(pixel) ) );
    	variable text_line    :  line;

	begin
	
		--write the header
		write( text_line, pixel_string );
		writeline( pbmplus_file, text_line);
	
	end procedure write_pixel;

	--======================================================================================--


	procedure write_bin_pixel(

		variable pixel:  in boolean;                      							
        file pbmplus_file : text

    ) is
		variable pixel_val : integer;
    begin

    	case pixel is
    		when true 	=> pixel_val := 1;
    		when false	=> pixel_val := 0;
    		when others => pixel_val := 255;
    	end case;

    	write_pixel(pixel_val, pbmplus_file);

    end procedure write_bin_pixel;


	-----------------------------------------------------------------------------------------

	procedure write_bin_pixel(

		signal pixel:  in std_logic;                      							
        file pbmplus_file : text

    ) is
		variable pixel_val : integer;
    begin

    	case pixel is
    		when '1' 	=> pixel_val := 1;
    		when '0'	=> pixel_val := 0;
    		when others => pixel_val := 255;
    	end case;

    	write_pixel(pixel_val, pbmplus_file);

    end procedure write_bin_pixel;

	--======================================================================================--	

	 procedure write_rgb_pixel(

	 	variable pixel_r:  in integer;
	 	variable pixel_g:  in integer;
	    variable pixel_b:  in integer;	

   	    file pbmplus_file : text
   	 ) is
		
		constant pixel_r_string : string := integer'image( pixel_r );
		constant pixel_g_string : string := integer'image( pixel_g );
   	  	constant pixel_b_string : string := integer'image( pixel_b );
    	variable text_line    : line;

	begin
	
		write( text_line, pixel_r_string );
		writeline( pbmplus_file, text_line);

		write( text_line, pixel_g_string );
		writeline( pbmplus_file, text_line);  	

		write( text_line, pixel_b_string );
		writeline( pbmplus_file, text_line);
	
	end procedure write_rgb_pixel;

	------------------------------------------------------------------------------------------

	procedure write_rgb_pixel( 	

		signal pixel_r:  in unsigned(7 downto 0);
		signal pixel_g:  in unsigned(7 downto 0);
		signal pixel_b:  in unsigned(7 downto 0);

   	   	file pbmplus_file : text

   	) is
		
		constant pixel_r_string : string := integer'image( to_integer( unsigned(pixel_r) ) );
		constant pixel_g_string : string := integer'image( to_integer( unsigned(pixel_g) ) );
   	  	constant pixel_b_string : string := integer'image( to_integer( unsigned(pixel_b) ) );
    	variable text_line    : line;

	begin
	
		write( text_line, pixel_r_string );
		writeline( pbmplus_file, text_line);

		write( text_line, pixel_g_string );
		writeline( pbmplus_file, text_line);  	

		write( text_line, pixel_b_string );
		writeline( pbmplus_file, text_line);
	
	end procedure write_rgb_pixel;

	------------------------------------------------------------------------

	procedure write_ycbcr_pixel( 	

		variable pixel_y:   in integer;
		variable pixel_cb:  in integer;
		variable pixel_cr:  in integer;	

   		file pbmplus_file : text

	) is
	  	variable var_pixel_y:  unsigned(9 downto 0);
		variable var_pixel_cb: unsigned(9 downto 0);
		variable var_pixel_cr: unsigned(9 downto 0);

		variable pixel_r : unsigned(7 downto 0);
		variable pixel_g : unsigned(7 downto 0);
   	  	variable pixel_b : unsigned(7 downto 0);	

	begin
		
		var_pixel_y		:= to_unsigned(pixel_y, 10);
		var_pixel_cb	:= to_unsigned(pixel_cb, 10);
		var_pixel_cr	:= to_unsigned(pixel_cr, 10);

		ycbcr_to_rgb( var_pixel_y, var_pixel_cb, var_pixel_cr, pixel_r, pixel_g, pixel_b);
		write_rgb_pixel( to_integer(pixel_r), to_integer(pixel_g), to_integer(pixel_b), pbmplus_file );
			
	end procedure write_ycbcr_pixel;

	------------------------------------------------------------------------

	procedure write_ycbcr_pixel( 	

		signal pixel_y:   in unsigned(9 downto 0);
		signal pixel_cb:  in unsigned(9 downto 0);
		signal pixel_cr:  in unsigned(9 downto 0);

        file pbmplus_file : text

    ) is

	    variable var_pixel_y:  unsigned(9 downto 0);
		variable var_pixel_cb: unsigned(9 downto 0);
		variable var_pixel_cr: unsigned(9 downto 0);

		variable pixel_r : unsigned(7 downto 0);
		variable pixel_g : unsigned(7 downto 0);
   	  	variable pixel_b : unsigned(7 downto 0);

	begin

		var_pixel_y		:= pixel_y;
		var_pixel_cb	:= pixel_cb;
		var_pixel_cr	:= pixel_cr;

		ycbcr_to_rgb( var_pixel_y, var_pixel_cb, var_pixel_cr, pixel_r, pixel_g, pixel_b);
		write_rgb_pixel( to_integer(pixel_r), to_integer(pixel_g), to_integer(pixel_b), pbmplus_file );

	end procedure write_ycbcr_pixel;

	--======================================================================================--

	procedure rgb_to_ycbcr(

		variable r : in unsigned(7 downto 0);
		variable g : in unsigned(7 downto 0);
		variable b : in unsigned(7 downto 0);

		variable y  : out unsigned(9 downto 0);
		variable cb : out unsigned(9 downto 0);
		variable cr : out unsigned(9 downto 0)

		) is

		variable tr : real;
	begin

	--conversion as adviced by  itu-r bt.601	

	tr := 0.257 * real(to_integer(r)) + 0.504 * real(to_integer(g)) + 0.098 * real(to_integer(b)) + 16.0;
    y :=  to_unsigned(integer(tr * 4.0 + 0.5), y'length);

    tr := -0.148 * real(to_integer(r)) - 0.291 * real(to_integer(g)) + 0.439 * real(to_integer(b)) + 128.0;
    cb := to_unsigned(integer(tr * 4.0 + 0.5), cb'length);

    tr := 0.439 * real(to_integer(r)) - 0.368 * real(to_integer(g)) + 0.071 * real(to_integer(b)) + 128.0;
    cr := to_unsigned(integer(tr * 4.0 + 0.5), cr'length);

	end procedure rgb_to_ycbcr;

	--======================================================================================--

	procedure ycbcr_to_rgb(

		variable y  : in unsigned(9 downto 0);
		variable cb : in unsigned(9 downto 0);
		variable cr : in unsigned(9 downto 0);

		variable r : out unsigned(7 downto 0);
		variable g : out unsigned(7 downto 0);
		variable b : out unsigned(7 downto 0)

		) is

		variable tr : real;
	begin

	--conversion as adviced by  itu-r bt.601	
	
	tr := 1.164 * real(to_integer(y) - 16*4) + 1.596 * real(to_integer(cr) - 128*4);
    r :=  to_unsigned(integer(tr)/4, r'length);

    tr := 1.164 * real(to_integer(y) - 16*4) - 0.813 * real(to_integer(cr) - 128*4) - 0.392 * real(to_integer(cb) - 128*4);
    g :=  to_unsigned(integer(tr)/4, g'length);

    tr := 1.164 * real(to_integer(y) - 16*4) + 2.017 * real(to_integer(cb) - 128*4);
    b :=  to_unsigned(integer(tr)/4, b'length);

	end procedure ycbcr_to_rgb;

	function pad_string( 	arg_str : 		string;
							ret_len_c : 	natural   := 10;
							fill_char_c : 	character := ' ' )

							return string is

		variable ret_v : 		string (1 to ret_len_c);
		constant pad_len_c : 	integer := ret_len_c - arg_str'length ;
		variable pad_v : 		string (1 to abs(pad_len_c));
		
	begin
	
		if pad_len_c < 1 then
			ret_v := arg_str(ret_v'range);
		else
			pad_v := (others => fill_char_c);
			ret_v := pad_v & arg_str;
		end if;
		return ret_v;
	
	end pad_string;

end package body;
