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

TB_DEPS = config_const_pkg.o image_io_pkg.o curves_pkg.o lookup_table.o test_bench_driver.o

.PHONY: all clean

all: sigmoid_tb gamma_tb

# Testbenches
%_tb: $(TB_DEPS) %_tb.o 
	$(CC) -e $(AFLAGS) -o ${BLDDIR}/$@ $@ 

# Objects
%.o : %.vhd
	$(CC) -a $(AFLAGS) $<

# Housekeeping
clean:
	@echo Removing any temp files from syntax checking
	@-rm -f *.cf
