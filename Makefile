# Flatalias
# Generate short, convenient shell aliases for Flatpak applications.
#
# Flatalias scans installed Flatpaks, derives suitable aliases from their
# default commands, and makes them available in your shell environment.
#
# Copyright (C) 2026  Daniel Rudolf <https://www.daniel-rudolf.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License only.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# License: GNU General Public License <https://opensource.org/license/gpl-3-0>
# SPDX-License-Identifier: GPL-3.0-only

SHELL = /bin/sh

INSTALL ?= install
INSTALL_PROGRAM ?= $(INSTALL)
INSTALL_DATA ?= $(INSTALL) -m644

srcdir ?= .
prefix ?= /usr/local
exec_prefix ?= $(prefix)

bindir ?= $(exec_prefix)/bin
libdir ?= $(exec_prefix)/lib
datarootdir ?= $(prefix)/share
docdir ?= $(datarootdir)/doc/flatalias
licensedir ?= $(datarootdir)/licenses/flatalias

SYSTEMD_USER_UNIT_PATH ?= $(libdir)/systemd/user
PROFILE_PATH ?= /etc/profile.d

.PHONY: all install uninstall clean

all:
	@echo "Nothing to build."

install:
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	$(INSTALL_PROGRAM) -D "$(srcdir)/src/bin/flatalias" "$(DESTDIR)$(bindir)/flatalias"
	
	(cd "$(srcdir)/src/lib/flatalias"; find -type d -print0) | xargs -t -0 -I{} \
		$(INSTALL) -d "$(DESTDIR)$(libdir)/flatalias/{}"
	(cd "$(srcdir)/src/lib/flatalias"; find -type f -print0) | xargs -t -0 -I{} \
		$(INSTALL_DATA) "$(srcdir)/src/lib/flatalias/{}" "$(DESTDIR)$(libdir)/flatalias/{}"
	
	$(INSTALL) -d "$(DESTDIR)$(PROFILE_PATH)"
	(cd "$(DESTDIR)$(libdir)/flatalias/profile.d"; find -type f -print0) | xargs -t -0 -I{} \
		ln -sr "$(DESTDIR)$(libdir)/flatalias/profile.d/{}" "$(DESTDIR)$(PROFILE_PATH)/"
	
	(cd "$(srcdir)/src/lib/systemd/user"; find -type d -print0) | xargs -t -0 -I{} \
		$(INSTALL) -d "$(DESTDIR)$(SYSTEMD_USER_UNIT_PATH)/{}"
	(cd "$(srcdir)/src/lib/systemd/user"; find -type f -print0) | xargs -t -0 -I{} \
		$(INSTALL_DATA) "$(srcdir)/src/lib/systemd/user/{}" "$(DESTDIR)$(SYSTEMD_USER_UNIT_PATH)/{}"
	
	(cd "$(DESTDIR)$(SYSTEMD_USER_UNIT_PATH)"; find -type f -print0) | xargs -t -0 -I{} \
		sed -i -e 's|@bindir@|$(bindir)|g' -e 's|@libdir@|$(libdir)|g' "$(DESTDIR)$(SYSTEMD_USER_UNIT_PATH)/{}"
	
	$(INSTALL) -d "$(DESTDIR)$(docdir)" "$(DESTDIR)$(licensedir)"
	$(INSTALL_DATA) -D "$(srcdir)/README.md" "$(DESTDIR)$(docdir)/README.md"
	$(INSTALL_DATA) -D "$(srcdir)/CHANGELOG.md" "$(DESTDIR)$(docdir)/CHANGELOG.md"
	$(INSTALL_DATA) -D "$(srcdir)/LICENSE" "$(DESTDIR)$(licensedir)/LICENSE"

uninstall:
	rm -f "$(DESTDIR)$(bindir)/flatalias"
	rm -rf "$(DESTDIR)$(libdir)/flatalias"
	(cd "$(srcdir)/src/lib/flatalias/profile.d"; find -type f -print0) | xargs -t -0 -I{} \
		rm -f "$(DESTDIR)$(PROFILE_PATH)/{}"
	(cd "$(srcdir)/src/lib/systemd/user"; find -type f -print0) | xargs -t -0 -I{} \
		rm -f "$(DESTDIR)$(SYSTEMD_USER_UNIT_PATH)/{}"
	rm -rf "$(DESTDIR)$(docdir)" "$(DESTDIR)$(licensedir)"

clean:
	@echo "Nothing to clean."
