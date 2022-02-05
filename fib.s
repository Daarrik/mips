# Calculates nth number of fibonacci sequence
main:
	li	$a0, 4
	jal fib
	move	$a0, $v0
	li	$v0, 1
	syscall
	li	$v0, 10
	syscall
fib:
	addiu	$sp, $sp, -8
	sw	$a0, 0($sp)
	sw	$ra, 4($sp)

	bne	$a0, $0, elseif

	li	$v0, 0
	lw	$ra, 4($sp)
	lw	$a0, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
elseif:
	li	$t0, 1
	bne	$a0, $t0, else

	li	$v0, 1
	lw	$ra, 4($sp)
	lw	$a0, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
else:
	sub	$a0, $a0, 1
	jal	fib

	lw	$a0, 0($sp)
	sw	$v0, 0($sp)

	sub	$a0, $a0, 2
	jal	fib
	
	lw	$t0, 0($sp)
	add	$v0, $v0, $t0

	lw	$ra, 4($sp)
	lw	$a0, 0($sp)
	addiu	$sp, $sp, 8

	jr	$ra