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
BLDTMPDIR=bld/tmp
BLDDIR=bld
AFLAGS='--workdir=$(BLDTMPDIR)'
EFLAGS='--workdir=$(BLDTMPDIR)'

MKDIR_P = mkdir -p

SRCS = $(wildcard src/*.vhd)
OBJS = $(notdir $(SRCS:.vhd=.o))

INCS = -P../common/bld -P../test/bld

TST_BENCHES_SRCS = $(wildcard tst/*_tb.vhd)
TST_BENCHES = $(notdir $(TST_BENCHES_SRCS:.vhd=))
TST_OBJS = $(notdir $(TST_BENCHES_SRCS:.vhd=.o))

.PHONY: all dirs clean

all: dirs $(TST_BENCHES)

dirs:
	${MKDIR_P} ${BLDDIR}
	${MKDIR_P} ${BLDTMPDIR}

# Testbenches
%_tb: $(OBJS) $(TST_OBJS)
	$(CC) -e $(AFLAGS) -o ${BLDDIR}/$@ $@ 

# Objects
%.o : src/%.vhd
	$(CC) -a $(AFLAGS) $<

# Objects
%_tb.o : tst/%.vhd
	$(CC) -a $(AFLAGS) $<

# Housekeeping
clean:
	$(info removing temp folder)
	@-rm -f *.cf
