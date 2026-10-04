# You can change these values to test your solution.
.data
A:    .word 6, 1, 3, 9, 12, 4, 13, 153
B:    .word 6, 1, 3, 9, 12, 4, 13, 153
SIZE: .word 8

.text
main:
  la a1, A                        # a1 = pointer to array A
  la a2, B                        # a2 = pointer to array B
  lw a3, SIZE                     # a3 = number of elements in each array
  jal ra, dot                     # call dot function
exit:
  li a7, 10                       # exit syscall code
  ecall                           # terminate the program


# ==========================================================================
# FUNCTION: dot
#   This function computes the dot product of two integer arrays.
# Arguments:
#   a1 = pointer to first array
#   a2 = pointer to second array
#   a3 = array length
# Returns:
#   a0 = status code  li t1, 0                        
#   a1 = dot product result
# ===========================================================================
dot:
  # TODO: Implement the dot product function here
  li a4, 1                      # minimum array size
  blt a3, a4, invalid_size      # the array size must be equal or greater than 1
  li t0, 0                      # accumulator
  li t1, 0                      # counter

loop_start:
  beq t1, a3, loop_end          # stop condition
  lw t2, 0(a1)                  # current value first array
  lw t3, 0(a2)                  # current value second array

  mul t4, t2, t3                # low part of the multiplication
  mulh t5, t2, t3               # high part of the multiplication
  srai t2, t4, 31               # if there isn't overflow, the hight part is just the natural extension of the low part
  xor t6, t2, t5                # comparison of the high and low parts
  bne t6, x0, overflow          # if the two parts are different, there is overflow

  add t2, t4, t0                # temporary new accumolator
  xor t3, t2, t0                # xor between the old accumulator and the new one
  xor t6, t4, t2                # xor between the low part of the multiplication and the new accumulator
  and t6, t3, t6                # and between the two XORs
  blt t6, x0, overflow          # both parts had the same sign but the result has the oposite sign
  
  mv t0, t2                     # copy the value to the real accumulator

  addi a1, a1, 4                # next element
  addi a2, a2, 4                # next element

  addi t1, t1, 1                # increase counter

  j loop_start



invalid_size:
  li a0, 50                     # code error for invalid size
  j end


overflow:
  li a0, 200                    # code error to overflow
  j end


loop_end:
  li a0, 0                      # no errors have occurred
  mv a1, t0                     # copy the result
  j end

end:
  jr ra                           # return to the caller
