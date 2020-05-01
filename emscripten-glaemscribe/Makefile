#
# Copyright (C) 2014-2017 Eitan Isaacson
# Copyright (C) 2016-2017 Alberto Pettarin
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see: <http://www.gnu.org/licenses/>.
#

# NOTE: variables specific to espeak-ng + emscripten starts with "EM_"

# NOTE: set to 1 to debug or to speed emscripten up while developing.
#       If the EM_DEBUG environment variable is set,
#       the value specified here will be ignored.
EM_DEBUG ?= 0
ifneq ($(EM_DEBUG), 1)
	CXXFLAGS+=-O3
endif



###############################################################################
# WARNING: modify code below this line at your own risk!
###############################################################################

# NOTE: sanity check
ifndef EMSCRIPTEN
	$(error EMSCRIPTEN var not set. You must use emmake to run this Makefile!)
endif

# NOTE: in the emscripten virtual FS,
#       this is the location of the eSpeak-ng data files,
#       if we configure with "./configure --prefix=/usr"
EM_VIRTUAL_PATH_ESPEAKNG_DATA=/usr/share/espeak-ng-data

# NOTE: emmake will replace EMSCRIPTEN with the actual root directory
#       of the emscripten tools inside the emscripten SDK directory
EM_WEBIDL_BINDER=python $(EMSCRIPTEN)/tools/webidl_binder.py
EM_FILE_PACKAGER=python $(EMSCRIPTEN)/tools/file_packager.py

# NOTE: libespeak-ng.so (Linux) or libespeak-ng.dylib (macOS) compiled to LLVM IR code
EM_LIBESPEAKNG_SO=$(wildcard ../src/.libs/libespeak-ng.so)
EM_LIBESPEAKNG_A=$(wildcard ../src/.libs/libespeak-ng.a)
ifneq ($(EM_LIBESPEAKNG_SO),)
	EM_LIBESPEAKNG=$(EM_LIBESPEAKNG_SO)
else ifneq ($(EM_LIBESPEAKNG_A),)
	EM_LIBESPEAKNG=$(EM_LIBESPEAKNG_A)
endif

# NOTE: glue code files
EM_GLUE_PREFIX=glue
EM_GLUE_IDL=espeakng_glue.idl
EM_GLUE_OBJ=espeakng_glue.o
EM_GLUE_CPP=espeakng_glue.cpp
EM_GLUE_AUTOGEN_CPP=glue.cpp
EM_GLUE_AUTOGEN_JS=glue.js

# NOTE: preload espeak-ng-data directory...
EM_DATA_DIR=../espeak-ng-data
# NOTE: ... but exclude these subdirectories/files
EM_EXCLUDE_DATA=../espeak-ng-data/mbrola_ph ../espeak-ng-data/phondata-manifest

# NOTE: pre/post JS files
EM_PRE_JS=pre.js
EM_POST_JS=post.js

# NOTE: output files
EM_ESPEAKNG_DATA=build/js/espeakng.for.glaemscribe.embed.data
EM_ESPEAKNG_DATA_PACKAGE_JS=build/js/espeakng.for.glaemscribe.data.js
EM_SYNC_WASM_JS=build/js/espeakng.for.glaemscribe.wasm.sync.js
EM_ASYNC_WASM_JS=build/js/espeakng.for.glaemscribe.wasm.async.js
EM_SYNC_NOWASM_JS=build/js/espeakng.for.glaemscribe.nowasm.sync.js

# NOTE: intermediate objects
EM_ALL_PRE_JS=$(EM_PRE_JS) $(EM_ESPEAKNG_DATA_PACKAGE_JS)
EM_ALL_POST_JS=$(EM_GLUE_AUTOGEN_JS) $(EM_POST_JS)

# NOTE: compile without async, i.e. with synchronous output
#
# ./emconfigure ./configure --prefix=/usr --without-async
# ./emmake make
CXXFLAGS+=-DESPEAK_DATA_PATH=\"$(EM_VIRTUAL_PATH_ESPEAKNG_DATA)\"
CXXFLAGS+=-I ./ -I ../  -I ../src/include -I ../src/include/espeak-ng -I ../src/ucd-tools/src/include

# NOTE: so far, pthread is not supported in any browser
#       except Firefox Nightly.
#       If we want to enable pthread in the future,
#       we must append "-s USE_PTHREADS=1" to CXXFLAGS
#       and pass that to emconfigure and emmake.
#       If enabled, js/pthread-main.js will be created as well.
#
#CXXFLAGS+=-s USE_PTHREADS=1

# NOTE: extra flags for emscripten
# This is really important
# WASM has been activated by default in emscripten but it generates some issues regarding sync/async loading.
#
# Synchronous + WASM 	does not work under chrome
#											works under firefox
# 										works under mini_racer
#
# Asynchronous + WASM works under chrome
#											works under firefox
#											does not work under mini_racer
#
# Since we don't want a nightmare headache in loading the engine, we will stay syncrhonous, without WASM.

