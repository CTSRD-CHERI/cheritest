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
		dla	$a0, exception_end
		jal 	bev0_handler_install
		nop

		dla	$a0, exception_end
		jal	bev1_handler_install
		nop

		#
		# Explicitly clear most registers in order to make the effects
		# of a test on the register file more clear.  Otherwise,
		# values leaked from init.s and its dependencies may hang
		# around.
		#
		dli	$at, 0
		dli	$v0, 0
		dli	$v1, 0
		dli	$a0, 0
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0
		dli	$t0, 0
		dli	$t1, 0
		dli	$t2, 0
		dli	$t3, 0
		dli	$s0, 0
		dli	$s1, 0
		dli	$s2, 0
		dli	$s3, 0
		dli	$s4, 0
		dli	$s5, 0
		dli	$s6, 0
		dli	$s7, 0
		dli	$t8, 0
		dli	$t9, 0
		dli	$k0, 0
		dli	$k1, 0
		dli	$gp, 0
		# Not cleared: $sp, $fp, $ra
		mthi	$at
		mtlo	$at

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
