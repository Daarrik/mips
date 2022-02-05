#	Description:
#		Allows the user to input strings and then the program will print them out with a linked list.
#

		.data
llist:		.word	0
inbuf:		.space	82
intro:		.asciiz	"Link List\n\n"
prompt:		.asciiz	"Enter text? "

		.text
main:

		addiu	$sp, $sp, -4		# Create space on stack
		sw	$ra, 0($sp)		# Save startup code $ra onto stack
		
		la	$a0, intro		# Print intro
		li	$v0, 4
		syscall
promptText:
		la	$a0, prompt		# Print prompt
		li	$v0, 4
		syscall

		la	$a0, inbuf		# Prompt user for text
		li	$a1, 80
		li	$v0, 8
		syscall

		lb	$t0, ($a0)		# Get the first character of the inputted string
		beq	$t0, '\n', promptEnd	# Stop prompting user for strings if the string is only \n
						# Otherwise:
		jal	strdup			# Call strdup to duplicate inputted string

		move	$a0, $v0		# Move duplicated string to data parameter of addnode
		lw	$a1, llist		# Load current head of the linked list to the next parameter of addnode
		jal	addnode			# Add node with the parameters above
		sw	$v0, llist		# Update the head of the linked list

		b	promptText		# Prompt user for another line of text
promptEnd:
		lw	$a0, llist		# Load head of linked list to $a0 as a paramater for traverse
		la	$a1, print		# Load address of print to $a1 to cal with jalr in traverse
		jal	traverse		# Traverse through the linked list
		
		lw	$ra, 0($sp)		# Restore startup code $ra
		addiu	$sp, $sp, 4		# Restore stack pointer
		
		jr	$ra			# Return to startup code to terminate

#
# print($a0)
#	prints out string
# paramaters:
#	$a0: address of string
# returns:
#	void
#
print:
		li	$v0, 4
		syscall

		jr	$ra

#
# traverse($a0, $a1)
#	loops through a linked list, prints out contents when it reaches the end of the list
# paramaters:
#	$a0: address of linked list
#	$a1: address of print function
# returns:
#	void
#
traverse:
		addiu	$sp, $sp, -12		# Create space on stack (Creates space on the stack for every next node on recursive calls)
		sw	$ra, 0($sp)		# Save $ra onto stack
		sw	$a0, 4($sp)		# Save node onto stack
		sw	$a1, 8($sp)		# Save address of print function onto stack

		lw	$a0, 4($a0)		# This loads the next node of the data saved onto stack

		beqz	$a0, printLoop		# If the next node is 0, jump to printLoop
						# Otherwise:
		jal	traverse		# Call traversal again until the next node is 0
						# Recursive calls to traverse will save the $ra to return here, allowing for printLoop to loop until the original $ra is reached
printLoop:
		lw	$a0, 4($sp)		# Load node into $a0
		lw	$a0, 0($a0)		# Load data of node into $a0
		lw	$a1, 8($sp)		# Load address of print fuction into $a1
		jalr	$a1			# Call print using jalr $a1

		lw	$ra, 0($sp)		# Restore $ra
		addiu	$sp, $sp, 12		# Restore stack pointer

		jr	$ra

#
# addnode($a0, $a1)
#	adds a new node to the head of the linked list
# paramaters:
#	$a0: address of data to be added to list
#	$a1: address of head of linked list
# returns:
#	$v0: address of head of new linked list
#
addnode:
		addiu	$sp, $sp, -8		# Create space on stack
		sw	$s0, 0($sp)		# Save $s0 register onto stack by convention
		sw	$s1, 4($sp)		# Save $s1 register onto stack by convention

		move	$s0, $a0		# Move data $a0 into $s0
		move	$s1, $a1		# Move llist head (which will become the next node) into $s1

		li	$a0, 8			# Create space 8 on the heap, 4 for data, 4 for next
		li	$v0, 9
		syscall

		sw	$s0, ($v0)		# Save data onto heap
		sw	$s1, 4($v0)		# Save next node onto heap

		lw	$s1, 4($sp)		# Restore $s1 register by convention
		lw	$s0, 0($sp)		# Restore $s0 registers by convention
		addiu	$sp, $sp, 8		# Restore stack pointer

		jr	$ra

#
# strlen($a0)
#	compute the length of a c-string
# paramaters:
#	$a0: address of string
# returns:
#	$v0: length of string
#
strlen:
		addiu	$sp, $sp, -12		# Create space on stack
		sw	$s0, 0($sp)		# Save $s0 register onto stack by convention
		sw	$s1, 4($sp)		# Save $s1 register onto stack by convention
		sw	$s2, 8($sp)		# Save $s2 register onto stack by convention

		li	$s0, 0			# Length
		la	$s1, ($a0)		# Load address of $a0 into $s1
strlenWhile:
		lb	$s2, ($s1)		# Load byte of $s1 into $t2
		beqz	$s2, endStrlenWhile	# If address of $s1 ($a0) equals 0, jump to endStlrenWhile
		addi	$s0, $s0, 1		# Increment length
		addi	$s1, $s1, 1		# Increment pointer
		b	strlenWhile		# Loop strlenWhile
endStrlenWhile:
		move	$v0, $s0		# Move length $s0 into return register $v0

		lw	$s2, 8($sp)		# Restore $s2 register by convention
		lw	$s1, 4($sp)		# Restore $s1 register by convention
		lw	$s0, 0($sp)		# Restore $s0 register by convention
		addiu	$sp, $sp, 12		# Restore stack pointer

		jr	$ra

#
# strdup($a0)
#	duplicate a c-string
# paramaters:
#	$a0: address of string
# returns:
#	$v0: address of duplicated string
#
strdup:
		addiu	$sp, $sp, -20		# Create space on stack
		sw	$ra, 0($sp)		# Save $ra onto stack
		sw	$a0, 4($sp)		# Save inputted string onto stack
		sw	$s0, 8($sp)		# Save $s0 register onto stack by convention
		sw	$s1, 12($sp)		# Save $s1 register onto stack by convention
		sw	$s2, 16($sp)		# Save $s2 register onto stack by convention

		jal	strlen			# We already saved the length of the string onto the stack, but we will be calling strlen again anyways
		
		move	$a0, $v0		# Move result of strlen to $a0 to use as a parameter in malloc
		addi	$a0, $a0, 1		# Add one more space for null character
		jal	malloc			# Run malloc to determine how much space to allocate for the duplicated string
		
		lw	$a0, 4($sp)		# Restore inputted string for use in strdupWhile

		move	$s2, $v0		# Move result of malloc to $s2 for duplication
		move	$s0, $a0		# Move string to $s0
strdupWhile:
		lb	$s1, 0($s0)		# Load character into $s1
		sb	$s1, 0($s2)		# Save character of $s1 into $s2, duplicates string

		addi	$s0, $s0, 1		# Increment character (byte) of the string $s0
		addi	$s2, $s2, 1		# Increment duplicated string pointer
		
		bnez	$s1, strdupWhile	# Loop if the character is not the null character

		lw	$s2, 16($sp)		# Restore $s2 register by convention
		lw	$s1, 12($sp)		# Restore $s1 register by convention
		lw	$s0, 8($sp)		# Restore $s0 register by convention
		lw	$a0, 4($sp)		# Restore inputted string
		lw	$ra, 0($sp)		# Restore $ra
		addiu	$sp, $sp, 20		# Restore stack pointer

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
		sra	$a0, $a0, 2
		sll	$a0, $a0, 2
		li	$v0, 9
		syscall

		jr	$ra

