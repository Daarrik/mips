#
#	Name: Houck, Darrik
#	Project: 3
#	Due: November 25, 2020
#	Course: cs-2640-01-f20
#
#	Description:
#		Prints out an adjacency matrix for a digraph.
#

		.data
title:		.asciiz "Digraph by D. Houck\n\n"
vert:		.asciiz "Enter number of vertices? "
edge:		.asciiz "Enter edge? "
edgeInbuf:	.space 2
vertError:	.asciiz "Number of vertices must be less than or equal to 26.\n"
edgeError:	.asciiz "Invalid edge.\n"

		.text
main:
		move	$s2, $ra		# Save $ra into $s2 (because stack is altered by matrix)

		la	$a0, title		# Load title into $a0
		li	$v0, 4			# Print title
		syscall

promptVertLoop:
		li	$t0, 26
		la	$a0, vert		# Load vert into $a0
		li	$v0, 4			# Print vertices prompt
		syscall

		li	$v0, 5			# Prompt user for number of vertices
		syscall

		ble	$v0, $t0, promptVertEnd		# If entered vertices is greater than 26, reprompt user
promptVertError:
		la	$a0, vertError
		li	$v0, 4
		syscall

		b	promptVertLoop
promptVertEnd:
		move	$s1, $v0		# Save number of entered vertices (n) into $s1
		move	$a0, $s1		# Move n to $a0
		mul	$a0, $a0, $a0		# Square n for total number of matrix entries
		sll	$a0, $a0, 2		# Multiply number of matrix entries by 4

		sub	$sp, $sp, $a0		# Subtract $a0 from $sp
		move	$s0, $sp		# Save stack pointer (beginning of matrix) to $s1

		move	$a0, $s0		# Load mat as paramater $a0
		move	$a1, $s1		# Load $s0 as parameter $a1
		jal	matrix			# Create a matrix of appropriate size

promptEdgeLoop:
		la	$a0, edge		# Load edge into $a0
		li	$v0, 4			# Print edge prompt
		syscall

		li	$t2, 65			# Load $t2 with ascii for 'A'
		la	$a0, edgeInbuf		# Load $a0 with destination for inputted edge
		li	$a1, 4			# Load $a1 with space allowed for an edge
		li	$v0, 8			# Prompt user for an edge
		syscall

		lb	$t0, ($a0)		# Get the first character from the inputted edge
		addiu	$a0, $a0, 1		# Increment counter
		lb	$t1, ($a0)		# Get the second character from the inputted edge

		beq	$t0, '\n', promptEdgeError	# If the first character is '\n', tell the user to reinput the edge

		bne	$t0, 'X', noX			# If first character is not X, jump to noX
		beq	$t1, '\n', promptEdgeEnd	# If the first character was X and the second character is '\n', stop prompting for edges

		b	validX

noX:
		beq	$t1, '\n', promptEdgeError	# If the first character was not an X, but the second character is '\n', tell the user to reinput the edge
validX:
		sub	$t3, $t0, 65
		bge	$t3, $s1, promptEdgeError	# Check if the first character is out of the bounds of the vertices

		sub	$t3, $t1, 65
		bge	$t3, $s1, promptEdgeError	# Check if the second character is out of the bounds of the vertices

		sub	$t0, $t0, $t2		# Subtract 65 both characters to get the row and column to be changed
		sub	$t1, $t1, $t2

		move	$a0, $s0		# Move address of matrix to parameter for addedge
		move	$a1, $s1		# Move n to parameter for addedge
		move	$a2, $t0		# Move row to parameter for addedge
		move	$a3, $t1		# Move column to parameter for addedge		

		jal	addedge			# Add the inputted edge

		b	promptEdgeLoop
promptEdgeError:
		la	$a0, edgeError
		li	$v0, 4
		syscall

		b	promptEdgeLoop
promptEdgeEnd:
		move	$a0, $s0		# Move address of matrix to parameter for print
		move	$a1, $s1		# Move n to parameter for print
		jal	print			# Print out contents of the matrix

		addu	$sp, $sp, $s0		# Jump out of matrix
		move	$ra, $s2		# Restore startup code $ra from $s2

		jr	$ra

