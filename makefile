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
TMPDIR=tmp
BLDTMPDIR=bld/tmp
BLDDIR=bld
TSTDIR=tst
TST_OUT_DIR=tst/output

MKDIR_P = mkdir -p

TESTBENCHES = sigmoid_tb gamma_tb vignette_tb sepia_tb rgb2hsv_tb hsv2rgb_tb

VIEW_CMD = /usr/bin/gtkwave

.PHONY: all clean directories docs test

all: directories test_benches

test_benches: 
	@cd src; make

clean:
	@cd doc; make clean
	@cd src; make clean
	@rm -rf $(BLDDIR)/*;echo "Cleared $(BLDDIR)"
	@rm -rf $(TST_OUT_DIR)/*;echo "Cleared $(TST_OUT_DIR)"

directories:
	${MKDIR_P} ${BLDDIR}
	${MKDIR_P} ${BLDTMPDIR}
	${MKDIR_P} ${TST_OUT_DIR}
	${MKDIR_P} ${TMPDIR}

docs:
	@cd doc; make

test: all
	@echo "Starting TB "
	@$(BLDDIR)/rgb2hsv_tb  --wave=$(TMPDIR)/rgb2hsv_tb.ghw
	@$(BLDDIR)/hsv2rgb_tb  --wave=$(TMPDIR)/hsv2rgb_tb.ghw
	@$(BLDDIR)/lomo_tb     --wave=$(TMPDIR)/lomo_tb.ghw
	@$(BLDDIR)/vignette_tb --wave=$(TMPDIR)/vignette_tb.ghw
	@$(BLDDIR)/sigmoid_tb  --wave=$(TMPDIR)/sigmoid_tb.ghw
	@$(BLDDIR)/sepia_tb    --wave=$(TMPDIR)/sepia_tb.ghw
	@$(BLDDIR)/gamma_tb    --wave=$(TMPDIR)/gamma_tb.ghw
	@$(BLDDIR)/lomo_testsets_tb
	@$(BLDDIR)/rgb2hsv_testsets_tb
	@$(BLDDIR)/hsv2rgb_testsets_tb

