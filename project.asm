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
displayHeight: .word 64
displayWidth: .word 64
# color of classes
blue: 	.word	0x0066cc # color of 1 class
red: .word  0xFF0000 # color of 0 class
displayColor:.word 0xFFFFFF # white 
black: .word 0x000000 # color of default class
# data file
dataFile: .asciiz "data.txt"
# 100X3 table
xVector: .space 100
yVector: .space 100
colorVector: .space 100
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
la $t2, xVector # store address of 1st column of table
la $t3, yVector # store address of 2nd column of table
la $t4, colorVector # stores address of 3rd column of table
li $s1, 400
li $s2, 0 # store character count to stop the loop
lw $s3, black # store the color of black
	
loopThroughBuffer:
	addi $t5, $t1, 2 # store address of 2nd number
	sb $t1, ($t2) # store number in x column
	sb $t5, ($t3) # store number in y column
	sb $s3 ($t4) # store color in color column
	addi $t2, $t2, 1 # increment column index by 1
	addi $t3, $t3, 1
	addi $t4, $t4, 4 # move color vector to next word
	addi $t1, $t1, 4 # increment buffer by three to move to new line
	addi $s2, $s2, 4 # increment number of characters read
	bne $s1, $s2, loopThroughBuffer
	
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
	addi $a3, $a3, 256
	bne $a3, $a2, DrawYAxis
# go right to draw the x axis
addi $a2, $a2, 256
DrawXAxis:
	sw $a1, ($a3)
	addi $a3, $a3, 4
	bne $a3, $a2, DrawXAxis
### Plot Points ###
li $a0, 2
li $a1, 2
li $a2, 0
jal drawPoint
### Iterate ###
# take the first two points as the centroids 
### K-means Cluster ##
# exit the program 
exit:
	li $v0, 10
	syscall
# input $a0: x coordinate, $a1: y coordinate, $a2: color of point
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
	jr $ra
	 
# input: $a0: x of first data point, $a1: y of first data point, $a2: x of second data point, $a3: y of second data point 
# output: $v0: returns floating point and represents distance between two points
calculateEuclideanDistance:
	jr $ra