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

# 
# To seperate source from build files, export them to the seperate bld folder
BLDDIR=img/bld
DOXYDIR=html

MKDIR_P = mkdir -p

.PHONY: all clean directories images docs

all: directories images docs

clean:
	@rm -rf $(BLDDIR)/*;rm -rf $(DOXYDIR)/*;echo "Cleared $(BLDDIR) and $(DOXYDIR)"

directories:
	${MKDIR_P} ${BLDDIR}

images: directories
	@cd img; gnuplot ./*.gnuplot

block_diagrams: directories
	@find  ../src/ -regex ".*\.vhd" | xargs -I '{}'  ./vhdl_to_dot.py -o ./$(BLDDIR) '{}'

docs: images block_diagrams
	@doxygen Doxyfile

