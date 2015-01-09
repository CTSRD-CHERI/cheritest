#include "assert.h"
#include "stdio.h"
#include "stdlib.h"

#include "DMAAsm.h"
#include "DMADisasm.h"
#include "DMAModel.h"

static unsigned long next = 1;

#define RAND_LIMIT 32767

int myrand(void) {
	next = next * 1103515245 + 12345;
	return((unsigned)(next/65536) % 32768);
}

void mysrand(unsigned seed) {
	next = seed;
}

struct transfer_record;

struct transfer_record {
	dma_address source;
	dma_address destination;
	enum transfer_size size;

	struct transfer_record *next;
};

static void
record_transfer(void *context,
	dma_address source, dma_address destination, enum transfer_size size)
{
	struct transfer_record *tail = (struct transfer_record *)context;
	tail->next = malloc(sizeof(struct transfer_record));
	tail = tail->next;

	tail->source = source;
	tail->destination = destination;
	tail->size = size;
	tail->next = NULL;
}

struct transfer_record *
list_transfers(dma_instruction *program)
{
	struct transfer_record *false_head, *true_head, *tail;
        false_head = malloc(sizeof(struct transfer_record));
	tail = false_head;

	struct dma_thread thread;
	thread.dmat_program_counter =
		thread.dmat_external_program_counter = program;
	// Use 0 because we are interested in relative offsets.
	thread.dmat_source = thread.dmat_external_source = 0;
	thread.dmat_destination = thread.dmat_external_destination = 0;
	thread.dmat_state = DMAM_RUNNING;

	while (thread.dmat_state != DMAM_STOPPED) {
		dma_execute_instruction(&thread, record_transfer, tail);
		if (tail->next != NULL) {
			tail = tail->next;
		}
	}

	true_head = false_head->next;
	free(false_head);

	return true_head;
}

enum dma_program_node_type {
	DMAPNT_LOOP,
	DMAPNT_SEQ,
	DMAPNT_OP
};

struct dma_program_node;

struct dma_program_node {
	enum dma_program_node_type	dmapn_type;
	struct dma_program_node		*dmapn_left_child;
	struct dma_program_node		*dmapn_right_child;

	struct dma_program_node		*dmapn_next_space;
};

struct dma_program_node *
random_dma_program_structure(unsigned int seed)
{
	// So that test sequences are reproducable.
	mysrand(seed);

	// It is suprisingly difficult to come up with a routine to generate
	// valid DMA programs. Our main constraint is that we don't try to
	// set a loop counter in the body of a loop. I also want to generate
	// various interesting patterns of loops, and ensure that each loop
	// performs some interesting work.
	//
	// So, let's build up a tree. A tree node has up to two children, and
	// can be of four different types. It can be a loop: we can't have a
	// depth greater than 4 of loops. It can be an add, or transfer. It
	// can be a sequence. This whole proces is a bit hacky and ad-hoc. I
	// have a python script modelling the size of the program generated.
	// The parameters here give an average program length of 12, with a
	// maximum of around 23.

	struct dma_program_node *root, *next_space, *last_space, *left, *right;
	root = malloc(sizeof(struct dma_program_node));
	next_space = last_space = root;

	// Not technically a limit, but when the program gets this long, we
	// start definitely filling in gaps.
	const long LENGTH_LIMIT = 12;
	const long SPACE_LIMIT = 10;

	// These are longs so that we can multiply constants by RAND_LIMIT
	// without worrying.
	long spaces = 1;
	long program_length = 0;
	long space_bias, length_bias;

	int p;
	// The idea is we are more likely to add operations when the program
	// gets longer, and more likely to add spaces when there are fewer
	// spaces. The whole thing is unrolled, so we don't have to do divide,
	// which would require float conversion etc.
	while (spaces > 0) {
		p = myrand();
		space_bias = SPACE_LIMIT - spaces;
		length_bias = LENGTH_LIMIT - program_length;
		if ((LENGTH_LIMIT * p) > (RAND_LIMIT * length_bias)) {
			// fill in next space with operation
			next_space->dmapn_type = DMAPNT_OP;

			program_length += 1;
			spaces -= 1;
		}
		else if (LENGTH_LIMIT * SPACE_LIMIT * p >
				(RAND_LIMIT * length_bias * space_bias)) {
			// fill in with loop
			next_space->dmapn_type = DMAPNT_LOOP;
			left = malloc(sizeof(struct dma_program_node));
			next_space->dmapn_left_child = left;
			last_space->dmapn_next_space = left;
			last_space = left;

			program_length += 2;
		}
		else {
			next_space->dmapn_type = DMAPNT_SEQ;
			left = malloc(sizeof(struct dma_program_node));
			right = malloc(sizeof(struct dma_program_node));
			next_space->dmapn_left_child = left;
			next_space->dmapn_right_child = right;
			last_space->dmapn_next_space = left;
			left->dmapn_next_space = right;
			last_space = right;

			spaces += 1;
		}
		next_space = next_space->dmapn_next_space;
	}

	return root;
}

