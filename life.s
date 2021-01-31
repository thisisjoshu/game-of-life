# board1.s ... Game of Life on a 10x10 grid

	.data

N:	.word 10  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

newBoard: .space 100
# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by Joshua Z, June 2019
# z5196042

    .data
msg1:	.asciiz "# Iterations: "
msg2:	.asciiz "=== After iteration "
msg3:   .asciiz " ==="
eol:    .asciiz "\n"
dot:    .asciiz "."
hash:   .asciiz "#"
    .align 2
## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow
 
 
########################################################################
# .TEXT <main>
	.text
main:
 
# Structure:
#	main
#	-> [prologue]
#	-> maxi_loop
#       -> row_loop
#       -> col_loop
#       -> end_col_loop
#       -> end_row_loop
#	-> end_main [epilogue]
 
# Code:                         # set up stack frame
	sw      $fp, -4($sp)
    la      $fp, -4($sp)
    sw      $ra, -4($fp)
    sw      $s0, -8($fp)        # s0 represents maxiters
    sw      $s1, -12($fp)       # s1 represents n
    sw      $s2, -16($fp)       # s2 represents i
    sw      $s3, -20($fp)       # s3 represents j
    sw      $s4, -24($fp)       # s4 represents nn
    addi    $sp, $fp, -24
    
	la	    $a0, msg1
	li	    $v0, 4
	syscall                     # prints '# Iterations: '
	
	li	    $v0, 5
	syscall	                    # scanf # iterations into maxiters
	
	move    $s0, $v0            # move value from $v0 into maxiters

	li      $s1, 1              # n = 1
maxi_loop:
    bgt     $s1, $s0, end_main
    
    li      $s2, 0              # i = 0
row_loop:
    lw      $t0, N
    bge     $s2, $t0, end_row_loop

    li      $s3, 0              # j = 0
col_loop:
    lw      $t0, N
    bge     $s3, $t0, end_col_loop 
    
    move    $a0, $s2
    move    $a1, $s3
    jal     neighbours          # call function - neighbours (i, j);
       
    move    $s4, $v0            # move return value to $s4 (nn)
    
    lw      $t0, N
    la      $t1, board 
    la      $t2, newBoard
    
    mul     $t0, $s2, $t0       # offset calculation (N * row) + col 
    add     $t0, $t0, $s3    
    
    add     $t4, $t0, $t1       # absolute address of board
    lb      $t1, ($t4)
    
    add     $t3, $t0, $t2       # absolute address of newboard
    lb      $t2, ($t3) 
    
    move    $a0, $t1
    move    $a1, $s4
    jal     decideCell          # call function decideCell
    
    move    $t2, $v0            # load return value into newBoard[i][j]
	sb	    $t2, newBoard($t0)
	
    addi    $s3, $s3, 1         # j++
    j       col_loop

end_col_loop:
    addi    $s2, $s2, 1         # i++
    j       row_loop

end_row_loop:
	la	    $a0, msg2
	li	    $v0, 4              # prints '=== After iteration '
	syscall 
	
	move    $a0, $s1
	li	    $v0, 1              # prints iteration number
	syscall
	
    la	    $a0, msg3
	li	    $v0, 4              # prints ' ==='
	syscall 
	
	la	    $a0, eol
	li	    $v0, 4              # prints '\n'
	syscall 
	     
    jal     copyBackAndShow     # call function - copyBackAndShow
	
	addi    $s1, $s1, 1         # increments n, n++ 
    j       maxi_loop
    
end_main:                       # tear down stack frame
    lw      $s4, -24($fp)
    lw      $s3, -20($fp)
    lw      $s2, -16($fp)
    lw      $s1, -12($fp)
    lw      $s0, -8($fp)
    lw      $ra, -4($fp)
    la      $sp, 4($fp)
    lw      $fp, ($fp)
    li      $v0, 0
	jr	    $ra
	
	
########################################################################
# .TEXT <decideCell>	
    .text
decideCell:
 
# Structure:
#	decideCell
#	-> [prologue]
#	-> oldeq1
#   -> three_neighbours
#   -> return_0
#   -> return_1
#	-> end_decideCell [epilogue]

# Code:                         # set up stack frame
    sw      $fp, -4($sp)
    la      $fp, -4($sp)
    sw      $ra, -4($fp)
    sw      $s0, -8($fp)        # $s0 represents old
    sw      $s1, -12($fp)       # $s1 represents nn
    sw      $s2, -16($fp)       # $s2 represents ret
    addi    $sp, $fp, -16
    
    move    $s0, $a0            # int old
    move    $s1, $a1            # int nn

oldeq1:
    bne     $s0, 1, three_neighbours
    
    blt     $s1, 2, return_0    # if (nn < 2)
    beq     $s1, 2, return_1    # else if (nn == 2)
    beq     $s1, 3, return_1    # else if (nn == 3)
    
    j       return_0

three_neighbours:
    bne     $s1, 3, return_0
    
    j       return_1

return_0:
    li      $s2, 0              # ret = 0
    move    $v0, $s2
    
    j       end_decideCell

return_1:
    li      $s2, 1              # ret = 1
    move    $v0, $s2
    