EM_CXXFLAGS_COMMON=-s RESERVED_FUNCTION_POINTERS=2 --memory-init-file 0 -s SINGLE_FILE -s FORCE_FILESYSTEM=1 
EM_CXXFLAGS_SYNC_NOWASM=$(EM_CXXFLAGS_COMMON) -s WASM=0
EM_CXXFLAGS_SYNC_WASM=$(EM_CXXFLAGS_COMMON) -s WASM=1 -s BINARYEN_ASYNC_COMPILATION=0
EM_CXXFLAGS_ASYNC_WASM=$(EM_CXXFLAGS_COMMON) -s WASM=1 -s BINARYEN_ASYNC_COMPILATION=1 -s MODULARIZE=1 -s 'EXPORT_NAME="GlaemscribeEspeakNG"'


###############################################################################
# NOTE: actual targets
###############################################################################

all: $(EM_SYNC_WASM_JS) $(EM_ASYNC_WASM_JS) $(EM_SYNC_NOWASM_JS)


# NOTE : use --preload for preloaded version (for the web), 
# or --embed for embedded version (for node)
# or --embed for double compatibility
$(EM_ESPEAKNG_DATA):
	$(EM_FILE_PACKAGER) $@ \
		--js-output=$(EM_ESPEAKNG_DATA_PACKAGE_JS) \
		--embed $(EM_DATA_DIR)@$(EM_VIRTUAL_PATH_ESPEAKNG_DATA) \
		$(patsubst %,--exclude %,$(EM_EXCLUDE_DATA))

$(EM_ESPEAKNG_DATA_PACKAGE_JS): $(EM_ESPEAKNG_DATA)

$(EM_GLUE_AUTOGEN_CPP): $(EM_GLUE_IDL)
	$(EM_WEBIDL_BINDER) $(EM_GLUE_IDL) $(EM_GLUE_PREFIX)

$(EM_GLUE_AUTOGEN_JS): $(EM_GLUE_AUTOGEN_CPP)

$(EM_GLUE_OBJ): $(EM_GLUE_CPP)

$(EM_SYNC_WASM_JS): $(EM_GLUE_AUTOGEN_CPP) $(EM_GLUE_OBJ) $(EM_ALL_PRE_JS) $(EM_ALL_POST_JS)
ifeq ($(EM_LIBESPEAKNG),)
	$(error Unable to find ../src/.libs/libespeak-ng .so or .dylib. Aborting!)
endif
	$(CXX) $(CXXFLAGS) \
		$(EM_CXXFLAGS_SYNC_WASM) \
		$(EM_LIBESPEAKNG) \
		$(EM_GLUE_OBJ) \
		$(patsubst %,--pre-js %,$(EM_ALL_PRE_JS)) \
		$(patsubst %,--post-js %,$(EM_ALL_POST_JS)) \
		-o $@
		
$(EM_ASYNC_WASM_JS): $(EM_GLUE_AUTOGEN_CPP) $(EM_GLUE_OBJ) $(EM_ALL_PRE_JS) $(EM_ALL_POST_JS)
ifeq ($(EM_LIBESPEAKNG),)
	$(error Unable to find ../src/.libs/libespeak-ng .so or .dylib. Aborting!)
endif
	$(CXX) $(CXXFLAGS) \
		$(EM_CXXFLAGS_ASYNC_WASM) \
		$(EM_LIBESPEAKNG) \
		$(EM_GLUE_OBJ) \
		$(patsubst %,--pre-js %,$(EM_ALL_PRE_JS)) \
		$(patsubst %,--post-js %,$(EM_ALL_POST_JS)) \
		-o $@		
		
$(EM_SYNC_NOWASM_JS): $(EM_GLUE_AUTOGEN_CPP) $(EM_GLUE_OBJ) $(EM_ALL_PRE_JS) $(EM_ALL_POST_JS)
ifeq ($(EM_LIBESPEAKNG),)
	$(error Unable to find ../src/.libs/libespeak-ng .so or .dylib. Aborting!)
endif
	$(CXX) $(CXXFLAGS) \
		$(EM_CXXFLAGS_SYNC_NOWASM) \
		$(EM_LIBESPEAKNG) \
		$(EM_GLUE_OBJ) \
		$(patsubst %,--pre-js %,$(EM_ALL_PRE_JS)) \
		$(patsubst %,--post-js %,$(EM_ALL_POST_JS)) \
		-o $@				
		

clean-intermediate:
	rm -f *.o *.out *.pkl $(EM_GLUE_AUTOGEN_CPP) $(EM_GLUE_AUTOGEN_JS) $(EM_ESPEAKNG_DATA_PACKAGE_JS)

clean: clean-intermediate
	rm -f $(EM_ESPEAKNG_DATA) $(EM_SYNC_NOWASM_JS) $(EM_ASYNC_WASM_JS) $(EM_SYNC_WASM_JS)

help:
	echo "Available targets: all clean clean-intermediate help"

