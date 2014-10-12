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
use ieee.math_real.all;

--! Package which provides functions to create Look Up Tables for various functions
--! The generated Look Up Table can be placed in a lookup_table entity.
--! \see lookup_table
package curves_pkg is

    --! Bit depth of pixels
    constant wordsize   : integer := 8;

    --! \brief array of std_logic_vectors
    type array_pixel is array (natural range <>) of std_logic_vector(wordsize-1 downto 0);

    ----------------------------------------------------------------------     								
    --! Function to create Look up table for a straight line
    --! Used for testing purposes, creates a straight line.
    --! The straight function is \f[p_{out}=p_{in} \f]
    --! \param[in] size  Number of elements to create
    --! \image html straight.png
    function create_straight_lut( size:       integer)

                                  return array_pixel;

    ----------------------------------------------------------------------     								
    --! Function to create Look up table for a negated line
    --! The negate function is \f[p_{out}=p_{max}-p_{in} \f]
    --! \param[in] size  Number of elements to create
    --! \image html negate.png
    function create_negated_lut( size:       integer)

                                 return array_pixel;

    ----------------------------------------------------------------------     								
    --! Function to create Look up table for a sigmoid function
    --! The sigmoid function is \f[p_{out}=\frac{p_{max}}{1+\exp({-c/p_{max}*(p_{in}-p_{max})})} \f]
    --! \param[in] size  Number of elements to create
    --! \param[in] c     Amplification factor
    --! \image html sigmoid.png
    function create_sigmoid_lut( size:       integer;
                                 c:          real := 1.0)

                                 return array_pixel;

    ----------------------------------------------------------------------     								
    --! Function to create Look up table for a gamma function
    --! The gamma function is \f[p_{out}=c*p_{max}*(\frac{p_{in}}{p_{max}})^{\gamma} \f]
    --! \param[in] size  Number of elements to create
    --! \param[in] gamma Gamma factor
    --! \param[in] c     Amplification factor
    --! \image html gamma.png
    function create_gamma_lut( size:    integer;
                               gamma:   real := 1.0;
                               c:       real := 1.0)
                               return array_pixel;

    ----------------------------------------------------------------------     								
    --! Procedure to assert that value can be represented in bit range
    --! \param[in] value    Value to compare
    --! \param[in] wordsize Bit depth
    procedure verify_valid_value( variable value:    in real;
                                  constant wordsize: in integer);

    ----------------------------------------------------------------------     								
    --! Procedure to pretty print out a LUT value
    --! \param[in] value    Value to be printed
    --! \param[in] index    Index to print
    procedure report_lut_value( variable value:  in real;
                                constant index:  in integer);

end curves_pkg;

package body curves_pkg is

--======================================================================================--
    function create_straight_lut( size:    integer)
                                  return array_pixel is

        variable calc_val:     real := 0.0;
        variable return_value: array_pixel(0 to size-1);

    begin

        for i in return_value'range loop

            calc_val := real(i);
            report_lut_value( calc_val, i);
            return_value(i) := std_logic_vector(to_unsigned(integer(calc_val), wordsize));

        end loop;

        return return_value;
    end create_straight_lut;

--======================================================================================--

    function create_negated_lut( size:    integer)
                                 return array_pixel is

        variable calc_val:      real := 0.0;
        constant max_val:       real := real(2**wordsize)-1.0;
        variable return_value:  array_pixel(0 to size-1);

    begin

        for i in return_value'range loop

            calc_val := max_val-real(i);
            report_lut_value( calc_val, i);
            return_value(i) := std_logic_vector(to_unsigned(integer(calc_val), wordsize));

        end loop;

        return return_value;
    end  create_negated_lut;

--======================================================================================--

    function create_sigmoid_lut( size:    integer;
                                 c:       real := 1.0)
                                 return   array_pixel is

        variable exponent:      real := 0.0;
        variable calc_val:      real := 0.0;
        constant max_val:       real := real(2**wordsize)-1.0;
        variable return_value:  array_pixel(0 to size-1);
    begin

        for i in return_value'range loop

            exponent := (c/max_val)*(real(i) - max_val * 0.5 );
            calc_val := ceil(max_val / (real(1) + exp(-exponent)));

            report_lut_value( calc_val, i);
            verify_valid_value(calc_val, wordsize);

            return_value(i) := std_logic_vector(to_unsigned(integer(calc_val), wordsize));

        end loop;

        return return_value;
    end  create_sigmoid_lut;

--======================================================================================--

    function create_gamma_lut( size:    integer;
                               gamma:   real := 1.0;
                               c:       real := 1.0)
                               return   array_pixel is

        variable calc_val: real := 0.0;
        constant max_val:  real := real(2**wordsize)-1.0;
        variable return_value: array_pixel(0 to size-1);

    begin

        for i in return_value'range loop

            calc_val := c*max_val*(real(i)/max_val)**gamma;

            report_lut_value( calc_val, i);
            verify_valid_value(calc_val, wordsize);

            return_value(i) := std_logic_vector(to_unsigned(integer(calc_val), wordsize));

        end loop;

        return return_value;
    end  create_gamma_lut;

--======================================================================================--

    procedure verify_valid_value( variable value:    in real;
                                  constant wordsize: in integer) is

        constant max_val : integer := integer(2**wordsize)-1;

    begin

        assert(integer(value) <= max_val) report "LUT filled with invalid value: " & integer'image(integer(value)) severity failure;
        assert(integer(value) >= 0) report "LUT filled with invalid value" severity failure;

    end procedure verify_valid_value;

--======================================================================================--

    procedure report_lut_value( variable value:  in real;
                                constant index:  in integer) is
    begin
        report "LUT[" & integer'image(index) & "]: " & integer'image(integer(value));
    end procedure report_lut_value;

end curves_pkg;
