	/* Set the .text address */
	. = __base__;
	/* Fake section to force the LMA for all following sections */
	.setLMA __text_start__ : AT(__text_start_phys__) {}
