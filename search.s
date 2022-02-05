#	Description:
#		     	Searches for particular values in an array.
#

		.data
intro:		.asciiz		"Search"
message:	.word		'M', 'I', 'P', 'S', ' ', 'a', 's', 's', 'e', 'm', 'b', 'l', 'y', ' ', 'l', 'a', 'n', 'g', 'u', 'a', 'g', 'e', '!'
		
		.text
main:
		la	$a0, intro		# $a0 = intro
		li	$v0, 4			# Print intro
		syscall
		li	$a0, '\n'		# $a0 = \n
		li	$v0, 11			# Print \n
		syscall
		li	$v0, 11			# Print \n
		syscall

		la	$a1, message		# $a1 = message
		li	$t2, 23			# $t2 = number of bytes in message

printMessage:
		lw	$a0, 0($a1)		# $t0 = Mem($a1)
		beqz	$t2, endPrint
		addi	$t2, $t2, -1
		li	$v0, 11
		syscall
		addi	$a1, $a1, 4
		b	printMessage

endPrint:
		li	$a0, '\n'		# $a0 = \n
		li	$v0, 11			# Print \n
		syscall
		li	$v0, 11			# Print \n
		syscall

		addiu	$sp, $sp, -4
		sw	$ra, ($sp)

		la	$a1, message		# $a1 = message
		li	$t2, 22			# $t2 = increment
		li	$t1, 23			# $t1 = number of bytes in message
		li	$t0, '!'		# $t0 = '!'
		jal	search			# Execute search with $a1 = message and $t0 = '!'

		la	$a1, message		# $a1 = message
		li	$t2, 23			# $t2 = increment
		li	$t1, 23			# $t1 = number of bytes in message
		li	$t0, 'z'		# $t0 = 'z'
		jal	search			# Execute search with $a1 = message and $t0 = 'z'

		lw	$ra, ($sp)
		addiu	$sp, $sp, 4

		jr	$ra

search:
		lw	$a0, 0($a1)		# Load $a0 with the next byte in message
		beq	$a0, $t0, found		# If $a0 is equal to $t0, branch to found
		addi	$t2, $t2, -1		# Decrement loop
		addi	$a1, $a1, 4		# If $a0 is not equal to $t0, increment the next byte
		bgez	$t2, search		# Branch back to search if loop counter ($t2) is greater than or equal to zero
		li	$t1, -1			# If loop counter ($t2) is less than zero, make $t1 -1
		b	showans			# Branch around found and go to showans
found:
		sub	$t1, $t1, $t2		# Subtract the loop counter ($t2) from the total number of bytes ($t1) to get the index of the character
showans:
		move	$a0, $t0		# Move the desired character ($t0) to $a0
		li	$v0, 11			# Print desired character ($t0)
		syscall
		li	$a0, ':'		# $a0 = ':'
		li	$v0, 11			# Print ':'
		syscall
		move	$a0, $t1		# Move the index of the character ($t1) to $a0
		li	$v0, 1			# Print index of the character ($t1)
		syscall
		li	$a0, '\n'		# $a0 = '\n'
		li	$v0, 11			# Print '\n'
		syscall
		jr	$ra			# Return
		