/*-
 * Copyright (c) 2015 Colin Rothwell
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * @BERI_LICENSE_HEADER_START@
 *
 * Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
 * license agreements.  See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership.  BERI licenses this
 * file to you under the BERI Hardware-Software License, Version 1.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 *   http://www.beri-open-systems.org/legal/license-1-0.txt
 *
 * Unless required by applicable law or agreed to in writing, Work distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * @BERI_LICENSE_HEADER_END@
 */

#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

#include "dma_test_generation.h"
#include "DMAModel.h"

typedef unsigned int uint;

/*
 * For generating non virtualised tests, need to output:
 * an array of programs
 * source address setting,
 * assertions.
 * an array of source addresses,
 * an array of destination addresses
 */

/*
 * For generating virtualised tests, each program needs to operate in its
 * input and output. The MIPS TLB does this weird thing where it allocates 8K
 * of contiguous virtual address to two potentially non-contiguous memory
 * locations in one way go. Let's allocate each thread an 8K contiguous
 * physical region for input and another for output. The longest generated
 * test I've seen so far takes source up to 0x540 whilst 8K is 0x2000, so we
 * should be ok.
 *
 * What are our restrictions on virtual/physical addressing?
 *
 * User address space is:
 * 0x0000 0000 0000 0000 to
 * 0x3FFF FFFF FFFF FFFF
 *
 * DRAM is:
 * 0x0000 0000 to
 * 0x3FFF FFFF
 *
 * But the "test kernel" will go into DRAM:
 * 0x0010 0000 to
 * 0x0FFF FFFF
 *
 * And all of the access to test goes through the "unmapped region".
 *
 * So allocate pages in physical regions
 * 0x1000 0000 (PN = 0x1 0000) to
 * 0x3FFF FFFF (PN = 0x3 FFFF) (This is 0x2 FFFF pages in total)
 *
 * And virtual pages up to PN
 * 0x0003 FFFF FFFF FFFF
 */

#define MIN_PHYS_PAGE   0x10000
#define MAX_PHYS_PAGE   0x3FFFF

#define VIRT_PAGE_COUNT 0x3FFFFFFFFFFFF

 /*
 * The tests will:
 * - Set up the desired source data (using the physical addresses).
 * - Set up the mappings from source to destination addresses.
 * - Do the aggressive thread switching thing.
 * - Check with physical addresses.
 *
 * We need to output source and dest addrs as normal apart from being in
 * random physical locations.
 *
 * Then output functions to add mappings.
 */

#define FOR_EACH(pointer, list)	\
	for(pointer = list; pointer != NULL; pointer = pointer->next)

const dma_address DRAM_START = 0x9000000010000000;

static inline dma_address
next_aligned(dma_address address, enum transfer_size width)
{
	dma_address size_in_bytes = (1 << width);
	dma_address mask = ~((1 << width) - 1);
	return (address + size_in_bytes - 1) & mask;
}

void
generate_programs(uint count, dma_instruction **programs)
{
	for (int i = 0; i < count; ++i) {
		programs[i] = generate_random_dma_program(myrand());
	}
}

void
generate_transfer_lists(uint count,
		struct transfer_record **transfer_lists,
		dma_instruction **programs)
{
	for (int i = 0; i < count; ++i) {
		transfer_lists[i] = list_transfers(programs[i]);
	}
}

void
print_programs(uint program_count, dma_instruction **programs)
{
	for (uint i = 0; i < program_count; ++i) {
		printf("(dma_instruction[]){");
		for (uint j = 0; ; ++j) {
			printf("0x%08x", programs[i][j]);
			if (programs[i][j] == DMA_OP_STOP) {
				break;
			}
			else {
				printf(", ");
			}
		}
		printf("}");
		if (i < (program_count - 1)) {
			printf(", ");
		}
	}
}

inline static dma_address
phys_pn_to_addr(dma_address phys_pn)
{
	return 0x9000000000000000 + (phys_pn << 12);
}

inline static dma_address
virt_pn_to_addr(dma_address virt_pn)
{
	return (virt_pn << 12);
}

inline static bool
in_addr_array(dma_address to_test, dma_address *array, size_t array_size)
{
	for (size_t i = 0; i < array_size; ++i) {
		if (array[i] == to_test) {
			return true;
		}
	}
	return false;
}

inline static dma_address
addr_in_range(dma_address min, dma_address max)
{
	// I think this might be biased against the last page. I think there
	// may also be pages that we never hit.
	dma_address count = max - min;
	return min + ((count * (dma_address)myrand()) / RAND_LIMIT);
}

