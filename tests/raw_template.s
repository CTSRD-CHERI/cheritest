.set mips64
.set noreorder
.set nobopt
.set noat

start:
		# Test here
		nop

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
