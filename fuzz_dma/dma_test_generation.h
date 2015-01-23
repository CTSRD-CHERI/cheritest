#ifndef DMA_TEST_GENERATION_H
#define DMA_TEST_GENERATION_H

#include "DMAAsm.h"
#include "DMAModel.h"

static unsigned long next = 1;
#define RAND_LIMIT 32767

int myrand();
void mysrand(unsigned _seed);


struct transfer_record;

struct transfer_record {
	dma_address source;
	dma_address destination;
	enum transfer_size size;

	struct transfer_record *next;
};

struct transfer_record *list_transfers(dma_instruction *program);

dma_instruction *generate_random_dma_program(unsigned int _seed);

#endif
