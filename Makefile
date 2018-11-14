# set LD_LIBRARY_PATH
optimization = 0

export CC  = gcc
export CXX = g++
export NVCC =nvcc
include config.mk
include mshadow/make/mshadow.mk

ifeq ($(optimization), 1)
export CFLAGS = -Wall -O3 -std=c++11 -Imshadow/ $(MSHADOW_CFLAGS)
export NVCCFLAGS = -O3 --use_fast_math -ccbin $(CXX) $(MSHADOW_NVCCFLAGS)
else
export NVCCFLAGS = -g --use_fast_math -ccbin $(CXX) $(MSHADOW_NVCCFLAGS)
export CFLAGS = -Wall -g -std=c++11 -Imshadow/ $(MSHADOW_CFLAGS)
$(warning,"use debug mode")
endif
export LDFLAGS= -lm $(MSHADOW_LDFLAGS)

# specify tensor path
BIN = main
OBJ =
CUOBJ =
CUBIN =
.PHONY: clean all

all: $(BIN) $(OBJ) $(CUBIN) $(CUOBJ)

main: main.cpp
# defop: defop.cpp
basic_stream: basic_stream.cu

$(BIN) :
	$(CXX) $(CFLAGS) -o $@ $(filter %.cpp %.o %.c, $^)  $(LDFLAGS)

$(OBJ) :
	$(CXX) -c $(CFLAGS) -o $@ $(firstword $(filter %.cpp %.c, $^) )

$(CUOBJ) :
	$(NVCC) -c -o $@ $(NVCCFLAGS) -Xcompiler "$(CFLAGS)" $(filter %.cu, $^)

$(CUBIN) :
	$(NVCC) -o $@ $(NVCCFLAGS) -Xcompiler "$(CFLAGS)" -Xlinker "$(LDFLAGS)" $(filter %.cu %.cpp %.o, $^)

clean:
	$(RM) $(OBJ) $(BIN) $(CUBIN) $(CUOBJ) *~
