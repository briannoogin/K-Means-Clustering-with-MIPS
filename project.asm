# K-means clustering visualization for binary data
# by Brian Nguyen
.data
# screen size dimensions
screenHeight: .word 64
screenWidth: .word 64
# color of classes
blue: 	.word	0x0066cc # blue
backgroundColor:.word	0xFFFFFF # white	 
.text
	main:
	
	
	# exit the program 
	exit:
		li $v0, 10
		syscall