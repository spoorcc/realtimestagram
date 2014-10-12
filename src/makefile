#   This file is part of Realtimestagram.
#
#   Realtimestagram is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 2 of the License, or
#   (at your option) any later version.
#
#   Realtimestagram is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Realtimestagram.  If not, see <http://www.gnu.org/licenses/>.


CC=ghdl
# 
# To seperate source from build files, export them to the seperate bld folder
BLDTMPDIR=../bld/tmp
BLDDIR=../bld
AFLAGS='--workdir=$(BLDTMPDIR)'
EFLAGS='--workdir=$(BLDTMPDIR)'

MKDIR_P = mkdir -p

.PHONY: all clean

all: curve_adjust_tb

# Binaries
curve_adjust_tb: config_const_pkg.o image_io_pkg.o lookup_table.o curve_adjust_tb.o 
	$(CC) -e $(AFLAGS) -o ${BLDDIR}/curve_adjust_tb curve_adjust_tb 

# Objects
config_const_pkg.o: config_const_pkg.vhd
	$(CC) -a $(EFLAGS) config_const_pkg.vhd

curves_pkg.o: curves_pkg.vhd
	$(CC) -a $(EFLAGS) curves_pkg.vhd

image_io_pkg.o: image_io_pkg.vhd
	$(CC) -a $(EFLAGS) image_io_pkg.vhd

lookup_table.o: lookup_table.vhd curves_pkg.o
	$(CC) -a $(EFLAGS) lookup_table.vhd

test_bench_driver.o: test_bench_driver.vhd image_io_pkg.o config_const_pkg.o
	$(CC) -a $(EFLAGS) test_bench_driver.vhd

curve_adjust_tb.o: curve_adjust_tb.vhd test_bench_driver.o
	$(CC) -a $(EFLAGS) curve_adjust_tb.vhd

# Housekeeping
clean: 
	-rm -f *.cf # Remove any temp files from sytax checking
