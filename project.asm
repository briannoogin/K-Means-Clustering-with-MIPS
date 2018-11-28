# K-means clustering visualization for binary classifcation data
# by Brian Nguyen
# 	Program uses Bitmap display to display the scatter plot
#	Bitmap Display Settings:                                     #
#	Unit Width: 8						     #
#	Unit Height: 8						     #
#	Display Width: 512					     #
#	Display Height: 512					     #
#	Base Address for Display: 0x10008000 ($gp)	
# TODO:
# Enter in the data in a two-column table, try to read in from file
# Draw the lines of the graph
# finish k-means algorithmn 
# Do 10 iterations of k-means
.data
# screen size dimensions
screenHeight: .word 64
screenWidth: .word 64
# color of classes
blue: 	.word	0x0066cc # color of 1 class
red: .word  0xFF0000 # color of 0 class
backgroundColor:.word	0xFFFFFF # white 
# data file
dataFile: .asciiz "data.txt"
# 100X2 table
xDimension: .space 100
yDimension: .space 100
fileBuffer: .space 400
.text
	main:
	### Read in text data ###
	# open file
	li $v0, 13 
	la $a0, dataFile
	li $a1, 0
	li $a2,0
	syscall
	move $t1, $v0 # save the file description
	
	# read file
	li $v0, 14 
	addi $a0, $t1, 0
	la $a1, fileBuffer
	li $a2, 400
	syscall
	
	# close file
	li $v0,16 
	syscall
	
	# output character
	la $t1, fileBuffer # store address of the file buffer
	la $t2, xDimension # store address of 1st column of table
	la $t3, yDimension # store address of 2nd column of table
	li $s1, 400
	li $s2, 0 # store character count to stop the loop
	loopThroughBuffer:
	addi $t4, $t1, 2 # store address of 2nd number
	sb $t1, ($t2) # store number in x column
	sb $t4, ($t3) # store number in y column
	addi $t2, $t2, 1 # increment column index by 1
	addi $t3, $t3, 1
	addi $t1, $t1, 4 # increment buffer by three to move to new line
	addi $s2, $s2, 4 # increment number of characters read
	bne $s1, $s2, loopThroughBuffer
	### Draw in graph ###
	### Iterate ###
	### K-means Cluster ##
	
	# exit the program 
	exit:
		li $v0, 10
		syscall
