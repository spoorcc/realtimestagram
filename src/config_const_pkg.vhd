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


package config_const_pkg is

    constant const_wordsize :integer := 8;

    constant const_imageheight :integer := 512;
    constant const_imagewidth  :integer := 512;
    
    constant const_hor_start_activeimage : integer := 10;
    constant const_activeimagewidth: integer := const_imagewidth;

    constant const_blanking_horizontal_left: integer := 10;

end config_const_pkg;