void
print_dma_program(struct dma_program_node *program)
{
	switch (program->dmapn_type) {
	case DMAPNT_LOOP:
		printf("L(");
		print_dma_program(program->dmapn_left_child);
		printf(")");
		break;
	case DMAPNT_SEQ:
		/*printf("S (");*/
		print_dma_program(program->dmapn_left_child);
		/*printf(", ");*/
		printf(" ");
		print_dma_program(program->dmapn_right_child);
		/*printf(")");*/
		break;
	case DMAPNT_OP:
		printf("T");
		break;
	}
}

unsigned int
dma_program_length(struct dma_program_node *program)
{
	unsigned int length = 0;
	switch (program->dmapn_type) {
	case DMAPNT_LOOP:
		return 2 + dma_program_length(program->dmapn_left_child);
	case DMAPNT_SEQ:
		return dma_program_length(program->dmapn_left_child) +
			dma_program_length(program->dmapn_right_child);
	case DMAPNT_OP:
		return 1;
	}
}

/*
 * We notably don't generate sub instructions. This is obviously bad, but does
 * make things simpler: in particular, the DMA will never overwrite anything
 * that is has previously written.
 */
void
write_random_dma_program(struct dma_program_node *structure,
		dma_instruction **next_pp, int loop_level,
		enum transfer_size ts)
{
	assert(loop_level <= 4);
	struct dma_program_node *body, *left, *right;
	int body_length;
	switch (structure->dmapn_type) {
	case DMAPNT_LOOP:
		**next_pp = DMA_OP_SET(loop_level, 1 + myrand() % 5);
		++(*next_pp);
		body = structure->dmapn_left_child;
		body_length = dma_program_length(body);
		write_random_dma_program(body, next_pp, loop_level+1, ts);
		**next_pp = DMA_OP_LOOP(loop_level, body_length);
		++(*next_pp);
		break;
	case DMAPNT_SEQ:
		left = structure->dmapn_left_child;
		right = structure->dmapn_right_child;
		write_random_dma_program(left, next_pp, loop_level, ts);
		write_random_dma_program(right, next_pp, loop_level, ts);
		break;
	case DMAPNT_OP:
		if (myrand() % 2 == 0) {
			**next_pp = DMA_OP_TRANSFER(ts);
		}
		else {
			**next_pp = DMA_OP_ADD(myrand() % 3,
					(1 << ts) * (myrand() % 20));
		}
		++(*next_pp);
		break;
	}
}

dma_instruction *
random_fill_structure(struct dma_program_node *structure)
{
	/* +1 for stop */
	unsigned int length = dma_program_length(structure) + 1;
	dma_instruction *program = malloc(length * sizeof(dma_instruction));
	dma_instruction *next = program;
	write_random_dma_program(structure, &next, 0, myrand() % 6);
	*next = DMA_OP_STOP;
	return program;
}

