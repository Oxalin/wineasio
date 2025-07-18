#!/usr/bin/make -f
# Makefile for WineASIO #
# --------------------- #
# Created by falkTX
# Initially generated by winemaker
#

ifeq ($(ARCH),)
$(error incorrect use of Makefile, ARCH var is missing)
endif
ifeq ($(M),)
$(error incorrect use of Makefile, M var is missing)
endif

wineasio_dll_MODULE   = wineasio$(M).dll

DLLS                  = $(wineasio_dll_MODULE) $(wineasio_dll_MODULE).so

PKG_CONFIG_PATH ?= /usr/lib$(M)/pkgconfig
WINE_INCLUDE_PATH		?= /usr/include/wine
WINE_LIBDIR ?= /usr/lib$(M)/wine

### Tools

CC        = gcc
WINEBUILD = winebuild
WINECC    = winegcc

### Common settings

CEXTRA                = -m$(M) -D_REENTRANT -fPIC -Wall -pipe
CEXTRA               += -fno-strict-aliasing -Wdeclaration-after-statement -Wwrite-strings -Wpointer-arith
CEXTRA               += -Werror=implicit-function-declaration
CEXTRA               += $(shell PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" pkg-config --cflags jack)
RCEXTRA               =
INCLUDE_PATH          = -I. -Irtaudio/include
INCLUDE_PATH         += -I$(WINE_INCLUDE_PATH)
INCLUDE_PATH         += -I$(WINE_INCLUDE_PATH)/windows
LIBRARIES             = $(shell PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" pkg-config --libs jack)

# Debug or Release
ifeq ($(DEBUG),true)
CEXTRA               += -O0 -DDEBUG -g -D__WINESRC__ -v
else
CEXTRA               += -O2 -DNDEBUG -fvisibility=hidden
endif

### wineasio.dll settings

wineasio_dll_C_SRCS   = asio.c \
			main.c \
			regsvr.c
wineasio_dll_LDFLAGS  = -shared \
			-m$(M) \
			wineasio.dll.spec \
			-L/usr/lib$(M)/wine \
			-L$(WINE_LIBDIR) \
			-L$(WINE_LIBDIR)/$(ARCH)-unix \
			-L$(WINE_LIBDIR)/$(ARCH)-windows
wineasio_dll_DLLS     = odbc32 \
			ole32 \
			winmm
wineasio_dll_LIBRARIES = uuid

wineasio_dll_OBJS     = $(wineasio_dll_C_SRCS:%.c=build$(M)/%.c.o)

### Global source lists

C_SRCS                = $(wineasio_dll_C_SRCS)

### Generic targets

all:
build: $(DLLS:%=build$(M)/%)

### Build rules

.PHONY: all

# Implicit rules

build$(M)/%.c.o: %.c
	@$(shell mkdir -p build$(M))
	$(CC) -c $(INCLUDE_PATH) $(CFLAGS) $(CEXTRA) -o $@ $<

### Target specific build rules

build$(M)/$(wineasio_dll_MODULE): $(wineasio_dll_OBJS)
	$(WINEBUILD) -m$(M) --dll --fake-module -E wineasio.dll.spec $^ -o $@

build$(M)/$(wineasio_dll_MODULE).so: $(wineasio_dll_OBJS)
	$(WINECC) $^ $(wineasio_dll_LDFLAGS) $(LIBRARIES) \
		$(wineasio_dll_DLLS:%=-l%) $(wineasio_dll_LIBRARIES:%=-l%) -o $@
