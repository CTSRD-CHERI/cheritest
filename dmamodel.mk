CC=clang -march=x86-64
CFLAGS=-g -DDMAMODEL

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

x86-obj/generate_dma_test.o: fuzz_dma/generate_dma_test.c
	$(CC) -c $(CFLAGS) $(CFFLAGS) -I$(DMADIR) $^ -o $@

x86-obj/generate_dma_test: x86-obj/generate_dma_test.o $(DMAMODEL_LIB_OBJS)
	$(CC) $(CFLAGS) $(CFFLAGS) -I$(DMADIR) $^ -o $@
