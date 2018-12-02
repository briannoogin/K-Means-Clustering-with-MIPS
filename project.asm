# K-means clustering visualization for binary classifcation data     #
# by Brian Nguyen						     #	
# 	Program uses Bitmap display to display the scatter plot      #
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
# print output of centroids to console 
# adds tests for convergence

.data
# screen size dimensions
displayHeight: .word 64
displayWidth: .word 64

# number of iterations for k-means
iterations: .word 10

# color of classes
blue: 	.word	0x0066cc # color of 1 class
red: .word  0xFF0000 # color of 0 class
displayColor:.word 0xFFFFFF # white 
black: .word 0x000000 # color of default class

# data file
dataFile: .asciiz "data.txt"

# 100X3 table
# align 2 makes aligns memory to word
xVector:
	.align 2 
	.space 400 
yVector:
	.align 2 
	.space 400 
colorVector:
	    .align 2
	    .space 400
fileBuffer: 
	    .align 0
	    .space 600 
	    
centroids: .space 16 # array contains the coordinates of both centroids 

# used for floating point division 
division: .float 2.0
guess: .float 2

# used for printing out new lines
newLine: .asciiz "\n"
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
	
# initialize variables 
la $t1, fileBuffer # store address of the file buffer
la $t2, xVector # store address of 1st column of table
la $t3, yVector # store address of 2nd column of table
la $t4, colorVector # stores address of 3rd column of table
li $s1, 600
li $s2, 0 # store character count to stop the loop
lw $s3, black # store the color of black
	
loopThroughBuffer:
	addi $t5, $t1, 3 # store address of 2nd number in the row
	
	# load half the number from the buffer
	lb $t6, ($t1) 
	lb $t7, ($t5) 
	
	# converts ascii to number
	addi $t6,$t6,-48 
	addi $t7,$t7,-48
	
	# load the 2nd half of the number from the buffer
	lb $t8, 1($t1)
	lb $t9, 1($t5)
	
	# converts ascii to number
	addi $t8,$t8,-48
	addi $t9,$t9,-48
	
	# multiply the digit by 10 to make the num the tens digit
	mul $t6, $t6, 10 
	mul $t7, $t7, 10
	
	# combine the tens and one digit 
	add $t6, $t6, $t8 
	add $t7, $t7, $t9
	
	sw $t6, ($t2) # store number in x column
	sw $t7, ($t3) # store number in y column
	sw $s3 ($t4) # store color in color column
	
	# increment column index by a word
	addi $t2, $t2, 4 
	addi $t3, $t3, 4
	addi $t4, $t4, 4 
	
	addi $t1, $t1, 6 # increment buffer by six to move to new line
	addi $s2, $s2, 6 # increment number of characters read
	
	# i < 400
	blt $s2, $s1, loopThroughBuffer 
	
### Draw in graph ###
lw $a0, displayWidth
lw $a1, displayColor
mul $a2, $a0,$a0 # calculate total pixels
mul $a2, $a2, 4 # each pixel stores 4 bytes
add $a2, $a2, $gp # add to the $gp to mark the end
addi $a3, $gp, 0 # index
	
# makes the screen white
FillScreen:
	sw $a1, ($a3) # change pixel to white
	addiu $a3, $a3, 4 # move word by 1
	bne $a2, $a3, FillScreen
	
# draws the graph lines
lw $a1, black # store the color black
mul $a2,$a0, 4 # multiply the number of pixels by 4 to format the address
mul $a2, $a2, 35 # find total length of a column
add $a2, $a2, $gp # add length of column by the position of the graph
move $a3, $gp # reset to index original position 

# go down to draw the y axis
DrawYAxis: 
	sw $a1, ($a3)
	# move to next row
	addi $a3, $a3, 256
	blt $a3, $a2, DrawYAxis
# go right to draw the x axis
addi $a2, $a2, 256
DrawXAxis:
	sw $a1, ($a3)
	# move one pixel right 
	addi $a3, $a3, 4
	blt $a3, $a2, DrawXAxis
### Plot Points ###
la $s1, xVector 
la $s2, yVector
la $s3, colorVector
li $s4,0 # i = 0

drawAllPoints:
	# load the points
	lw $a0, ($s1)
	lw $a1, ($s2)
	lw $a2, ($s3)
	jal drawPoint
	
	# move to next word 
	addi $s1, $s1, 4 
	addi $s2, $s2, 4
	addi $s3, $s3, 4
	
	# i++
	addi $s4, $s4, 1
	# i < 100
	blt $s4, 100, drawAllPoints
### K-means Clustering ###
la $s1, xVector 
la $s2, yVector
la $s3, colorVector
la $s4, centroids
lw $s5, blue
lw $s6, red

# take the first two points as the centroids
lw $t3, ($s1)
lw $t4, ($s2) 
sw $t3, ($s4) # store 1st centroid
sw $t4, 4($s4)
sw $s5, ($s3) # mark point as blue

# get second point
lw $t3, 4($s1)
lw $t4, 4($s2) 
sw $t3, 8($s4) # store 2nd centroid 
sw $t4, 12($s4)
sw $s6, 4($s3)

# print the 1st colored point
lw $a0, ($s1)
lw $a1, ($s2)
lw $a2, ($s3)
jal drawPoint

# pause the program for .1 seconds
li $v0, 32
li $a0, 100 
syscall

# print the 2nd point
lw $a0, 4($s1)
lw $a1, 4($s2)
lw $a2, 4($s3)
jal drawPoint

# pause the program for .1 seconds
li $v0, 32
li $a0, 100 
syscall

### Iteration ###

