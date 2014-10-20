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


entity lomo_testsets_tb is
end entity;

architecture all_tests of lomo_testsets_tb is

    component lomo_tb is
        generic (
            input_file:   string; --! Input file of test 
            output_file:  string  --! Output file of test 
        );
    end component;

begin

    Lenna: lomo_tb
        generic map(
            input_file  => "tst/input/Lenna.pnm",
            output_file => "tst/output/lomo_lenna.pnm"
        );

    windmill: lomo_tb
        generic map(
            input_file  => "tst/input/windmill.pnm",
            output_file => "tst/output/lomo_windmill.pnm"
        );

    danger_zone: lomo_tb
        generic map(
            input_file  => "tst/input/danger_zone.pnm",
            output_file => "tst/output/lomo_danger_zone.pnm"
        );

    amersfoort: lomo_tb
        generic map(
            input_file  => "tst/input/amersfoort.pnm",
            output_file => "tst/output/lomo_amersfoort.pnm"
        );

end architecture;
