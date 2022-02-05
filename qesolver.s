#	Description:
#		Solves a quadratic equation from user input
#

		.data
title:		.asciiz	"Quadratic Equation Solver by D. Houck\n\n"
prompt:		.asciiz	"Enter values for a b c?\n"
notQuad:	.asciiz "Not a quadratic equation."
noSol:		.asciiz "Roots are imaginary."
oneSol:		.asciiz "x = "
x1:		.asciiz "x1 = "
x2:		.asciiz "x2 = "

		.text
main:
		addiu	$sp, $sp, -4		# Create space on stack
		sw	$ra, 0($sp)		# Save startup code $ra to stack

		la	$a0, title
		li	$v0, 4
		syscall				# Print "Quadratic Equation Solver by D. Houck\n\n"

		la	$a0, prompt
		li	$v0, 4
		syscall				# Print "Enter values for a b c?\n"

		li	$v0, 6
		syscall				# Get a value
		mov.s	$f12, $f0		# Move a value to $f12

		li	$v0, 6
		syscall				# Get b value
		mov.s	$f13, $f0		# Move b value to $f13

		li	$v0, 6
		syscall				# Get c value
		mov.s	$f14, $f0		# Move c value to $f14

		jal	solveqe			# Call solveqe with paramters $f12 (a), $f13 (b), and $f14 (c)
		
		beq	$v0, -1, noSolution	# Go to noSolution if $v0 == -1
		beq	$v0, 0, notQuadratic	# Go to notQuadratic if $v0 == 0
		beq	$v0, 1, oneSolution	# Go to oneSolution if $v0 == 1
		b	twoSolutions		# Go to twoSolutions if none of the previous are true ($v0 == 2)

noSolution:
		la	$a0, noSol
		li	$v0, 4
		syscall				# Print "Roots are imaginary."

		b	endMain			# Go to endMain

notQuadratic:
		la	$a0, notQuad
		li	$v0, 4
		syscall				# Print "Not a quadratic equation."

		b	endMain			# Go to endMain

oneSolution:
		la	$a0, oneSol
		li	$v0, 4
		syscall				# Print "x = "

		mov.s	$f12, $f0		# Move calculated root to $f12
		li	$v0, 2
		syscall				# Print calculated root

		b	endMain			# Go to endMain

twoSolutions:
		la	$a0, x1
		li	$v0, 4
		syscall				# Print "x1 = "

		mov.s	$f12, $f0		# Move first calculated root to $f12
		li	$v0, 2
		syscall				# Print first calculated root

		li	$a0, '\n'
		li	$v0, 11
		syscall				# Print a new line

		la	$a0, x2
		li	$v0, 4
		syscall				# Print "x2 = "

		mov.s	$f12, $f1		# Move second calculated root to $f12
		li	$v0, 2
		syscall				# Print second calculated root

		b	endMain			# Go to endMain

endMain:
		lw	$ra, 0($sp)		# Restore startup code $ra
		addiu	$sp, $sp, 4		# Restore stack pointer

		jr	$ra			# Return to startup code

#
# solveqe($f12, $f13, $f14)
#	solves quadratic equation with the values given
# parameters:
#	$f12: a value
#	$f13: b value
#	$f14: c value
# returns:
#	v0: -1 (imaginary)
#	v0: 0 (not quadratic)
#	v0: 1 (one solution); f0: solution
#	v0: 2 (two solutions); f0: solution; f1: solution
solveqe:
		li.s	$f4, 0.0		# Load $f4 with 0.0

		c.eq.s	$f12, $f4		# Check if a ($f12) == 0.0
		bc1f	getDiscriminant		# Go to getDiscriminant if a =/= 0.0
						# Otherwise:
		c.eq.s	$f13, $f4		# Check if b ($f13) == 0
		bc1f	linearEq		# Go to linearEq if b =/= 0.0
						# Otherwise:
		li	$v0, 0			# Not quadratic, $v0 = 0

		b	endSolveqe		# Go to endSolveqe

linearEq:
		neg.s	$f14, $f14		# Negate c, $f14 = -c
		div.s	$f0, $f14, $f13		# Return $f0 = -c / b

		li	$v0, 1			# One solution, $v0 = 1

		b	endSolveqe		# Go to endSolveqe

getDiscriminant:
		mul.s	$f4, $f13, $f13		# $f4 = b^2

		li.s	$f5, 4.0		# $f5 = 4.0
		mul.s	$f5, $f5, $f12		# $f5 = 4.0 * a
		mul.s	$f5, $f5, $f14		# $f5 = 4.0 * a * c

		sub.s	$f4, $f4, $f5		# $f4 = b^2 - 4.0 * a * c (discriminant)

		li.s	$f5, 0.0		# Load $f5 with 0.0
		
		c.lt.s	$f4, $f5		# Check if discriminant < 0.0
		bc1f	solveQuadratic		# Go to solveQuadratic if discriminant > 0.0
						# Otherwise:
		li	$v0, -1			# No solutions, $v0 = -1

		b	endSolveqe		# Go to endSolveqe

solveQuadratic:
		li.s	$f5, 2.0		# $f5 = 2.0
		mul.s	$f5, $f5, $f12		# $f5 = 2.0 * a

		neg.s	$f6, $f13		# Negate b, $f6 = -b

		sqrt.s	$f7, $f4		# $f7 = sqrt(b^2 - 4 * a * c), square root of discriminant

		add.s	$f0, $f6, $f7		# $f0 = -b + sqrt(b^2 - 4 * a * c), numerator only (add the terms)
		div.s	$f0, $f0, $f5		# Return $f0 = (-b + sqrt(b^2 - 4 * a * c))/(2 * a), numerator divided by 2 * a ($f5)

		sub.s	$f1, $f6, $f7		# $f1 = -b - sqrt(b^2 - 4 * a * c), numerator only (subtract the terms)
		div.s	$f1, $f1, $f5		# Return $f1 = (-b + sqrt(b^2 - 4 * a * c))/(2 * a), numerator divided by 2 * a ($f5)

		li	$v0, 2			# Two solutions, $v0 = 2

endSolveqe:
		jr	$ra			# Return to main
	