# initialize variables 
li $t1, 0 # index i = 0
lw $t2, iterations
la $s1, xVector
la $s2, yVector
la $s3, colorVector
la $s4, centroids
lw $s5, blue
lw $s6 red

iteration:
	# i = 0
	li $t0, 0 
	loopThroughAllPoints:
		# load the point 
		lw $t1, ($s1)
		lw $t2, ($s2)
		
		# compare the points to centroids by computing distance
		# load point into parameters
		move $a0, $t1
		move $a1, $t2
		# 1st centroid
		# load centroid point
		lw $a2, ($s4)
		lw $a3, 4($s4)
		jal calculateEuclideanDistance
		# save output
		mov.s $f10,$f4
		
		# 2nd centroid
		# load centroid point
		lw $a2, 8($s4)
		lw $a3, 12($s4)
		jal calculateEuclideanDistance
		# save output
		mov.s $f11,$f4 
		
		# compare if point is closer to the first centroid or to the second centroid 
		c.lt.s $f10, $f11
		# save blue if condition is true
		movt $t3, $s5
		# save red if condition is false
		movf $t3, $s6
		# store new color
		sw $t3, ($s3)
		
		# draw point
		lw $a0, ($s1)
		lw $a1, ($s2)
		lw $a2, ($s3)
		jal drawPoint
		
		# increment to next word
		addi $s1, $s1, 4 # xVector
		addi $s2, $s2, 4 # yVector
		addi $s3, $s3, 4 # colorVector
		# i < 100
		blt $t0, 100, loopThroughAllPoints
		
		
	# pause the program for .1 seconds 
	#li $v0, 32
	#li $a0, 100 
	# iteration++
	addi $t1,$t1, 1 
	# iteration < 10
	bne $t1,$t2, iteration 
	
# exit the program 
exit:
	li $v0, 10
	syscall
# input: $a0: x coordinate, integer
# 	 $a1: y coordinate, integer
#	 $a2: color of point, integer
# assumes that the coordinates are within the boundaries of the graph 
# output: none
drawPoint:
	# convert coordinate to address
	# recenter the coordinate relative to the origin
	lw $t1, displayWidth
	mul $t1, $t1, 4 # format pixels into address
	mul $t1, $t1, 35 # number of pixels in the column
	
	add $t1, $t1, $gp # add address of the coordinate to the address of the graph 
	mul $t2, $a1, 256 # multiply y coordinate by 256 to get the location of the y address
	sub $t1, $t1, $t2 # offset the address to correctly match the y coordinate 
	mul $t2, $a0, 4 # multiply x coordinate by 4 to get the location of the x address 
	add $t1, $t1, $t2  # add to move point right 
	
	# change address to specified color 
	sw $a2,($t1)
	
	# return to caller
	jr $ra
	 
# input: $a0: x of first data point, integer
#	 $a1: y of first data point, integer
#	 $a2: x of second data point, integer
#        $a3: y of second data point, integer
# output: $f4: returns floating point and represents distance between two points
# distance formula = ((x2-x1)^2 + (y2-y1)^2)^.5
calculateEuclideanDistance:

	# x2 - x1
	sub $v0, $a2, $a0
	
	# y2 - y1
	sub $v1, $a3, $a1 
	
	# square both values
	mul $v0, $v0, $v0
	mul $v1, $v1, $v1
	
	# add both squared values and pass it to calculate square root function
	add $a0, $v0, $v1
	
	# store $ra in stack before function call
	sw $ra, 4($sp)
	
	# call function 
	jal calculateSquareRoot
	
	# pop off the stack
	lw $ra, 4($sp)
	
	# return
	jr $ra 
	
# input: $a0: integer number
# output: $f4: returns the resulting floating square root of the number
# square root is approximated with 3 iterations of Newton's Method. 
# Newton's method: xn+1 = .5(xn + a/xn) where a is number you want to take the square root of and x0 is the initial guess
calculateSquareRoot:
	
	# return 0 if $a0 is 0
	bne  $a0, 0, calc
	mtc1 $a0, $f4 # move input to floating point register
	cvt.s.w $f2, $f4 # convert word to single point
	jr $ra
	calc:
	# initialize variables 
	mtc1 $a0, $f2 # move input to floating point register
	cvt.s.w $f2, $f2 # convert word to single point
	l.s $f3, division # used for division 
	
	li $t8, 0 # num iterations = 0
	li $t9, 5 # max num of iterations for newtons method
	li $t0, 0 # i = 0
	srl $t2, $a0, 1
	move $t1, $a0, # store a into x
	
	calcInitialGuess: # calculate the integer square root for a close guess
		divu $t3, $a0, $t1  # a/x
		add  $t3, $t1, $t3 	# x + a/x
		srl $t1, $t3, 1 # x = .5(x + a/x)
		addi $t0, $t0,1 # i++
		blt $t0, $t2, calcInitialGuess # i < a/2
		
	mtc1 $t1,$f1 # move x to floating point register
	cvt.s.w $f1, $f1 # convert word to single point
	
	approximate:
		div.s $f4, $f2, $f1 # a/xn
		add.s $f4, $f1, $f4 # xn + a/xn
		div.s $f4, $f4, $f3 # .5(xn + a/xn)
		addi $t8, $t8, 1
		blt $t8, $t9, approximate # iterations < 5
		
	# print out the value
	li $v0, 2
	mov.s $f12, $f4
	syscall
	
	# print out new line
	# store $a0 so it does not get overwritten
	sw $a0, ($sp)
	li $v0, 4
	la $a0, newLine
	syscall
	lw $a0, ($sp)
	# return
	jr $ra