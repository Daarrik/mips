# approximates pi by sum
main:
	# number of iterations
	li	$a0, 5000
	jal	pi

	cvt.s.d	$f12, $f0
	li	$v0, 2
	syscall
	li	$v0, 10
	syscall
pi:
	move	$t0, $a0
	li.d	$f4, 4.0
	li.d	$f6, 1.0
	li.d	$f8, 2.0
piLoop:
	ble	$t0, $zero, piEnd
	div.d	$f10, $f4, $f6
	add.d	$f0, $f0, $f10
	neg.d	$f4, $f4
	add.d	$f6, $f6, $f8
	sub	$t0, $t0, 1
	b	piLoop
piEnd:
	jr	$ra