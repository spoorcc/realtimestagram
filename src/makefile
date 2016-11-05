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


SUBDIRS = $(shell find . -mindepth 1 -maxdepth 1 -type d)
LIBS = ./common ./testbench_drivers
COMPS = $(filter-out $(LIBS),$(SUBDIRS))

all: $(LIBS) $(COMPS)

$(LIBS):
	$(MAKE) -C $@

$(COMPS):
	$(MAKE) -C $@

.PHONY: all $(LIBS) $(COMPS)

# Housekeeping
clean:
	for dir in $(SUBDIRS); do \
         $(MAKE) -C $$dir clean;\
    done

test: $(LIBS)
	for dir in $(COMPS); do \
         $(MAKE) -C $$dir test;\
    done

