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
VIEW_CMD = /usr/bin/gtkwave

.PHONY: all clean directories docs test

all: test_benches

test_benches:
	$(MAKE) -C src

clean:
	$(MAKE) -C doc clean
	$(MAKE) -C src clean

docs: test
	@cd doc; make

test: $(TESTBENCHES)
	@echo "> Done: running testbenches $(TESTBENCHES)"
	$(MAKE) -C src test
