.set mips64
.set noreorder
.set nobopt
.set noat

#
# This regression test simply dumps registers to the simulator console.  It
# uses its own init routine to avoid setting up a stack frame, so that the
# test framework can also test the initial value of $sp.
#

start:
		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
