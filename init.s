.set mips64
.set noreorder
.set nobopt
.set noat

#
# Generic init.s used by low-level CHERI regression tests.  Set up a stack
# using memory set aside by the linker, and allocate an initial 32-byte stack
# frame (the minimum in the MIPS ABI).  Install some default exception
# handlers so we can try and provide a register dump even if things go
# horribly wrong during the test.
#

start:
		# Set up stack and stack frame
		dla	$fp, __sp
		dla	$sp, __sp
		daddu 	$sp, $sp, -32

		# Install default exception handlers
		dli	$a0, 0xffffffff80000180
		dla	$a1, exception_end
		jal 	handler_install
		nop

		dli	$a0, 0xffffffffbfc00380
		dla	$a1, exception_end
		jal	handler_install
		nop

		# Invoke test function test() provided by individual tests.
		jal test
		nop			# branch-delay slot

		# Dump registers on the simulator
exception_end:
		mtc0 $at, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
