# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4
INDEX: .word 2

.text
main:
  la a1, ARRAY      # a1 = pointer to array
  lw a2, SIZE       # a2 = array length
  lw a3, INDEX      # a3 = element index
  jal ra, select    # call select function
exit:
  li a7, 10         # exit syscall code
  ecall             # terminate the program

# ==========================================================================
# FUNCTION: select
#   This function selects an element from an integer array.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length
#   a3 = element index
# Returns:
#   a0 = status code
#   a1 = value of the selected element
# ===========================================================================
select:
  # TODO: Implement the select function here
  li t2, 1              # minimum vector size
  blt a2, t2, argInv    # if the size is greater than 1, don't update the code status
  bge a3, a2, outLimit  # cheks if element index > array length
  blt a3, x0,outLimit   # cheks if element index < 0
  li a0, 0              # update of the status code
  li t4, 4              # selected element of the vector
  mul t5, a3, t4        # multiplies the index by 4 to obtain the offset
  add t5, a1, t5        # updates the pointer to the required element of the vector  
  lw a1, 0(t5)          # stores the element of the vector
  j select_end          # jump to the end
  

outLimit:
  li a0, 100            # status code of off limits index
  j select_end          # jump to the end

argInv:
  li a0, 50             # invalid size
  j select_end          # jump to the end

select_end:
  jr ra                 # return to the caller