#
# matrix(a0, a1)
#	creates a matrix of zeros
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
matrixWhile:
		sw	$zero, ($s0)		# Put $zero in current matrix pointer
		addiu	$s0, $s0, 4		# Increment matrix pointer
		addi	$s1, $s1, -1		# Decrement matrix size
		beqz	$s1, matrixEnd		# If matrix size equals zero, jump to matrixZeroEnd
						# Otherwise:
		b	matrixWhile		# Loop back to matrixZeroWhile
matrixEnd:
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
		li	$t1, 65			# Load $t1 with ascii for 'A'
		li	$t4, 65			# Load $t4 with ascii for 'A'
		add	$t2, $t1, $t0		# Upper bound for characters to print
		mul	$s1, $s1, $s1		# Square $s1 to get total number of items in matrix

		li	$a0, '*'		# Load $a0 with '*'
		li	$v0, 11			# Print '*'
		syscall

		li	$a0, ' '		# Load $a0 with ' '
		li	$v0, 11			# Print ' '
		syscall
printTopRow:
		move	$a0, $t1		# Move $t1 to $a0
		li	$v0, 11			# Print current character ($t1)
		syscall

		li	$a0, ' '		# Load $a0 with ' '
		li	$v0, 11			# Print ' '
		syscall

		addi	$t1, 1			# Increment character to be printed
		beq	$t1, $t2, printNewLine	# If the character to be printed is equal to the upper bound, jump to printNewLine
						# Otherwise:
		b	printTopRow		# Loop back to printTopRow
printMatrix:
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
		mfhi	$t3
		beqz	$t3, printNewLine	# If remainder of matrix size divided by n equals zero, jump to printNewLine
						# Otherwise:
		b	printMatrix		# Loop back to printWhile
printNewLine:
		li	$a0, '\n'		# Load '\n' into $a0
		li	$v0, 11			# Print '\n'
		syscall

		move	$a0, $t4		# Move $t4 to $a0
		li	$v0, 11			# Print current character ($t4)
		syscall

		li	$a0, ' '		# Load $a0 with ' '
		li	$v0, 11			# Print ' '
		syscall

		addi	$t4, 1			# Increment character to be printed

		b	printMatrix		# Loop back to printWhile
printEnd:
		lw	$s1, 4($sp)		# Restore $s1 by convention
		lw	$s0, 0($sp)		# Restore $s0 by convention
		addiu	$sp, $sp, 8		# Restore stack pointer

		jr	$ra

#
# addedge(a0, a1, a2, a3)
#	prints out the contents of the matrix
# parameters:
#	$a0: address of matrix
#	$a1: n (nxn matrix)
#	$a2: row
#	$a3: column
# returns:
#	void
addedge:
		addiu	$sp, $sp, -4		# Create space on stack
		sw	$ra, 0($sp)		# Save $ra onto stack

		jal	getae			# Get the effective address (uses same parameters as addedge, so no saving is needed here)
		
		li	$t0, 1			# Load $t0 with 1
		sw	$t0, ($v0)		# Replace the value at the effective address with $t0 (1)

		lw	$ra, 0($sp)		# Restore $ra
		addiu	$sp, $sp, 4		# Restore stack pointer

		jr	$ra

#
# print(a0, a1)
#	prints out the contents of the matrix
# parameters:
#	$a0: address of matrix
#	$a1: n (nxn matrix)
#	$a2: row
#	$a3: column
# returns:
#	effective address of the matrix
getae:
		addiu	$sp, $sp, -20		# Create space on stack
		sw	$s0, 0($sp)		# Save $s0 by convention
		sw	$s1, 4($sp)		# Save $s1 by convention
		sw	$s2, 8($sp)		# Save $s2 by convention
		sw	$s3, 12($sp)		# Save $s3 by convention
		sw	$s4, 16($sp)		# Save $s4 by convention

		move	$s0, $a0
		move	$s1, $a1
		move	$s2, $a2
		move	$s3, $a3

		mul	$s4, $s2, $s1
		add	$s4, $s4, $s3		# Operations for computing effective address
		sll	$s4, $s4, 2

		add	$v0, $s0, $s4		# Put effective address in return register $v0

		lw	$s4, 16($sp)		# Restore $s4 by convention
		lw	$s3, 12($sp)		# Restore $s3 by convention
		lw	$s2, 8($sp)		# Restore $s2 by convention
		lw	$s1, 4($sp)		# Restore $s1 by convention
		lw	$s0, 0($sp)		# Restore $s0 by convention
		addiu	$sp, $sp, 20		# Restore stack pointer

		jr	$ra