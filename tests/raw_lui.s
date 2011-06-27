.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test lui (load upper immediate)
#

start:
		dli	$a0, 0xffffffffffffffff
		dli	$a1, 0
		dli	$a2, 0

		lui	$a0, 0x0000
		lui	$a1, 0x7fff
		lui	$a2, 0xffff

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
		break
end:
		b end
