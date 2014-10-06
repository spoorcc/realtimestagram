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
DOXYDIR=../doc/html
AFLAGS='--workdir=$(BLDTMPDIR)'
EFLAGS='--workdir=$(BLDTMPDIR)'

MKDIR_P = mkdir -p

.PHONY: all clean directories docs test


all: directories curve_adjust_tb

curve_adjust_tb: image_io_pkg.o curve_adjust.o curve_adjust_tb.o 
	$(CC) -e $(AFLAGS) -o ${BLDDIR}/curve_adjust_tb curve_adjust_tb 

image_io_pkg.o: image_io_pkg.vhd
	$(CC) -a $(EFLAGS) image_io_pkg.vhd

curve_adjust.o: curve_adjust.vhd
	$(CC) -a $(EFLAGS) curve_adjust.vhd

curve_adjust_tb.o: curve_adjust_tb.vhd
	$(CC) -a $(EFLAGS) curve_adjust_tb.vhd

clean:
	@rm -rf $(BLDDIR)/*;rm -rf $(DOXYDIR)/*;echo "Cleared $(BLDDIR) and $(DOXYDIR)"

directories:
	${MKDIR_P} ${BLDDIR}
	${MKDIR_P} ${BLDTMPDIR}

docs:
	@doxygen Doxyfile

test:
	@echo "Nothing yet!"

