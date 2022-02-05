#	Description:
#			Greedy coin change computation.
#

	.data
title: .asciiz "Change"
change: .asciiz "Enter the change? "
q: .asciiz "Quarter: "
d: .asciiz "Dime: "
n: .asciiz "Nickel: "
p: .asciiz "Penny: "
newLine: .asciiz "\n"

	.text
main:	la	$a0, title 		# Print title
	li	$v0, 4
	syscall

	la	$a0, newLine
	li	$v0, 4
	syscall				# Print blank lines for format
	la	$a0, newLine
	li	$v0, 4
	syscall

	la	$a0, change		# Print prompt
	li	$v0, 4
	syscall

	li	$v0, 5			# Get change
	syscall
	move	$t0, $v0		# Move inputted change value to t0

	li	$t1, 25			# Load t1 with value of current coin (quarter)
	
	slt	$t2, $t0, $t1		# Check if inputted change value < t1; 0 if false, 1 if true
	
	bne	$t2, $zero, dime	# If t2 = 0, execute the code below bne, if t2 = 1, jump to dime
	div	$t0, $t1		# Divide inputted change value by value of current coin (quarter)
	mfhi	$t0			# Move remainder to change value
	mflo	$t3			# Move integer division result to t3

	la	$a0, q			# Print quarter
	li	$v0, 4
	syscall

	move	$a0, $t3		# Print integer division
	li	$v0, 1
	syscall
	
	la	$a0, newLine		# Print new line
	li	$v0, 4
	syscall

dime:
	li	$t1, 10			# Load t1 with value of current coin (dime)

	slt	$t2, $t0, $t1

	bne	$t2, $zero, nickel
	div	$t0, $t1
	mfhi	$t0
	mflo	$t3

	la	$a0, d			# Print dime
	li	$v0, 4
	syscall

	move	$a0, $t3		# Print integer division
	li	$v0, 1
	syscall

	la	$a0, newLine		# Print new line
	li	$v0, 4
	syscall
	
nickel:
	li	$t1, 5			# Load t1 with value of current coin (nickel)

	slt	$t2, $t0, $t1

	bne	$t2, $zero, penny
	div	$t0, $t1
	mfhi	$t0
	mflo	$t3

	la	$a0, n			# Print nickel
	li	$v0, 4
	syscall

	move	$a0, $t3		# Print integer division
	li	$v0, 1
	syscall

	la	$a0, newLine		# Print new line
	li	$v0, 4
	syscall

penny:
	li	$t1, 1			# Load t1 with value of current coin (penny)

	slt	$t2, $t0, $t1

	bne	$t2, $zero, end
	div	$t0, $t1
	mfhi	$t0
	mflo	$t3

	la	$a0, p			# Print penny
	li	$v0, 4
	syscall

	move	$a0, $t3		# Print integer division
	li	$v0, 1
	syscall

	la	$a0, newLine		# Print new line
	li	$v0, 4
	syscall
	
end:
	li	$v0, 10
	syscall