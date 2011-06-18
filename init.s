.set mips64
.set noreorder
.set nobopt
.set noat

#
# Generic init.s used by low-level CHERI regression tests.  Set up a stack
# using memory set aside by the linker, and allocate an initial 32-byte stack
# frame (the minimum in the MIPS ABI).
#

start:
		# Set up stack and stack frame
		dla	$sp, __sp
		daddu 	$sp, $sp, -32

		# Invoke test function test() provided by individual tests.
		jal test
		nop			# branch-delay slot

		# Dump registers on the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
