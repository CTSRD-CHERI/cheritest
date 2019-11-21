	/* Set the .text address */
	. = __text_start__;
	/* Fake section to force the LMA for all following sections */
	.setLMA . : AT(__text_start_phys__) {}
