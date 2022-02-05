#	Description:
#		Creates a 10x10 identity matrix and then changes the entry in mat[4][4] to 0
#

		.data
title:		.asciiz "Matrix\n\n"
mat:		.word	0

		.text
main:
		addiu	$sp, $sp, -4		# Create space on stack
		sw	$ra, 0($sp)		# Save $ra onto stack

		la	$a0, title		# Load title into $a0
		li	$v0, 4			# Print title
		syscall

		li	$a0, 400		# 10x10 matrix = 100 words, 100 words * 4 = 400 bytes
		jal	malloc			# Create appropriate space on heap
		sw	$v0, mat		# Save allocated space to mat

		lw	$a0, mat		# Load mat as paramater $a0
		li	$a1, 10			# Load 10 as paramter $a1
		jal	matrix			# Create appropriate identity matrix

		lw	$t3, mat
		li	$t0, 4
		li	$t1, 4
		mul	$t2, $t0, 10
		add	$t2, $t2, $t1		# Change mat[4][4] to 0
		sll	$t2, $t2, 2
		add	$t3, $t3, $t2
		sw	$zero, ($t3)

		lw	$a0, mat		# Load mat as paramter $a0
		li	$a1, 10			# Load 10 as parameter $a1
		jal	print			# Print out contents of mat

		lw	$ra, 0($sp)		# Restore $ra
		addiu	$sp, $sp, 4		# Restore stack pointer

		jr	$ra

#
# matrix(a0, a1)
#	creates an identity matrix
# parameters:
#	$a0: address of matrix
#	$a1: n (nxn matrix)
# returns:
#	void
matrix:
		addiu	$sp, $sp, -8		# Create space on stack
		sw	$s0, 0($sp)		# Save $s0 by convention
		sw	$s1, 4($sp)		# Save $s1 by convention

		move	$s0, $a0		# Move address of matrix to $s0
		move	$s1, $a1		# Move n to $s1
		mul	$s1, $s1, $s1		# Square $s1 to get total number of items in matrix

matrixZeroWhile:
		sw	$zero, ($s0)		# Put $zero in current matrix pointer
		addiu	$s0, $s0, 4		# Increment matrix pointer
		addi	$s1, $s1, -1		# Decrement matrix size
		beqz	$s1, matrixZeroEnd	# If matrix size equals zero, jump to matrixZeroEnd
						# Otherwise:
		b	matrixZeroWhile		# Loop back to matrixZeroWhile
matrixZeroEnd:
		move	$s0, $a0		# Move address of matrix to $s0
		move	$s1, $a1		# Move n to $s1

		li	$v0, 1			# Load $v0 with 1
		li	$t0, 0			# $t0 = i
		move	$t1, $a1		# Load $t1 with number of columns
matrixOneWhile:
		mul	$t2, $t0, $t1		# $t2 = row * number of col
		add	$t2, $t2, $t0		# $t2 = $t2 + col
		sll	$t2, $t2, 2		# Convert offset to address pointer

		add	$s0, $s0, $t2		# Add converted offset to address pointer
		sw	$v0, ($s0)		# Save $v0 (1) into matrix

		move	$s0, $a0		# Reset address pointer
		addi	$t0, 1			# i++
		beq	$t0, $s1, matrixOneEnd	# If i is equal to n, jump to matrixOneEnd
						# Otherwise:
		b	matrixOneWhile		# Loop back to matrixOneWhile
matrixOneEnd:
		lw	$s1, 4($sp)		# Restore $s1 by convention
		lw	$s0, 0($sp)		# Restore $s0 by convention
		addiu	$sp, $sp, 8		# Restore stack pointer

		jr	$ra

#
# print(a0, a1)
#	prints out the contents of the matrix
# parameters:
#	$a0: address of matrix
#	$a1: n (nxn matrix)
# returns:
#	void
print:
		addiu	$sp, $sp, -8		# Create space on stack
		sw	$s0, 0($sp)		# Save $s0 by convention
		sw	$s1, 4($sp)		# Save $s1 by convention

		move	$s0, $a0		# Move address of matrix to $s0
		move	$s1, $a1		# Move n to $s1
		move	$t0, $s1		# Copy n to $t0
		mul	$s1, $s1, $s1		# Square $s1 to get total number of items in matrix
printWhile:
		lw	$a0, ($s0)		# Load word into $a0
		li	$v0, 1			# Print loaded word
		syscall

		li	$a0, ' '		# Load ' ' into $a0
		li	$v0, 11			# Print ' '
		syscall

		addiu	$s0, $s0, 4		# Increment matrix pointer
		addi	$s1, $s1, -1		# Decrement matrix size

		beqz	$s1, printEnd		# If matrix size equals zero, jump to printEnd
						# Otherwise:
		div	$s1, $t0		# Divide current matrix size by n
		mfhi	$t1
		beqz	$t1, printNewLine	# If remainder of matrix size divided by n equals zero, jump to printNewLine
						# Otherwise:
		b	printWhile		# Loop back to printWhile
printNewLine:
		li	$a0, '\n'		# Load '\n' into $a0
		li	$v0, 11			# Print '\n'
		syscall

		b	printWhile		# Loop back to printWhile
printEnd:
		lw	$s1, 4($sp)		# Restore $s1 by convention
		lw	$s0, 0($sp)		# Restore $s0 by convention
		addiu	$sp, $sp, 8		# Restore stack pointer

		jr	$ra
		


#
# malloc($a0)
#	allocates the appropriate space for a string of length n to the next multiple of 4
# paramaters:
#	$a0: length of string
# returns:
#	$v0: address of data on heap
#
malloc:
		addi	$a0, $a0, 3
		andi	$a0, $a0, 0xfffc
		li	$v0, 9
		syscall

		jr	$ra

