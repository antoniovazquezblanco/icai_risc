# Test program for the ICAI-RISC-16
#
# Executes every instruction in the processor set and tests them.

.org $0x00

start:
	beq %r0, %r0, $start

#	movi $0xFFFE, %r1	# R1=UART base dir...
#	movi $0x7FFE, %r2	# R2=Timer base dir...
#	movi $0x0002, %r3	# R3=UART full mask...
#
#       movi $0x0003, %r4	# Timer start + keep running after ov...
#       sw   %r2, $1, %r4	# Write configuration...

#loop:

#uartwait:
#	lw   %r1, $1, %r4	# R4=UART status...
#	nand %r4, %r3, %r4
#	nand %r4, %r4, %r4	# R4=Is uart full?
#	beq  %r4, %r0, $go	# Not full -> go
#	beq  %r0, %r0, $uartwait	# else -> uartwait
#go:	lw   %r2, $0, %r4	# R4=Timer count...
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4
#	srl  %r4, %r4		# Div by aprox 5000
#	addi %r4, $0x30, %r4	# Num to char...

#	sw   %r1, $0, %r4	# Send character...
#	beq  %r0, %r0, $loop	# Goto loop

#loop:
#	lw   %r1, $1, %r3	# R3=UART config...
#	nand %r3, %r2, %r3
#	nand %r3, %r3, %r3	# R3=UART contains data?
#	beq  %r3, %r0, $loop	# No data -> loop
#	lw   %r1, $0, %r4	# R4=UART data
#	sw   %r1, $0, %r4	# Send echo
#	beq  %r0, %r0, $loop	# Goto loop