inline static void
print_pointer_array(uint size, dma_address *array)
{
	for (uint i = 0; i < size; ++i) {
		printf("(uint8_t *)0x%llx", array[i]);
		if (i < (size - 1)) {
			printf(", ");
		}
	}
}

void
print_virtualised_test_information(uint thread_count, uint seed)
{
	mysrand(seed);

	uint i, j;

	size_t prog_arr_size = thread_count * sizeof(dma_instruction *);
	dma_instruction **programs = malloc(prog_arr_size);

	generate_programs(thread_count, programs);

	size_t tl_arr_size = thread_count * sizeof(struct transfer_record *);
	struct transfer_record **transfer_lists = malloc(tl_arr_size);
	struct transfer_record *current;

	generate_transfer_lists(thread_count, transfer_lists, programs);

	printf("#define DMA_ADDR DMA_VIRT$");
	print_programs(thread_count, programs);
	printf("$");

	size_t addr_arr_size = thread_count * sizeof(dma_address);
	// Allocate contiguously so we can easily check for duplicates
	dma_address *source_phys_pns = malloc(2 * addr_arr_size);
	dma_address *dest_phys_pns = source_phys_pns + addr_arr_size;
	dma_address *source_virt_pns = malloc(2 * addr_arr_size);
	dma_address *dest_virt_pns = source_virt_pns + addr_arr_size;

	dma_address next_addr;

	for (i = 0; i < thread_count; ++i) {
		// & ~1 to force even, due to MIPS TLB.
		do {
			next_addr = addr_in_range(MIN_PHYS_PAGE, MAX_PHYS_PAGE);
			next_addr &= ~1;
		} while (in_addr_array(next_addr, source_phys_pns, i));
		source_phys_pns[i] = next_addr;

		do {
			next_addr = addr_in_range(MIN_PHYS_PAGE, MAX_PHYS_PAGE);
			next_addr &= ~1;
		} while (in_addr_array(next_addr, source_phys_pns,
					i + addr_arr_size));
		dest_phys_pns[i] = next_addr;

		do {
			next_addr = addr_in_range(0, VIRT_PAGE_COUNT) & ~1;
		} while (in_addr_array(next_addr, source_virt_pns, i));
		source_virt_pns[i] = next_addr;

		do {
			next_addr = addr_in_range(0, VIRT_PAGE_COUNT) & ~1;
		} while (in_addr_array(next_addr, source_virt_pns,
					i + addr_arr_size));
		dest_virt_pns[i] = next_addr;
	}

	// We output the mapping before the sources, using the same region of
	// the test. This is naughty, but it works.

	for (i = 0; i < thread_count; ++i) {
		printf("add_tlb_mapping(0x%llx, 0x%llx, 0x%llx);",
			source_virt_pns[i],
			source_phys_pns[i], source_phys_pns[i] + 1);
		printf("add_tlb_mapping(0x%llx, 0x%llx, 0x%llx);",
			dest_virt_pns[i],
			dest_phys_pns[i], dest_phys_pns[i] + 1);
	}

	dma_address thread_source, transfer_source;
	uint8_t access_number = 0;
	uint transfer_size;

	for (i = 0; i < thread_count; ++i) {
		thread_source = phys_pn_to_addr(source_phys_pns[i]);
		FOR_EACH(current, transfer_lists[i]) {
			transfer_size = (1 << current->size);
			transfer_source = thread_source + current->source;
			for (j = 0; j < transfer_size; ++j) {
				printf("*((volatile uint8_t *)0x%llx) = %d;",
					transfer_source + j, access_number);
				++access_number;
			}
		}
	}
	printf("$assert(1 ");

	dma_address thread_dest, transfer_dest;
	access_number = 0;
	for (i = 0; i < thread_count; ++i) {
		thread_dest = phys_pn_to_addr(dest_phys_pns[i]);
		FOR_EACH(current, transfer_lists[i]) {
			transfer_size = (1 << current->size);
			transfer_dest = thread_dest + current->destination;
			for (j = 0; j < transfer_size; ++j) {
				printf("&& *((volatile uint8_t *)0x%llx) == %d ",
					transfer_dest + j, access_number);
				++access_number;
			}
		}
	}

	dma_address *source_virt_addrs = malloc(addr_arr_size);
	dma_address *dest_virt_addrs = malloc(addr_arr_size);

	for (i = 0; i < thread_count; ++i) {
		source_virt_addrs[i] = virt_pn_to_addr(source_virt_pns[i]);
		dest_virt_addrs[i] = virt_pn_to_addr(dest_virt_pns[i]);
	}

	printf(");$");
	print_pointer_array(thread_count, source_virt_addrs);
	printf("$");
	print_pointer_array(thread_count, dest_virt_addrs);

	for (i = 0; i < thread_count; ++i) {
		free(programs[i]);
		free_transfer_list(transfer_lists[i]);
	}
	free(programs);
	free(transfer_lists);
	free(source_phys_pns);
	free(dest_virt_pns);
	free(source_virt_addrs);
	free(dest_virt_pns);
}

