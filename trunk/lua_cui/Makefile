# makefile for lua curses and lua cui library for Lua

# curses for mingw
PDCURSES       = ../pdcurses
PDCURSES_LIBS  = $(PDCURSES)/pdcurses.a

# change these to reflect your Lua installation
LUA            = $(HOME)/local/lua
LUA_INC_DIR    = -I$(LUA)/include
LUA_LIB_DIR    = -L$(LUA)/lib
LUA_LIBS       =

CURSES_INC_DIR =
CURSES_LIB_DIR =
CURSES_LIBS    = -lcurses

DOC_DIR	= docs

T_DIR	= lib
T	= cui
SO	= .so
WARN	= -Wall -Werror -ansi
CFLAGS	= $(WARN) -O2 $(LUA_INC_DIR) $(CURSES_INC_DIR)
LDFLAGS	=  $(LUA_LIB_DIR) $(LUA_LIBS) $(CURSES_LIB_DIR) $(CURSES_LIBS)

ifeq ($(MINGW),1)
	SO	 = .dll
	CFLAGS	+= -mno-cygwin
	LDFLAGS += -mno-cygwin

	LUA_LIBS      += $(LUA)/bin/lua51.dll
	CURSES_INC_DIR = -I$(PDCURSES)
	CURSES_LIB_DIR =
	CURSES_LIBS    =  $(PDCURSES_LIBS)
else
	CFLAGS	+= -fPIC
	LDFLAGS	+= -fPIC
endif

.PHONY: doc shared

all:
	@echo 'make [mingw|linux]'

mingw:
	$(MAKE) MINGW=1 shared

linux:
	$(MAKE) MINGW=0 shared

shared: $(T_DIR)/$(T)$(SO)

$(T_DIR)/$(T)$(SO): src/lcurses.c
	@mkdir -p $(T_DIR)
	$(CC) $(CFLAGS) -o $@ -shared $^ $(LDFLAGS)

clean:
	rm -f $(T_DIR)/$(TARGET)$(SO)

doc:
	@mkdir -p $(DOC_DIR) NaturalDocs
	../NaturalDocs/NaturalDocs \
		-i lua -i src -i doc \
		-xi lua/.svn -xi src/.svn -xi doc/.svn \
		-p NaturalDocs \
		-o HTML $(DOC_DIR) \
		-s Default Styles
