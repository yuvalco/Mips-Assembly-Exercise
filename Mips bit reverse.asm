.data
     error: .asciiz "your number was invalid please try again between 9999 and minus 9999"
     newLine:  .asciiz  "\n"
     
.text
.globl main
main: 

# reads the number  from user
readNumber:
	li $v0, 5
	syscall

	bgt $v0,9999, printError
	blt $v0, -9999 , printError

	#stores read int in  a0 and s0 , and display the number we just read from user
	move $s0, $v0
	move $a0 ,$v0
	li $v0, 1
	syscall

	jal printNewLine	
	
	move $t0, $s0 # load number into t0
	sll $t0, $t0, 16 #shift left 16 bits 
	
	move $t3,$zero # sets t3 to 0	
	addi $t5,$zero ,2147483648 # mask of 1 at the start and zeros 

	# puts a 1 in t2 if the number we read is negtive
	slt $t2, $s0 , $zero

	# s0 original number
	#$t0 - the original sfited left 16
	#t1 - result of mask and zero
	#t3 - counter for loop
	#t5 - mask
	#t6 - result of mask

	
printBits:
	# counter in loop
	beq $t3, 16, printBitsReverse # if t3 is 16 end loop
	addi $t3,$t3, 1 # incremnet t3 by 1

	beq $t2, 1 ,negtiveNumber  # if 1 is negtive than

	and $t6, $t0, $t5 
	slt $t1, $zero, $t6 # t1 holds the value of the bit	

	srl $t5,$t5,1 # shift the mask by 1 to the right
	
	#print the bit 
	move $a0 , $t1
	addi $v0, $zero, 1
    	syscall
    	
	j printBits
	
	
printBitsReverse:
	jal printNewLine
	move $t0 , $s0
	move $t3,$zero # sets t3 to 0
	addi $t5,$zero ,1 # mask of 1 at the start and zeros 
	
	# init these before loop registers
	move $s1, $zero
	addi $t9, $zero, 1
	
	loop:
	beq $t3, 16, printLast # if t3 is 16 end loop and print last number
	addi $t3,$t3, 1 # incremnet t3 by 1
	
	and $t6, $t0, $t5 
	slt $t1, $zero, $t6 # t1 holds the value of the bit	
	sll $t5, $t5,1
	
	#print the bit 
	move $a0 , $t1
	addi $v0, $zero, 1
    	syscall
    	
    	# or t1 
    	beq $t1, 1, orWithMask
    	back:
    	sll $s1, $s1, 1
    	j loop
    	
# each reversed bit is assinged to $s1
orWithMask:
	or $s1, $s1, $t9
	j back
	
# prints the number reversed in 32 bits
printLast:
	
	# extand sign
	srl $s1, $s1, 1	
	addi $t7 $zero, 4294901760
	or $s2, $s1, $t7
	
	jal printNewLine
	
	#print new number
	move $a0 ,$s2
	li $v0, 1
	syscall
	j exit
	

printNewLine:
	addi $v0, $zero, 4  # print string syscall
        la $a0, newLine     # load address of the string
        syscall
	jr $ra
	
	
printError:
	la $a0, error
   	addi $v0, $0, 4
    	syscall
    	j readNumber
    	
	j exit

exit:
	li $v0, 10
	syscall

negtiveNumber:
	move $t2 , $zero# makes sure the condition will only happen once
	srl $t5,$t5,1 # shift the mask by 1 to the right
	addi $t1, $zero, 1 # setts t1 to 1 to print it's bit value
	#print the bit 
	move $a0 , $t1
	addi $v0, $zero, 1
    	syscall
    	
	j printBits
	