void
print_test_information(uint thread_count, uint seed)
{
	mysrand(seed);

	/* Generate programs, and evaluate results */
	uint i, j;

	size_t prog_arr_size = thread_count * sizeof(dma_instruction *);
	dma_instruction **programs = malloc(prog_arr_size);

	generate_programs(thread_count, programs);

	size_t tl_arr_size = thread_count * sizeof(struct transfer_record *);
	struct transfer_record **transfer_lists = malloc(tl_arr_size);
	struct transfer_record *current;

	generate_transfer_lists(thread_count, transfer_lists, programs);

	printf("#define DMA_ADDR DMA_VIRT$");
	print_programs(thread_count, programs);
	printf("$");

	dma_address dram_position = DRAM_START;
	dma_address *source_addrs = malloc(thread_count * sizeof(dma_address));
	dma_address *dest_addrs = malloc(thread_count * sizeof(dma_address));

	uint8_t access_number = 0;
	uint transfer_size;

	for (i = 0; i < thread_count; ++i) {
		current = transfer_lists[i];
		if (current != NULL) {
			dram_position =
				next_aligned(dram_position, current->size);
			source_addrs[i] = dram_position;
		}

		FOR_EACH(current, transfer_lists[i]) {
			transfer_size = (1 << current->size);
			dram_position = source_addrs[i] + current->source;
			for (j = 0; j < transfer_size; ++j) {
				printf("*((volatile uint8_t *)0x%llx) = %d;",
					dram_position, access_number);
				++dram_position;
				++access_number;
			}
		}
	}
	printf("$assert(1 ");

	access_number = 0;
	for (i = 0; i < thread_count; ++i) {
		current = transfer_lists[i];
		if (current != NULL) {
			dram_position =
				next_aligned(dram_position, current->size);
			dest_addrs[i] = dram_position;
		}
		FOR_EACH(current, transfer_lists[i]) {
			transfer_size = (1 << current->size);
			dram_position = dest_addrs[i] + current->destination;
			for (j = 0; j < transfer_size; ++j) {
				printf("&& *((volatile uint8_t *)0x%llx) == %d ",
					dram_position, access_number);
				++dram_position;
				++access_number;
			}
		}
	}


	printf(");$");
	print_pointer_array(thread_count, source_addrs);
	printf("$");
	print_pointer_array(thread_count, dest_addrs);
	
	/* Free resources */
	for (i = 0; i < thread_count; ++i) {
		free(programs[i]);
		free_transfer_list(transfer_lists[i]);
	}
	free(programs);
	free(transfer_lists);
	free(source_addrs);
	free(dest_addrs);
}

int
_main(int argc, char* argv[])
{
	dma_address test_data[3] = {3, 0, 2};

	printf("%d\n", in_addr_array(2, test_data, 3));
	printf("%d\n", in_addr_array(1, test_data, 3));
	printf("%d\n", in_addr_array(3, test_data, 0));

	return 0;
}


int
main(int argc, char* argv[])
{
	if (argc != 6 ||
			!(strcmp(argv[1], "virt") == 0 ||
			  strcmp(argv[1], "phys") == 0)) {
		printf(
"Usage: <virt|phys> <min thread count> <max thread count> <min seed> <max seed>\n");
		return 1;
	}
	int thread_lower = atoi(argv[2]);
	int thread_higher = atoi(argv[3]);
	int seed_lower = atoi(argv[4]);
	int seed_higher = atoi(argv[5]);

	for (int i = thread_lower; i <= thread_higher; ++i) {
		for (int j = seed_lower; j <= seed_higher; ++j) {
			if (strcmp(argv[1], "virt") == 0) {
				print_virtualised_test_information(i, j);
			}
			else { //argv[1] == phys
				print_test_information(i, j);
			}
			printf("\n");
		}
	}

	return 0;
}
