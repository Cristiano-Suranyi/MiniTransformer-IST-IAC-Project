# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4

.text
main:
  la a1, ARRAY        # a1 = pointer to array
  lw a2, SIZE         # a2 = number of elements in the array
  jal ra, argmax      # call argmax function
exit:
  li a7, 10           # exit syscall code
  ecall               # terminate the program

# ==========================================================================
# FUNCTION: argmax
#   Takes an array of integers and returns the index of the largest element.
#   If there are multiple elements with the same maximum value, 
#   it should return the smallest index among them.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length 
# Returns:
#   a0 = status code
#   a1 = index of the largest element
# ===========================================================================
argmax:
  # TODO: Implement the argmax function here
  li a0, 50               # inicialization of the status code
  li a3, 1                # minimum vector size
  blt a2, a3, argmax_end  # if the size is less than 1, don't update the code status
  li a0, 0                # update of the status code
  lw t0, 0(a1)            # selected element of the vector
  li t1, 0                # selected vector index
  li t2, 1                # current vector index
  addi t3, a1, 4          # loop variable
  

loop_start:
  beq t2, a2, loop_end    # if the current index is greater or equal to the vector size, stop
  lw t4, 0(t3)            # current element
  ble t4, t0, next        # if t4 <= t0, jump to the next element of the vector
  mv t0, t4               # select the new max value
  mv t1, t2               # select the new value index
  j next                  # jump to the next element

next:
  addi t3, t3, 4          # shift to the next element
  addi t2, t2, 1          # next index (important to the break condition)
  j loop_start            # jump to the start

loop_end:
  mv a1, t1               # move the result to the return variable
  j argmax_end            # jump to the end

argmax_end:
  jr ra                   # return to the caller