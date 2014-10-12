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

--! Curves package used to control the curve adjust component
--!
--! Curves
--! =========
--!
--! Multiple curves are possible:
--! * Straight (used for testing purposes) 
--! * Negate   (Negates all  pixel values) 
--! * Sigmoid  (used for contrast enhancement)
--! * Gamma    (used for contrast distribution)
--!
--! Straight
--! ---------- 
--! The straight function is \f[p_{out}=p_{in} \f]
--! \image html straight.png
--!
--! Negate
--! ---------- 
--! The negate function is \f[p_{out}=p_{max}-p_{in} \f]
--! \image html negate.png
--!
--! Sigmoid
--! ---------- 
--! The sigmoid function is \f[p_{out}=\frac{p_{max}}{1+\exp({-c/p_{max}*(p_{in}-p_{max})})} \f]
--! \image html sigmoid.png
--!
--! Gamma
--! ---------- 
--! The gamma function is \f[p_{out}=c*p_{max}*(\frac{p_{in}}{p_{max}})^{\gamma} \f]
--! \image html gamma.png


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package curves_pkg is

    constant wordsize   : integer := 8; 

	type curvetype is ( straight, negate, sigmoid, gamma);

    --! \brief array of std_logic_vectors
    type array_pixel is array (natural range <>) of std_logic_vector(wordsize-1 downto 0);

    function create_lookup_table(size:  integer;                     --! Number of elements to create 
                                 curve_type: curvetype )  --! The type of curve to calculate
                                  return array_pixel;
end curves_pkg;

package body curves_pkg is
 
     function create_lookup_table(size:       integer;                     --! Number of elements to create 
                                  curve_type: curvetype)  --! The type of curve to calculate
                                  return array_pixel is       
        variable exponent: real := 0.0;   --! temp variable used for calculation
        variable calc_val: real := 0.0;   --! The calculated real_value 
        constant max_val:  real := 255.0; --! The maximum value possible, used in calculation and asserting the values are in range
        constant c:        real := 1.0;   --! The amplification factor
        constant g:        real := 0.5;   --! The gamma factor used for the gamma correction
        variable return_value: array_pixel(0 to size-1);   --! 
    begin
        assert(size = 256) report "Invalid size: " & integer'image(size) severity failure;
    --!TODO: Clean up
        for i in return_value'range loop

            curve_sel: case curve_type is
                when straight =>
                    calc_val := real(i);
                when negate =>
                    calc_val := max_val-real(i);
                when sigmoid =>
                    exponent := (c/max_val)*(real(i) - max_val * 0.5 );
                    calc_val := ceil(max_val / (real(1) + exp(-exponent)));
                when gamma =>
                    calc_val := c*max_val*(real(i)/max_val)**g;
                end case;

            report "LUT[" & integer'image(i) & "]: " & integer'image(integer(calc_val));
            assert(integer(calc_val) <= integer(max_val)) report "LUT filled with invalid value: " & integer'image(integer(calc_val)) severity failure;
            assert(integer(calc_val) >= 0) report "LUT filled with invalid value" severity failure;

            return_value(i) := std_logic_vector(to_unsigned(integer(calc_val), wordsize));

        end loop;

        return return_value;
    end  create_lookup_table;
end curves_pkg;
