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


entity sepia_testsets_tb is
end entity;

architecture all_tests of sepia_testsets_tb is

    constant threshold:      integer  := 220;


    component sepia_tb is
        generic (
            input_file:   string; --! Input file of test 
            output_file:  string;  --! Output file of test 

            sepia_threshold: integer
        );
    end component;


begin

    Lenna: sepia_tb
        generic map(
            input_file  => "tst/input/Lenna.pnm",
            output_file => "tst/output/sepia_lenna.pnm",

            sepia_threshold => threshold
        );

    windmill: sepia_tb
        generic map(
            input_file  => "tst/input/windmill.pnm",
            output_file => "tst/output/sepia_windmill.pnm",

            sepia_threshold => threshold
        );

    danger_zone: sepia_tb
        generic map(
            input_file  => "tst/input/danger_zone.pnm",
            output_file => "tst/output/sepia_danger_zone.pnm",

            sepia_threshold => threshold
        );

    amersfoort: sepia_tb
        generic map(
            input_file  => "tst/input/amersfoort.pnm",
            output_file => "tst/output/sepia_amersfoort.pnm",

            sepia_threshold => threshold
        );

    rainbow: sepia_tb
        generic map(
            input_file  => "tst/input/rainbow.pnm",
            output_file => "tst/output/sepia_rainbow.pnm",

            sepia_threshold => threshold
        );

    hue_gradient: sepia_tb
        generic map(
            input_file  => "tst/input/hue_gradient.pnm",
            output_file => "tst/output/sepia_hue_gradient.pnm",

            sepia_threshold => threshold
        );

    sat_gradient: sepia_tb
        generic map(
            input_file  => "tst/input/sat_gradient.pnm",
            output_file => "tst/output/sepia_sat_gradient.pnm",

            sepia_threshold => threshold
        );

    val_gradient: sepia_tb
        generic map(
            input_file  => "tst/input/val_gradient.pnm",
            output_file => "tst/output/sepia_val_gradient.pnm",

            sepia_threshold => threshold
        );
end architecture;
