#	Description:
#		     	Outputs the leap years between 1970 and 2030.
#

		.data
title: 		.asciiz "Leap Years"
newLine: 	.asciiz "\n"
from: 		.asciiz "From "
to:		.asciiz " to "
colon:		.asciiz ":"

		.text
main:	
	la	$a0, title		# Print title
	li	$v0, 4
	syscall
	la	$a0, newLine
	li	$v0, 4
	syscall

	la	$a0, from		# Print "From "
	li	$v0, 4
	syscall
	la	$a0, 1970		# Print "1970"
	li	$v0, 1			
	syscall
	la	$a0, to			# Print " to "
	li	$v0, 4
	syscall
	la	$a0, 2030		# Print "2030"
	li	$v0, 1			
	syscall
	la	$a0, colon		# Print ":"
	li	$v0, 4
	syscall
	la	$a0, newLine
	li	$v0, 4
	syscall

	li	$a0, 1970		# $a0 = 1970
	li	$a1, 2030		# $a1 = 2030
	li	$s0, 400		# $s0 = 400
	li	$s1, 100		# $s1 = 100
	li	$s2, 4			# $s2 = 4

for:
	move	$t0, $a0		# Move current year to $t0
	slt	$t3, $a1, $t0		# Check if max year is less than current year
	beq	$t3, 1, end		# If max year is less than current year, jump to end

	div	$t0, $s0		# Divide current year by 400
	mfhi	$t1			# Move remainder of current year divided by 400 to $t1
	beq 	$t1, 0, output		# If divisible by 400, print and increment year

	div	$t0, $s1		# If not divisible by 400, divide current year by 100
	mfhi	$t1			# Move remainder of current year divided by 100 to $t1
	beq	$t1, 0, incrementYear	# If divisible by 100, don't print but increment year

	div	$t0, $s2		# If not divisible by 100, divide current year by 4
	mfhi	$t1			# Move remainder of current year divided by 4 to $t1
	beq	$t1, 0, output		# If divisble by 4, print and increment year

	j	incrementYear		# Jump to incrementYear
	

output:
	move	$a0, $t0		# Print out the current year
	li	$v0, 1
	syscall
	la	$a0, newLine		# Briefly change value of $a0 from current year to newLine (switches back in incrementYear)
	li	$v0, 4
	syscall

	j	incrementYear		# Jump to incrementYear

incrementYear:
	move	$a0, $t0		# Ensure value of $a0 is current year in order to increment the current year	
	addi	$a0, $a0, 1

	j	for			# Jump to for

end:
	li	$v0, 10
	syscall