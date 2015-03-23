#
# Copyright (c) 2015 Colin Rothwell
#
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249
# ("MRC2"), as part of the DARPA MRC research programme.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

CC=clang
CPP=clang++
CFLAGS=-march=x86-64 -Wall -Werror -g -DDMAMODEL -Ifuzz_dma
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
