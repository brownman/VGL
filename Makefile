DBGFLAGS := -g
OPTFLAGS := -O3 -fopenmp
#OPTFLAGS := -O3 -msse3 -m3dnow -mfpmath=sse
#OPTFLAGS := -O3

CXX := g++
CC  := gcc
LD  := g++

SRC := src
OBJ := build/obj
DIST := dist
BIN := bin
THIRDPARTY_SRC := thirdparty
THIRDPARTY_OBJ := build/thirdparty
EXAMPLE_SRC := example
EXAMPLE_OBJ := build/example

ifeq ($(OSTYPE), linux-gnu)
DYLIB_PRE := lib
DYLIB_EXT := .so
LIBVGL_BIN  := $(DIST)/lib/$(DYLIB_PRE)vgl$(DYLIB_EXT)
CXXFLAGS  := -Wall -m64 -fPIC -shared
LDFLAGS   := -m64 -fopenmp -Wl,--rpath,\$$ORIGIN -fPIC -shared
LDFLAGS_EXE := -m64 -fopenmp -Wl,--rpath,\$$ORIGIN
INCLUDE   := -I$(THIRDPARTY_SRC)
LIBS      := -lglut -lpthread -ljpeg -lpng -ltiff
else
DYLIB_PRE := lib
DYLIB_EXT := .dylib
LIBVGL_BIN  := $(DIST)/lib/$(DYLIB_PRE)vgl$(DYLIB_EXT)
CXXFLAGS  := -Wall -isysroot /Developer/SDKs/MacOSX10.6.sdk -arch x86_64 -shared
LDFLAGS   := -framework OpenGL -framework GLUT \
	-Wl,-syslibroot,/Developer/SDKs/MacOSX10.6.sdk -arch x86_64 -shared \
	-install_name @rpath/$(DYLIB_PRE)vgl$(DYLIB_EXT)
LDFLAGS_EXE := -framework OpenGL -framework GLUT \
	-Wl,-syslibroot,/Developer/SDKs/MacOSX10.6.sdk -arch x86_64 \
	-Wl,-rpath,@loader_path/
INCLUDE   := -I/opt/local/include -I$(THIRDPARTY_SRC)
LIBS      := -L/opt/local/lib -ljpeg -lpng -ltiff
endif

LIBVGL_OBJS :=  \
                $(OBJ)/vgl_camera.o \
                $(OBJ)/vgl_image.o \
                $(OBJ)/vgl_objparser.o \
                $(OBJ)/vgl_parser.o \
                $(OBJ)/vgl_plane3.o \
                $(OBJ)/vgl_plyparser.o \
                $(OBJ)/vgl_ray3.o \
                $(OBJ)/vgl_utils.o \
                $(OBJ)/vgl_vec2.o \
                $(OBJ)/vgl_vec3.o \
                $(OBJ)/vgl_vec4.o \
                $(OBJ)/vgl_viewer.o
LIBVGL_INCS :=  \
                $(DIST)/include/vgl.h \
                $(DIST)/include/vgl_camera.h \
                $(DIST)/include/vgl_image.h \
                $(DIST)/include/vgl_matrix3.h \
                $(DIST)/include/vgl_matrix4.h \
                $(DIST)/include/vgl_objparser.h \
                $(DIST)/include/vgl_parser.h \
                $(DIST)/include/vgl_plane3.h \
                $(DIST)/include/vgl_plyparser.h \
                $(DIST)/include/vgl_ray3.h \
                $(DIST)/include/vgl_renderer.h \
                $(DIST)/include/vgl_utils.h \
                $(DIST)/include/vgl_vec2.h \
                $(DIST)/include/vgl_vec3.h \
                $(DIST)/include/vgl_vec4.h \
                $(DIST)/include/vgl_viewer.h
THIRDPARTY_OBJS := $(THIRDPARTY_OBJ)/ply.o

EXAMPLE_BIN   := $(BIN)/example
EXAMPLE_OBJS  := $(EXAMPLE_OBJ)/example.o


.PRECIOUS: $(LIBVGL_OBJS) $(THIRDPARTY_OBJS)


.PHONY: debug
debug:
	$(MAKE) CXXFLAGS="$(DBGFLAGS) $(CXXFLAGS)" all


.PHONY: release
release:
	$(MAKE) CXXFLAGS="$(OPTFLAGS) $(CXXFLAGS)" all


.PHONY: all
all: build_libvgl build_example


.PHONY: dirs
dirs:
	@mkdir -p $(OBJ)
	@mkdir -p $(THIRDPARTY_OBJ)
	@mkdir -p $(DIST)/include
	@mkdir -p $(DIST)/lib
	@mkdir -p $(BIN)


.PHONY: build_example
build_example: dirs build_libvgl
	$(MAKE) -C $(EXAMPLE_SRC) CXXFLAGS="$(CXXFLAGS)" all
	cp $(LIBVGL_BIN) $(BIN)


.PHONY: build_libvgl
build_libvgl: dirs $(LIBVGL_BIN) $(LIBVGL_INCS)


$(LIBVGL_BIN): $(LIBVGL_OBJS) $(THIRDPARTY_OBJS)
	$(LD) $(LDFLAGS) -o  $@ $^ $(LIBS)


$(DIST)/include/%: $(SRC)/%
	cp $< $@


$(OBJ)/%.o: $(SRC)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@


$(THIRDPARTY_OBJ)/ply.o: $(THIRDPARTY_SRC)/ply.c
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@


.PHONY: clean
clean:
	rm -rf bin/* build/* dist/*

