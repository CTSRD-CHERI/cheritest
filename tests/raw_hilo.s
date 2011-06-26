.set mips64
.set noreorder
.set nobopt
.set noat

#
# Check that initial values of 'HI' and 'LO' can be loaded and are zeroed.
# Other tests for HI and LO are in test_hilo.
#

start:
		# Test here
		mfhi	$a0
		mflo	$a1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