end_decideCell:                 # tear down stack frame
    lw      $s2, -16($fp)
    lw      $s1, -12($fp)
    lw      $s0, -8($fp)
    lw      $ra, -4($fp)
    la      $sp, 4($fp)
    lw      $fp, ($fp)
	jr	    $ra
 

########################################################################
# .TEXT <neighbours>
    .text
neighbours:
 
# Structure:
#	neighbours
#	-> [prologue]
#	-> loop1
#       -> loop2
#       -> next_loop2
#           -> if_neighbours
#       -> end_loop2
#       -> end_loop1
#	-> end_neighbours [epilogue]

# Code:                         # set up stack frame
    sw      $fp, -4($sp)
    la      $fp, -4($sp)
    sw      $ra, -4($fp)
    sw      $s0, -8($fp)        # $s0 represents nn
    sw      $s1, -12($fp)       # $s1 represents x
    sw      $s2, -16($fp)       # $s2 represents y
    addi    $sp, $fp, -16
    
    li      $s0, 0              # nn = 0
    
    li      $s1, -1             # x = -1
loop1:
    bgt     $s1, 1, end_loop1
    
    li      $s2, -1             # y = -1
loop2:
    bgt     $s2, 1, end_loop2

    lw      $t0, N
    add     $t1, $a0, $s1           # i + x
    sub     $t0, $t0, 1             # N - 1
    add     $t2, $a1, $s2           # j + y
    
    blt     $t1, 0, next_loop2      # i + x < N - 1
    bgt     $t1, $t0, next_loop2    # i + x > N - 1
    blt     $t2, 0, next_loop2      # j + y < N - 1
    bgt     $t2, $t0, next_loop2    # j + y > N - 1
    
    bne     $s1, 0, if_neighbours   # x != 0
    bne     $s2, 0, if_neighbours   # y != 0

next_loop2:
    add     $s2, $s2, 1         # y++
    j       loop2
 
if_neighbours:
    lw      $t0, N
    la      $t1, board 
    
    add     $t3, $s1, $a0       # i + x
    add     $t4, $s2, $a1       # j + y
    
	mul	    $t0, $t0, $t3       # offset calculation (N * row) + col
	add     $t0, $t0, $t4

	add	    $t1, $t1, $t0       # absolute address of board[i + x][j + y]
	lb      $t1, ($t1)
	
    bne     $t1, 1, next_loop2  # if (board[i + x][j + y] == 1)
    
    add     $s0, $s0, 1         # nn++
    j       next_loop2
       
end_loop2:
    add     $s1, $s1, 1         # x++
    j       loop1

end_loop1:
    move    $v0, $s0            # return nn
    
end_neighbours:                 # tear down stack frame
    lw      $s2, -16($fp)
    lw      $s1, -12($fp)
    lw      $s0, -8($fp)
    lw      $ra, -4($fp)
    la      $sp, 4($fp)
    lw      $fp, ($fp)
	jr	    $ra


########################################################################
# .TEXT <copyBackAndShow>
    .text
copyBackAndShow:
 
# Structure:
#	copyBackAndShow
#	-> [prologue]
#	-> print_row
#       -> print_col
#           -> print_dot
#           -> print_hash
#           -> next_col
#       -> end_col
#	-> end_copyBackAndShow [epilogue]

# Code:                         # set up stack frame
	sw      $fp, -4($sp)
    la      $fp, -4($sp)
    sw      $ra, -4($fp)
    sw      $s0, -8($fp)        # s0 represents i
    sw      $s1, -12($fp)       # s1 represents j
    addi    $sp, $fp, -12
	
	li      $s0, 0              # i = 0
print_row:
	lw      $t0, N
	bge     $s0, $t0, end_copyBackAndShow

	li      $s1, 0              # j = 0
print_col:
	lw      $t0, N
	bge     $s1, $t0, end_col 

	la      $t1, board
	la      $t2, newBoard

	mul     $t0, $t0, $s0       # offset calculation (N * row) + col
	add     $t0, $t0, $s1

	add     $t1, $t1, $t0       # absolute address of board[i][j]
	add     $t2, $t2, $t0       # absolute address of newBoard[i][j]

	lb      $t3, ($t2)          # newBoard[i][j] is $t3
	
	sb      $t3, ($t1)          # board[i][j] = newBoard[i][j]
	lb      $t1, ($t1)
	
	beq     $t1, 0, print_dot   # if [i][j] == 0
	bne     $t1, 0, print_hash  # if [i][j] != 0
    
    j       next_col
    
print_dot:
	la      $a0, dot            # prints "."
	li      $v0, 4
	syscall

    j       next_col
    
print_hash:
	la      $a0, hash           # prints "#"
	li      $v0, 4
	syscall

next_col:
	addi    $s1, $s1, 1         # j++
	
	j       print_col
	
end_col:
    la      $a0, eol            # prints new line
	li      $v0, 4
	syscall
	
	addi    $s0, $s0, 1         # i++
	
	j       print_row
	
end_copyBackAndShow:            # tear down stack frame
	lw      $s1, -12($fp)
    lw      $s0, -8($fp)
    lw      $ra, -4($fp)
    la      $sp, 4($fp)
    lw      $fp, ($fp)
    jr      $ra 
