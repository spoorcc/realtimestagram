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
SRCDIR=../src
BLDDIR=img/bld
DOXYDIR=html

MKDIR_P = mkdir -p

.PHONY: all clean directories images block_diagrams timing_diagrams test_output_files docs

all: directories images docs

clean:
	@rm -rf $(BLDDIR)/*;rm -rf $(DOXYDIR)/*;echo "Cleared $(BLDDIR) and $(DOXYDIR)"

directories:
	${MKDIR_P} ${BLDDIR}

docs: images block_diagrams timing_diagrams test_output_files
	@doxygen Doxyfile

test_output_files: directories
	$(foreach i,\
           $(shell find $(SRCDIR) -regex ".*tst/output/.*\.pnm" ),\
           $(shell pnmtopng $i > $(BLDDIR)/`basename $i .pnm`.png ) )

images: directories
	@cd img; gnuplot ./*.gnuplot

# TODO Rewrite to use prerequisites 
block_diagrams: directories
	@find  $(SRCDIR) -regex ".*\.vhd" | xargs -I '{}'  ./vhdl_to_dot.py -o ./$(BLDDIR) '{}'

# Timing Diagram section
# ----------------------
# Since timing diagrams are documented using wavedrom and generated using LaTeX
# Several intermediate steps are necessary to generate usable images for in HTML
# documentation

TIMING_DIAGRAMS_SRCS = $(shell find $(SRCDIR) -regex ".*\.drom" )
TIMING_DIAGRAMS_IMGS = $(notdir $(TIMING_DIAGRAMS_SRCS:%.drom=%.timing.png))

# TODO Probably only workssince there is only 1 diagram
%.tikz: $(filter %.drom, $(TIMING_DIAGRAMS_SRCS))
	@./WaveDromTikZ/wavedromtikz.py wavedrom -o ./$(BLDDIR) -s $<

%.timing.pdf: %.tikz
	@pdflatex --interaction=batchmode --output-directory=$(BLDDIR) -jobname=$*.timing $<

%.timing.png: %.timing.pdf
	@pdftoppm $(BLDDIR)/$< | pnmtopng > $(BLDDIR)/$@

timing_diagrams: directories $(TIMING_DIAGRAMS_IMGS)
	@echo Generated Timing Diagrams:
	@echo "    $(filter-out directories, $+)"

