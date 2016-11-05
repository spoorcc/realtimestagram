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


entity hsv2rgb_testsets_tb is
end entity;

architecture all_tests of hsv2rgb_testsets_tb is

    component hsv2rgb_tb is
        generic (
            input_file:   string; --! Input file of test 
            output_file:  string  --! Output file of test 
        );
    end component;

begin

    Lenna: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_lenna.pnm",
            output_file => "tst/output/hsv2rgb_lenna.pnm"
        );

    windmill: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_windmill.pnm",
            output_file => "tst/output/hsv2rgb_windmill.pnm"
        );

    danger_zone: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_danger_zone.pnm",
            output_file => "tst/output/hsv2rgb_danger_zone.pnm"
        );

    amersfoort: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_amersfoort.pnm",
            output_file => "tst/output/hsv2rgb_amersfoort.pnm"
        );

    rainbow: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_rainbow.pnm",
            output_file => "tst/output/hsv2rgb_rainbow.pnm"
        );

    hue_gradient: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_hue_gradient.pnm",
            output_file => "tst/output/hsv2rgb_hue_gradient.pnm"
        );

    sat_gradient: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_sat_gradient.pnm",
            output_file => "tst/output/hsv2rgb_sat_gradient.pnm"
        );

    val_gradient: hsv2rgb_tb
        generic map(
            input_file  => "tst/input/rgb2hsv_val_gradient.pnm",
            output_file => "tst/output/hsv2rgb_val_gradient.pnm"
        );

end architecture;
