#
# Main section...
#

.org $0x0

start:
	movi $udiv, %r5	# Div function in R5...
	movi $0x0, %r7	# Stack on 0 growing upwards...
	movi $0xFFFE, %r4	# R4=UART base dir...

	movi $7, %r3	# Initialize counter...
loop:
	add %r0, %r3, %r1
	movi $2, %r2		# Divider...
	jalr %r5, %r6		# R1 = R1/R2
	sw   %r4, $0, %r1	# Send result...
	beq %r0, %r0, $loop	# Else loop
	

hlt:
	beq %r0, %r0, $hlt


#
# Functions section
#

# Unsigned division:
udiv:
	# return r1 = r1 / r2
	# Backup r3 and r4 to stack
	sw %r7, $0, %r3
	sw %r7, $1, %r4
	# Init r3 to 0
	add %r0, %r0, %r3
udiv_cmp:
	# If (x < y) => return
	# Else keep calculating...
	sltu %r1, %r2, %r4
	beq %r0, %r4, $udiv_calc
	# Return
	add %r0, %r3, %r1
	lw %r7, $1, %r4
	lw %r7, $0, %r3
	jalr %r6, %r0
	# Keep calculating...
udiv_calc:
	sub %r1, %r2, %r1
	addi %r3, $1, %r3
	beq %r0, %r0, $udiv_cmp
