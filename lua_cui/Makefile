# makefile for lcurses library for Lua

# dist location
DISTDIR=$(HOME)/dist
TMP=/tmp

# change these to reflect your Lua installation
LUA=$(HOME)/local/lua
LUABIN= $(LUA)/bin
LUAINC= $(LUA)/include
#LUALIB= $(LUA)/lib
LUALIB= $(LUA)/bin

# no need to change anything below here
SHFLAGS= -fPIC
CFLAGS= $(INCS) $(DEFS) $(WARN) $(SHFLAGS) -O2
DEFS= # -DDEBUG
WARN= -Wall -Werror -ansi #-ansi -pedantic -Wall
INCS= -I$(LUAINC)
LIBS= -L$(LUALIB) -lpanel -lcurses

PDCURSES=0

#PDCurses
ifeq ($(PDCURSES),1)
SHFLAGS=
CC=gcc -mno-cygwin
LIBS= ../curses/panel.a ../curses/pdcurses.a lua51.dll
INCS= -I$(LUAINC) -I../curses
endif


.PHONY: doc

MYLIB=curses
MYNAME= curses
OBJS= src/lcurses.o

ifneq ($(PDCURSES),1)
T= curses.so
else
T= curses.dll
endif

VER=0.2
TARFILE = $(DISTDIR)/$(MYLIB)-$(VER).tar.gz
TARFILES = \
	README Makefile \
	lcurses.c lpanel.c \
	lcurses.html \
	requireso.lua curses.lua curses.panel.lua \
	test.lua \
	cui.lua cui.ctrls.lua testcui.lua \
	firework.lua interp.lua

all: $T

$T:	$(OBJS)
	$(CC) $(SHFLAGS) -o $@ -shared $(OBJS) $(LIBS)

src/lcurses.o: src/lcurses.c

clean:
	rm -f $(OBJS) $T core core.* a.out

dist:
	@echo 'Exporting...'
	@cvs export -r HEAD -d $(TMP)/$(MYLIB)-$(VER) $(MYLIB)
	@echo 'Compressing...'
	@tar -zcf $(TARFILE) -C $(TMP) $(MYLIB)-$(VER)
	@rm -fr $(TMP)/$(MYLIB)-$(VER)
	@lsum $(TARFILE) $(DISTDIR)/md5sums.txt
	@echo 'Done.'

doc:
	@mkdir -p docs NaturalDocs
	../NaturalDocs/NaturalDocs \
		-i lua -i src -i doc \
		-xi lua/.svn -xi src/.svn -xi doc/.svn \
		-p NaturalDocs \
		-o HTML docs \
		-s Default Styles
