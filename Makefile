# I need to fix this file, then remove all the *_Makefiles
# Then repeat this process to merge the different LICENSE files

# dwm - dynamic window manager
# st  - simple terminal
# See LICENSE file for copyright and license details.

#==============================================================================
# MAKE CONFIGURATION

.POSIX:
VERSION = 0.0.1

# paths
PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

PKG_CONFIG = pkg-config

# Xinerama, comment if you don't want it
XINERAMALIBS  = -lXinerama
XINERAMAFLAGS = -DXINERAMA

# freetype
FREETYPELIBS = -lfontconfig -lXft
FREETYPEINC = /usr/include/freetype2
# OpenBSD (uncomment)
#FREETYPEINC = ${X11INC}/freetype2

# includes and libs
INCS = -I${X11INC} -I${FREETYPEINC}
LIBS = -L${X11LIB} -lX11 ${XINERAMALIBS} ${FREETYPELIBS} -lXrender

# For st
#INCS = -I. -I/usr/include -I${X11INC} \
#       `$(PKG_CONFIG) --cflags fontconfig` \
#       `$(PKG_CONFIG) --cflags freetype2`
#LIBS = -L/usr/lib -lc -L${X11LIB} -lm -lrt -lX11 -lutil -lXft -lXrender\
#       `$(PKG_CONFIG) --libs fontconfig` \
#       `$(PKG_CONFIG) --libs freetype2`

# flags
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_POSIX_C_SOURCE=2 -DVERSION=\"${VERSION}\" ${XINERAMAFLAGS}
#CFLAGS   = -g -std=c99 -pedantic -Wall -O0 ${INCS} ${CPPFLAGS}
CFLAGS   = -std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os ${INCS} ${CPPFLAGS}
LDFLAGS  = ${LIBS}
STCPPFLAGS = -DVERSION=\"$(VERSION)\" -D_XOPEN_SOURCE=600
STCFLAGS = $(INCS) $(STCPPFLAGS) $(CPPFLAGS) $(CFLAGS)
STLDFLAGS = $(LIBS) $(LDFLAGS)


# compiler and linker
CC = cc

#==============================================================================
# PROJECT STATE

SRC = dwm.c st.c
OBJ = ${SRC:.c=.o}

#==============================================================================
# INTERNAL TARGETS

.c.o:
	${CC} -c ${CFLAGS} $<

# for st
#.c.o:
#	$(CC) $(STCFLAGS) -c $<

dwm.o: dwm_config.h
st.o: config.h

dwm: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

st: $(OBJ)
	$(CC) -o $@ $(OBJ) $(STLDFLAGS)

#==============================================================================
# CALLABLE TARGETS

.PHONY: all clean install uninstall

all: dwm st

clean:
	rm -f dwm ${OBJ} dwm-${VERSION}.tar.gz
	rm -f st  $(OBJ) st-$(VERSION).tar.gz

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwm ${DESTDIR}${PREFIX}/bin
	cp -f st  $(DESTDIR)$(PREFIX)/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwm
	chmod 755 $(DESTDIR)$(PREFIX)/bin/st
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < dwm.1 > ${DESTDIR}${MANPREFIX}/man1/dwm.1
	sed "s/VERSION/$(VERSION)/g" < st.1 > $(DESTDIR)$(MANPREFIX)/man1/st.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/dwm.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/st.1
	tic -sx st.info
	@echo Please see the README file regarding the terminfo entry of st.

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwm\
		${DESTDIR}${MANPREFIX}/man1/dwm.1
	rm -f $(DESTDIR)$(PREFIX)/bin/st\
		$(DESTDIR)$(MANPREFIX)/man1/st.1

