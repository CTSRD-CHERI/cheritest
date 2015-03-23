CC=clang
CPP=clang++
CFLAGS=-march=x86-64 -Wall -Werror -g -DDMAMODEL
CPPFLAGS=-std=c++11

CHERILIBS?=../../cherilibs/trunk
CHERILIBS_ABS:=$(realpath $(CHERILIBS))
DMADIR=$(CHERILIBS_ABS)/peripherals/DMA
vpath DMA% $(DMADIR)

TESTS =simple add big_dram byte line long_program loop nested_loop sub
TESTS+=successive_programs

DMAMODEL_LIB_OBJS=$(addprefix x86-obj/,DMAAsm.o DMAModelSimple.o DMAModel.o)

.PHONY: dmamodel 
dmamodel: $(addprefix x86-obj/dmamodel_, $(TESTS))

x86-obj/dmamodel_%.o: tests/dma/test_clang_dma_%.c
	$(CC) -c $(CFLAGS) $(CCFLAGS) -I$(DMADIR) $^ -o $@

x86-obj/DMAModelSimple.o: $(DMADIR)/DMAModelSimple.c
	$(CC) -c $(CFLAGS) $(CCFLAGS) -I$(DMADIR) $< -o $@

x86-obj/DMA%.o: $(DMADIR)/DMA%.c
	$(CC) -c $(CFLAGS) $(CCFLAGS) -I$(DMADIR) $< -o $@

x86-obj/dmamodel_%: x86-obj/dmamodel_%.o $(DMAMODEL_LIB_OBJS)
	$(CC) $(CFLAGS) $(CFFGLAGS) -I$(DMADIR) $^ -o $@

x86-obj/%.o: fuzz_dma/%.cpp
	$(CPP) -c $(CFLAGS) $(CPPFLAGS) $(CFFLAGS) -I$(DMADIR) $^ -o $@

x86-obj/%.o: fuzz_dma/%.c
	$(CC) -c $(CFLAGS) $(CFFLAGS) -I$(DMADIR) $^ -o $@

x86-obj/%: x86-obj/%.o
	$(CPP) -lstdc++ $(CFLAGS) $(CFFLAGS) -I$(DMADIR) $^ -o $@

run-%: x86-obj/%
	$< $(ARGS)

GEN_DMA_OBJS=x86-obj/dma_test_generation.o $(DMAMODEL_LIB_OBJS)
x86-obj/generate_dma_test: $(GEN_DMA_OBJS)

x86-obj/generate_multithread_dma_test: $(GEN_DMA_OBJS)