void
free_dma_structure(struct dma_program_node *program)
{
	switch (program->dmapn_type) {
	case DMAPNT_LOOP:
		free_dma_structure(program->dmapn_left_child);
		free(program);
		break;
	case DMAPNT_SEQ:
		free_dma_structure(program->dmapn_left_child);
		free_dma_structure(program->dmapn_right_child);
		free(program);
		break;
	case DMAPNT_OP:
		free(program);
		break;
	}
}

void
print_test_information(unsigned seed)
{
	// Generate test, and output instruction list.
	dma_instruction *program;
	struct dma_program_node *structure;
	structure = random_dma_program_structure(seed);
	program = random_fill_structure(structure);

	for (int i = 0; ; ++i) {
		printf("0x%08x", program[i]);
		if (program[i] == DMA_OP_STOP) {
			break;
		}
#ifdef DISASSEMBLE_DMA
		else {
			printf(", /* ");
			print_dma_instruction(program[i]);
			printf(" */\n");
		}
#endif
	}
	printf("$");

	uint8_t access_number = 0;
	struct transfer_record *transfer_list, *current;
	transfer_list = list_transfers(program);

	for (current = transfer_list; current != NULL;
			current = current->next) {
		for (int i = 0; i < (1 << current->size); ++i) {
			printf("source[%lld] = %d;",
					current->source + i, access_number);
			++access_number;
		}
		if (current->next == NULL) {
			printf("$%lld$",
				current->source + (1 << current->size));
		}
	}

	access_number = 0;
	for (current = transfer_list; current != NULL;
			current = current->next) {
		for (int i = 0; i < (1 << current->size); ++i) {
			printf("assert(dest[%lld] == %d);",
					current->destination + i, access_number);
			++access_number;
		}
		if (current->next == NULL) {
			printf("$%lld",
				current->destination + (1 << current->size));
		}
	}
}

int main(int argc, char* argv[])
{
	if (argc == 2) {
		print_test_information(atoi(argv[1]));
	}
	else {
		printf("Invalid number of arguments: %d. Expected 1.\n",
			argc - 1);
	}
	return 0;
}


int test_routines()
{
	goto PRINT_PROGRAMS;

	unsigned int lengths[26];
	for (int i = 0; i < 26; ++i)
		lengths[i] = 0;

	for (int i = 0; i < 1000000; ++i) {
		struct dma_program_node *program;
		program = random_dma_program_structure(i);
		lengths[dma_program_length(program)] += 1;
	}

	for (int i = 0; i < 26; ++i) {
		printf("%d\n", lengths[i]);
	}

	return 0;

	dma_instruction *program;
	struct dma_program_node *structure;
PRINT_PROGRAMS:
	for (int i = 0; i < 10; ++i) {
		structure = random_dma_program_structure(i);
		program = random_fill_structure(structure);
		print_dma_program(structure);
		printf("\n");
		for (int j = 0; ; ++j) {
			/*print_dma_instruction(program[j]);*/
			printf("\n");
			if (program[j] == DMA_OP_STOP) {
				break;
			}
		}
		free_dma_structure(structure);
		free(program);
		printf("\n");
	}
	return 0;

	struct transfer_record *res, *last;

	dma_instruction one_transfer[] = {
		DMA_OP_TRANSFER(TS_BITS_32),
		DMA_OP_STOP
	};

	res = list_transfers(one_transfer);
	assert(res->source == 0);
	assert(res->destination == 0);
	assert(res->size == TS_BITS_32);
	assert(res->next == NULL);
	free(res);

	dma_instruction two_transfers[] = {
		DMA_OP_TRANSFER(TS_BITS_8),
		DMA_OP_TRANSFER(TS_BITS_256),
		DMA_OP_STOP
	};

	res = list_transfers(two_transfers);
	assert(res->source == 0);
	assert(res->destination == 0);
	assert(res->size == TS_BITS_8);

	last = res;
	res = res->next;
	free(last);

	assert(res->source == 1);
	assert(res->destination == 1);
	assert(res->size == TS_BITS_256);
	assert(res->next == NULL);

	free(res);

}
