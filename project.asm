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
# print output of centroids to console 
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
# align 1 makes aligns memory to half word
xVector:.align 2 
	.space 400 
yVector:.align 2 
	.space 400 
colorVector:.align 2
	    .space 400
fileBuffer: .align 0
	    .space 600 
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
li $s1, 600
li $s2, 0 # store character count to stop the loop
lw $s3, black # store the color of black
	
loopThroughBuffer:
	addi $t5, $t1, 3 # store address of 2nd number in the row
	
	lb $t6, ($t1) # load half the number from the buffer
	lb $t7, ($t5) 
	addi $t6,$t6,-48 # converts ascii to number
	addi $t7,$t7,-48
	
	lb $t8, 1($t1) # load the 2nd half of the number from the buffer
	lb $t9, 1($t5)
	addi $t8,$t8,-48 # converts ascii to number
	addi $t9,$t9,-48
	
	mul $t6, $t6, 10 # multiply the digit by 10 to make the num the tens digit
	mul $t7, $t7, 10
	add $t6, $t6, $t8 # combine the tens and one digit 
	add $t7, $t7, $t9
	
	sw $t6, ($t2) # store number in x column
	sw $t7, ($t3) # store number in y column
	sw $s3 ($t4) # store color in color column
	
	addi $t2, $t2, 4 # increment column index by a word
	addi $t3, $t3, 4
	addi $t4, $t4, 4 
	
	addi $t1, $t1, 6 # increment buffer by four to move to new line
	addi $s2, $s2, 6 # increment number of characters read
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
la $s1, xVector 
la $s2, yVector
la $s3, colorVector
li $a2, 0 # load black color
li $s4,0 # i = 0
drawAllPoints:
	lw $a0, ($s1)
	lw $a1, ($s2)
	li $a2, 0
	jal drawPoint
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $s4, $s4, 1
	bne $s4, 100, drawAllPoints
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