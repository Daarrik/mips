# modulo operator
main:
	# input
	li	$t0, 5
	li	$t1, 2

	sw	$t0, 0($sp)
	sw	$t1, 4($sp)

	jal	mod

	lw	$a0, 8($sp)
	li	$v0, 1
	syscall

	li	$v0, 10
	syscall

mod:
	lw	$t0, 0($sp)
	lw	$t1, 4($sp)

	div	$t0, $t1
	mfhi	$t2
	sw	$t2, 8($sp)

	jr	$ra