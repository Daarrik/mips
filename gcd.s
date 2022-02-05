# greatest common denominator
main:
	# input
	li	$a0, 78
	li	$a1, 66
	jal	gcd

	move	$a0, $v0
	li	$v0, 1
	syscall

	li	$v0, 10
	syscall
gcd:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)

	move	$t0, $a0
	move	$t1, $a1

	beqz	$t1, end

	move	$a0, $t1
	div	$t0, $t1
	mfhi	$a1

	jal	gcd
end:
	move	$v0, $t0
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4

	jr	$ra