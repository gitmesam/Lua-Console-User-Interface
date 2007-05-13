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

DOC_DIR	= doc/html

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

doc-code:
	@mkdir -p $(DOC_DIR)/api NaturalDocs
	../NaturalDocs/NaturalDocs \
		-i lua -i src \
		-xi lua/.svn -xi src/.svn -xi doc/.svn \
		-p NaturalDocs \
		-o HTML $(DOC_DIR)/api \
		-s Default Styles

DOC_SRC = doc/src
DOC_DST = $(DOC_DIR)
DOC_FILES = index

DOC_SHARED = \
	$(DOC_SRC)/header.t2t \
	$(DOC_SRC)/footer.t2t \
	$(DOC_SRC)/config.t2t

$(DOC_DST)/%.html: $(DOC_SRC)/%.t2t $(DOC_SHARED)
	txt2tags --target html -i $< -o $@ --no-rc

$(DOC_DST)/%: $(DOC_SRC)/%
	cp $^ $@

doc-html: $(DOC_DST)/index.html $(DOC_DST)/main.css

doc: doc-html doc-code