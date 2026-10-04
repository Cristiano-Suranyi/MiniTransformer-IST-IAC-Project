###########################################################################
# Upper bound constants for static memory reservation
###########################################################################
.equ CONST_DIMENSION 4
.equ CONST_BUFFER_SIZE 1024
.equ CONST_MAX_VOCAB_TOKENS 100
.equ CONST_MAX_INPUT_TOKENS 10

###########################################################################
# System call constants
###########################################################################
.equ CONST_SYSCALL_PRINT_INT 1
.equ CONST_SYSCALL_PRINT_STRING 4
.equ CONST_SYSCALL_PRINT_CHAR 11
.equ CONST_SYSCALL_EXIT 10
.equ CONST_SYSCALL_EXIT2 93
.equ CONST_SYSCALL_OPEN 1024
.equ CONST_SYSCALL_CLOSE 57
.equ CONST_SYSCALL_READ 63
.equ CONST_SYSCALL_WRITE 64 

###########################################################################
# ASCII character constants
###########################################################################
.equ CONST_CHAR_EOF 0
.equ CONST_CHAR_SPACE 32
.equ CONST_CHAR_NEWLINE 10
.equ CONST_CHAR_HYPHEN 45
.equ CONST_CHAR_ZERO 48

.data
###########################################################################
# Data section with static memory reservations.
# Feel free to add more if needed.
###########################################################################
VOCABULARY_FILENAME:     .string "vocab.txt"
EMBEDDINGS_FILENAME:     .string "embeddings.txt"
INPUT_FILENAME:          .string "input.txt"

W_Q_FILENAME:            .string "W_Q.txt"
W_K_FILENAME:            .string "W_K.txt"
W_V_FILENAME:            .string "W_V.txt"

VOCAB_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the vocabulary file
INPUT_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the input file
MATRIX_BUFFER:           .zero CONST_BUFFER_SIZE                              # Contents of a matrix file (used for W_Q, W_K, W_V, and embeddings)

INPUT_INDICES_VECTOR:    .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of input token indices (#inputs x 4 bytes)
SCORES_VECTOR:           .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of scores (#tokens x 4 bytes)

INPUT_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the input
VOCAB_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the vocabulary

VOCAB_EMBEDDINGS_MATRIX: .zero (CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
INPUT_EMBEDDINGS_MATRIX: .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
W_Q_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_Q matrix (dimension x dimension x 4 bytes)
W_K_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_K matrix (dimension x dimension x 4 bytes)
W_V_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_V matrix (dimension x dimension x 4 bytes)
Q_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Q matrix (#tokens x dimension x 4 bytes)
K_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # K matrix (#tokens x dimension x 4 bytes)
V_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # V matrix (#tokens x dimension x 4 bytes)

.text
main:
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    # TODO
    la a0, VOCABULARY_FILENAME                          # file path
    la a1, VOCAB_BUFFER                                 # destination buffer
    li a2, CONST_BUFFER_SIZE                            # max number of bytes to read

    jal read_file                                       # read vocab
    

    ###########################################################################
    # Read input
    ###########################################################################
    # TODO
    la a0, INPUT_FILENAME                               # file path
    la a1, INPUT_BUFFER                                 # destination buffer
    li a2, CONST_BUFFER_SIZE                            # max number of bytes to read

    jal read_file                                       # read input

    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    # TODO
    la a0, W_Q_FILENAME                                 # file path
    la a1, MATRIX_BUFFER                                # destination buffer
    li a2, CONST_BUFFER_SIZE                            # max number of bytes to read

    jal read_file                                       # read W_Q matrix

    ###########################################################################
    # Parse W_Q matrix
    ###########################################################################
    # TODO
    la a0, W_Q_MATRIX                                   # W_q matrix adress
    la a1, MATRIX_BUFFER                                # matrix data buffer
    
    jal parse_matrix_buffer                             # parse W_q matrix

    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    # TODO
    la a0, W_K_FILENAME                                 # file path
    la a1, MATRIX_BUFFER                                # destination buffer
    li a2, CONST_BUFFER_SIZE                            # max number of bytes to read

    jal read_file                                       # read W_K matrix

    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    # TODO
    la a0, W_K_MATRIX                                   # W_k matrix adress
    la a1, MATRIX_BUFFER                                # matrix data buffer
    
    jal parse_matrix_buffer                             # parse W_k matrix

    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    # TODO
    la a0, W_V_FILENAME                                 # file path
    la a1, MATRIX_BUFFER                                # destination buffer
    li a2, CONST_BUFFER_SIZE                            # max number of bytes to read

    jal read_file                                       # read W_V matrix

    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    # TODO
    la a0, W_V_MATRIX                                   # W_v matrix adress
    la a1, MATRIX_BUFFER                                # matrix data buffer
    
    jal parse_matrix_buffer                             # parse W_v matrix

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    # TODO
    la a0, EMBEDDINGS_FILENAME                          # file path
    la a1, MATRIX_BUFFER                                # destination buffer
    li a2, CONST_BUFFER_SIZE                            # max number of bytes to read

    jal read_file                                       # read embeddings matrix

    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    # TODO
    la a0, VOCAB_EMBEDDINGS_MATRIX                      # vocab embeddings matrix adress
    la a1, MATRIX_BUFFER                                # matrix data buffer
    
    jal parse_matrix_buffer                             # parse vocab embeddings matrix

    la t0, VOCAB_TOTAL_TOKENS
    sw a1, 0(t0)                                        # number of words in vocab

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    # TODO
    la a0, INPUT_INDICES_VECTOR                         # indices vector adress
    la a2, INPUT_BUFFER                                 # input buffer adress
    la a3, VOCAB_BUFFER                                 # vocab buffer adress

    jal tokens_to_indices                               # convert the input tokens to vocab indices

    la t0, INPUT_TOTAL_TOKENS                           # total number of words in input adress
    sw a1, 0(t0)                                        # number of words in input

    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    # TODO
    la a0, INPUT_EMBEDDINGS_MATRIX                      # input embeddings matrix adress
    la a1, VOCAB_EMBEDDINGS_MATRIX                      # vocab embeddings matrix adress
    la a2, INPUT_INDICES_VECTOR                         # indices vector
    lw a3, INPUT_TOTAL_TOKENS                           # number of words in input

    jal build_input_embeddings_matrix                   # build the input embeddings matrix

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    # TODO
    la a0, Q_MATRIX                                     # Q matrix adress
    la a1, INPUT_EMBEDDINGS_MATRIX                      # input embeddings matrix adress
    lw a2, INPUT_TOTAL_TOKENS                           # number of words in the input = number of rows of Q
    li a3, CONST_DIMENSION                              # number of columns of Q (in general, 4)
    la a4, W_Q_MATRIX                                   # W_q matrix adress
    li a5, CONST_DIMENSION                              # number of rows of W_q (in general, 4)
    li a6, CONST_DIMENSION                              # number of columns of W_q (in general, 4)

    jal matrix_multiply                                 # build Q matrix

    ###########################################################################
    # Build matrix K
    ###########################################################################
    # TODO
    la a0, K_MATRIX                                     # K matrix adress
    la a1, INPUT_EMBEDDINGS_MATRIX                      # input embeddings matrix adress
    lw a2, INPUT_TOTAL_TOKENS                           # number of words in the input = number of rows of K
    li a3, CONST_DIMENSION                              # number of columns in K (in general, 4)
    la a4, W_K_MATRIX                                   # W_k matrix adress
    li a5, CONST_DIMENSION                              # number of rows of W_k (in general, 4)
    li a6, CONST_DIMENSION                              # number of columns of W_k (in general, 4)

    jal matrix_multiply                                 # build K matrix

    ###########################################################################
    # Build matrix V
    ###########################################################################
    # TODO
    la a0, V_MATRIX                                     # V matrix adress
    la a1, INPUT_EMBEDDINGS_MATRIX                      # input embeddings matrix adress
    lw a2, INPUT_TOTAL_TOKENS                           # number of words in the input = number of rows of V
    li a3, CONST_DIMENSION                              # number of columns in V (in general, 4)
    la a4, W_V_MATRIX                                   # W_v matrix adress
    li a5, CONST_DIMENSION                              # number of rows of W_v (in general, 4)
    li a6, CONST_DIMENSION                              # number of columns of W_v (in general, 4) 

    jal matrix_multiply                                 # build V matrix
     
    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    # TODO
    la a0, SCORES_VECTOR                                # scores vector adress
    la a1, Q_MATRIX                                     # Q matrix adress
    la a2, K_MATRIX                                     # K matrix adress
    lw a3, INPUT_TOTAL_TOKENS                           # number of words in the input = number of rows of Q and K
    li a4, CONST_DIMENSION                              # number of coluns of Q and K (in general, 4)
    lw a5, INPUT_TOTAL_TOKENS                           # number of words in the input = last index + 1

    addi a5, a5, -1                                     # correct value of last index

    jal compute_scores                                  # build the scores vector
    
    ###########################################################################
    # Get the highest score index using argmax
    ###########################################################################
    # TODO
    
    la a1, SCORES_VECTOR                                # pointer to the scores vector
    lw a2, INPUT_TOTAL_TOKENS                           # length of the scores vector

    jal argmax                                          # call to argmax function, result in a0 and a1 -> choose the highest value
    
    ###########################################################################
    # Select chosen vector in V using the index from argmax
    ###########################################################################
    # TODO\
    mv a4, a1                                           # prepare arguments to select_vector_in_matrix: target row
    la a1, V_MATRIX                                     # V matrix adress
    lw a2, INPUT_TOTAL_TOKENS                           # number of words in the input = number of rows V
    li a3, CONST_DIMENSION                              # number of columns of V (in general, 4) 
    
    jal select_vector_in_matrix                         # Select the chosen vector

    ###########################################################################
    # Pick the next token in the vocabulary with the highest score
    ###########################################################################
    # TODO
    la a1, VOCAB_EMBEDDINGS_MATRIX                      # pointer to the vocab embeddings matrix
    lw a2, VOCAB_TOTAL_TOKENS                           # number of tokens in the vocabulary

    jal decide_next_token                               # call to decide_next_token function

    mv a1, a0                                           # prepare arguments: index of the predicted token
    la a0, VOCAB_BUFFER                                 # vocab buffer adress
    
    jal indices_to_tokens                               # convert the indice of the predicted token to a pointer to the predicted token
    
    jal print_predicted_token                           # print the predicted token

    ###########################################################################
    # Terminate program successfully
    ###########################################################################
    li a0, 0
    j exit_with_code                                    # Exit with code 0

# Read from a text file into a buffer.
# (in)  a0: filename address (char*)
# (in / out)  a1: destination buffer
# (in)  a2: maximum number of bytes to read
read_file:
    # TODO
    addi sp, sp, -20                                    # reserve space on the stack for 5 words
    sw a0, 16(sp)                                       # write a0 on memory
    sw a1, 12(sp)                                       # write a1 on memory
    sw a2, 8(sp)                                        # write a2 on memory
    sw ra, 4(sp)                                        # write ra on memory

open:

    li a7, CONST_SYSCALL_OPEN                           # open file service code
    li a1, 0                                            # flag of read only file
    ecall                                               # call to the system, a0 is now the file descriptor
    li t0, -1                                           # read error code
    beq a0, t0, end_read_file                           # give error if there is any read error

read:
    lw a1, 12(sp)                                       # load from memory the buffer adress
    lw a2, 8(sp)                                        # load from memory max number of byts
    sw a0, 0(sp)                                        # save on memory the file descriptor
    li a7, CONST_SYSCALL_READ                           # read file service code
    ecall                                               # call to the system, a0 is now the real number of read byts

close:
    mv t1, a0                                           # copy the number of read bytes
    lw a0, 0(sp)                                        # load from memory the file descriptor
    sw t1, 16(sp)                                       # save on memory the number of read bytes
    li a7, CONST_SYSCALL_CLOSE                          # close file service code
    ecall                                               # call to the system
    lw a0, 16(sp)                                       # load real read bytes from memory

end_read_file:
    lw ra, 4(sp)                                        # load return adress from memory
    addi sp, sp, 20                                     # free reserved memory
    jr ra                                               # return

# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in / out) a0: address of the matrix to fill (int*)
# (out) a1: number of rows in the matrix (int)
# (in)  a1: address of the buffer containing the matrix data (char*)
parse_matrix_buffer:
    # TODO
    mv t0, zero                                         # rows counter
    mv t1, zero                                         # current integer
    li t2, 10                                           # multiplier
    mv t3, a0                                           # copy the matrix adress
    mv t4, zero                                         # negative integer flag

loop_parse_matrix_buffer:
    lb t5, 0(a1)                                        # load of the current byte from the buffer

    li t6, CONST_CHAR_SPACE                             # ASCII code to ' '
    beq t5, t6, new_collum                              # if the byte represents ' ', process next column

    li t6, CONST_CHAR_NEWLINE                           # ASCII code to '\n'
    beq t5, t6, new_row                                 # if the byte represents '\n', increase the rows counter

    li t6, CONST_CHAR_EOF                               # ASCII code to 'EOF'
    beq t5, t6, loop_parse_matrix_buffer_end            # if the byte represents 'EOF' it's the last element

    li t6, CONST_CHAR_HYPHEN                            # ASCII code to '-'
    bne t5, t6, calc_new_digit                          # jump to the calculus of the updated integer
    addi t4, t4, -1                                     # the integer is negative

    addi a1, a1, 1                                      # next byte
    
    j loop_parse_matrix_buffer

calc_new_digit:
    mul t1, t1, t2                                      # shift to the left on decimal base
    addi t5, t5, -CONST_CHAR_ZERO                       # convert the digit from ASCII to decimal base
    add t1, t1, t5                                      # update the current integer

    addi a1, a1, 1                                      # next byte

    j loop_parse_matrix_buffer 

new_collum:
    bne t4, zero, new_negative_integer                  # the integer is negative
    j new_integer

new_integer:
    sw t1, 0(t3)                                        # filling the matrix with the integer
    mv t1, zero                                         # restart current integer to 0
    addi t3, t3, 4                                      # next word space
    addi a1, a1, 1                                      # next byte
    j loop_parse_matrix_buffer

new_negative_integer:
    mul t1, t1, t4                                      # converting to negative integer
    mv t4, zero                                         # restart the flag
    j new_integer

new_row:
    addi t0, t0, 1                                      # increase the number of rows
    bne t4, zero, new_negative_integer                  # the integer is negative
    j new_integer

loop_parse_matrix_buffer_end:
    mv a1, t0                                           # move the output
    jr ra                                               # return


# Converts the input tokens into their corresponding indices in the vocabulary.
# (in / out)  a0: address of input indices vector to fill (int*)
# (in)  a2: address to input buffer
# (in)  a3: address to vocabulary buffer
# (out) a1: size of input indices vector (number of tokens in input)
tokens_to_indices:
    # TODO
    mv t0, zero                                         # number of words in the input
    mv t1, a3                                           # copy of the vocab buffer pointer
    mv t2, a2                                           # copy of the input buffer pointer
    mv t3, zero                                         # current vocab word

loop_tokens_to_indices:
    lb t4, 0(t2)                                        # current input character
    li t5, CONST_CHAR_EOF                               # ASCII code to 'EOF'
    beq t4, t5, end_of_input                            # we've reached the end of the input
    lb t5, 0(t1)                                        # current vocab character
    bne t4, t5, not_equal_characters                    # if the characters are not equal, the comparison has failed

equal_characters:
    li t5, CONST_CHAR_NEWLINE                           # ASCII code to '\n'
    beq t4, t5, end_of_word                             # if both characters are '\n' the word has ended and we have a match
    addi t1, t1, 1                                      # next vocab byte
    addi t2, t2, 1                                      # next input byte
    j loop_tokens_to_indices

end_of_input:
    mv a1, t0                                           # copy the number of words in the input
    jr ra                                               # return

end_of_word:
    slli t1, t0, 2                                      # calculate the offset

    add t1, t1, a0                                      # pointer to the correct index to fill
    sw t3, 0(t1)                                        # write the index in the vector

    addi t0, t0, 1                                      # increase the number of computed words
    mv t3, zero                                         # restart the vocab word index
    addi t2, t2, 1                                      # next input byte
    mv a2, t2                                           # start at next input word
    mv t1, a3                                           # start at the vocab starting point
    
    j loop_tokens_to_indices

not_equal_characters:
    li t4, CONST_CHAR_NEWLINE                           # ASCII code to '\n'
    beq t5, t4, prepare_new_search                      # we've reached the end of this vocab word
    addi t1, t1, 1                                      # next vocab byte
    lb t5, 0(t1)                                        # current vocab character
    j not_equal_characters                              # we have not reached the end of this vocab word

prepare_new_search:
    addi t3, t3, 1                                      # increase the counter of current vocab word
    addi t1, t1, 1                                      # next vocab byte
    mv t2, a2                                           # start again at the input word's starting point
    j loop_tokens_to_indices


# (in / out) a0: address of the output matrix to fill (int*)
# (in)  a1: address of the vocabulary embeddings matrix (int*)
# (in)  a2: address of the input indices array (int*)
# (in)  a3: number of tokens in the input (int)
build_input_embeddings_matrix:
    # TODO
    mv t0, zero                                         # current indices vector index
    mv t1, a0                                           # copy output matrix adress

indices_loop:
    beq t0, a3, indices_loop_end                        # we've reached the end of the input
    lw t2, 0(a2)                                        # current index
    addi a2, a2, 4                                      # next index

calc_adress:
    slli t2, t2, 4                                      # index * (columns * 4)
    add t2, t2, a1                                      # final adress (base address + offset)

copy_values_to_adress:
    lw t3, 0(t2)                                        # load first value of vocab embeddings
    sw t3, 0(t1)                                        # write first value in the output matrix
    lw t3, 4(t2)                                        # load second value of vocab embeddings
    sw t3, 4(t1)                                        # write second value in the output matrix
    lw t3, 8(t2)                                        # load third value of vocab embeddings
    sw t3, 8(t1)                                        # write third value in the output matrix
    lw t3, 12(t2)                                       # load fourth value of vocab embeddings
    sw t3, 12(t1)                                       # write fourth value in the output matrix

prepare_next_index:
    addi t1, t1, 16                                     # next output matrix row
    addi t0, t0, 1                                      # update the index counter
    j indices_loop

indices_loop_end:
    jr ra                                               # return

# (in / out) a0: address of the output matrix (int*)
# (in)  a1: address of the first matrix (int*)
# (in)  a2: #rows of the first matrix (int)
# (in)  a3: #columns of the first matrix (int)
# (in)  a4: address of the second matrix (int*)
# (in)  a5: #rows of the second matrix (int)
# (in)  a6: #columns of the second matrix (int)
matrix_multiply:
    # TODO
    addi sp, sp, -52                                    # reserve space on the stack for 13 words
    sw s0, 48(sp)                                       # store previous s0 in the stack
    sw s1, 44(sp)                                       # store previous s1 in the stack
    sw s2, 40(sp)                                       # store previous s2 in the stack
    sw s3, 36(sp)                                       # store previous s3 in the stack
    sw s4, 32(sp)                                       # store previous s4 in the stack
    sw s5, 28(sp)                                       # store previous s5 in the stack
    sw s6, 24(sp)                                       # store previous s6 in the stack
    sw s7, 20(sp)                                       # store previous s7 in the stack
    sw s8, 16(sp)                                       # store previous s8 in the stack
    sw s9, 12(sp)                                       # store previous s9 in the stack
    sw s10, 8(sp)                                       # store previous s10 in the stack
    sw s11, 4(sp)                                       # store previous s11 in the stack
    sw ra, 0(sp)                                        # store return address on the stack
    
    mv s0, zero                                         # current row
    mv s1, zero                                         # current column
    mv s2, a0                                           # make a duplicate of the output matrix address
    mv s3, a1                                           # make a duplicate of the A matrix address
    mv s4, a2                                           # make a duplicate of the number of rows of the A matrix
    mv s5, a4                                           # make a duplicate of the address of the B matrix
    mv s7, s2                                           # make a triplicate of the output matrix address
    mv s8, a6                                           # make a duplicate of the number of columns of the B matrix
    mv s9, a3                                           # make a duplicate of the number of columns of the A matrix
    mv s11, a4                                          # make a triplicate of the address of the B matrix 
    
    slli s10, s8, 2                                     # calculate the memory jump to the next row of B

loop_matrix_multiply:
    beq s0, s4, end_matrix_multiply                     # we have computed the entire matrix
    beq s1, s8, next_row_matrix_multiply                # we have computed the entire row

build_column_vector:
    slli t0, s9, 2                                      # calculate the total size of the column vector
    sub sp, sp, t0                                      # reserve space on the stack for the column vector
    mv s6, sp                                           # starting point of the columns vector
    mv t1, zero                                         # start the iterator
    mv t2, s5                                           # start the pointer to traverse the current column of B

copy_column_loop:
    beq t1, s9, continue_matrix_multiply                # we have copied the entire column
    lw t3, 0(t2)                                        # load element from the B matrix
    slli t4, t1, 2                                      # calculate the offset of the current element
    add t4, s6, t4                                      # calculate the memory address in the stack
    sw t3, 0(t4)                                        # write the element to the column vector
    add t2, t2, s10                                     # advance pointer to the next element of the column
    addi t1, t1, 1                                      # update iterator
    j copy_column_loop                                  # jump to copy the next element

continue_matrix_multiply:
    mv a1, s3                                           # prepares the a1 argument to the dot function
    mv a2, s6                                           # prepares the a2 argument to the dot function
    mv a3, s9                                           # prepares the a3 argument to the dot function
    jal ra, dot                                         # calling dot function
    slli t0, s9, 2                                      # calculate the total size of the column vector
    add sp, sp, t0                                      # free the memory allocated to the column vector
    sw a1, 0(s7)                                        # fills the correct entry on the output matrix
    addi s7, s7, 4                                      # next entry on the output matrix
    addi s5, s5, 4                                      # start of the next column
    addi s1, s1, 1                                      # update column counter
    j loop_matrix_multiply                              # jump to compute the next entry

next_row_matrix_multiply:
    addi s0, s0, 1                                      # update the row counter
    li s1, 0                                            # restart the column counter
    mv s5, s11                                          # jump to first column
    slli t0, s9, 2                                      # calculate the size of a row of A
    add s3, s3, t0                                      # next row entry on A matrix
    j loop_matrix_multiply                              # jump to compute the next row

end_matrix_multiply:
    mv a0, s2                                           # prepares the output of the function
    lw s0, 48(sp)                                       # loads previous s0 from the stack
    lw s1, 44(sp)                                       # loads previous s1 from the stack
    lw s2, 40(sp)                                       # loads previous s2 from the stack
    lw s3, 36(sp)                                       # loads previous s3 from the stack
    lw s4, 32(sp)                                       # loads previous s4 from the stack
    lw s5, 28(sp)                                       # loads previous s5 from the stack
    lw s6, 24(sp)                                       # loads previous s6 from the stack
    lw s7, 20(sp)                                       # loads previous s7 from the stack
    lw s8, 16(sp)                                       # loads previous s8 from the stack
    lw s9, 12(sp)                                       # loads previous s9 from the stack
    lw s10, 8(sp)                                       # loads previous s10 from the stack
    lw s11, 4(sp)                                       # loads previous s11 from the stack
    lw ra, 0(sp)                                        # loads return address from the stack
    addi sp, sp, 52                                     # free space on the stack for 13 words
    jr ra                                               # return

# (in / out) a0: address of the output scores vector (int*)
# (in)  a1: address of Q matrix (int*)
# (in)  a2: address of K matrix (int*)
# (in)  a3: #rows of Q and K (int)
# (in)  a4: #columns of Q and K (int)
# (in)  a5: target token index for which we want to compute the score (int)
compute_scores:
    # TODO
    slli t0, a4, 2                                      # size, in bytes, of one line (number_of_columns * 4)
    mul t0, t0, a5                                      # total offset (line_size * target_token_index)
    add t0, t0, a1                                      # updated pointer to target in Q matrix

    addi sp, sp, -32                                    # reserve space on the stack for 8 words
    sw s0, 28(sp)                                       # store previous s0 in the stack
    sw s1, 24(sp)                                       # store previous s1 in the stack
    sw s2, 20(sp)                                       # store previous s2 in the stack
    sw s3, 16(sp)                                       # store previous s3 in the stack
    sw s4, 12(sp)                                       # store previous s4 in the stack
    sw s5, 8(sp)                                        # store previous s5 in the stack
    sw s6, 4(sp)                                        # store previous s6 in the stack
    sw ra, 0(sp)                                        # store return address on the stack

    mv s0, a0                                           # make a duplicate of the output adress
    mv s1, a2                                           # make a duplicate of the K matrix adress
    mv s2, a3                                           # make a duplicate of the number of rows of Q and K
    mv s3, a4                                           # make a duplicate of the number of columns of Q and K
    mv s4, s0                                           # make a duplicate of the target
    mv s5, t0                                           # make a duplicate of the target starting point pointer
    mv s6, zero                                         # number of computed K rows

compute_scores_loop:
    beq s6, s2, compute_scores_end                      # we have computed the entire matrix
    
    mv a1, s5                                           # prepare argument a1 for the dot function
    mv a2, s1                                           # prepare argument a2 for dot function
    mv a3, s3                                           # prepare argument a3 for the dot function
    
    jal ra, dot                                         # call the dot function

    sw a1, 0(s4)                                        # write the result on the output matrix
    addi s4, s4, 4                                      # next entry on the output matrix
    addi s6, s6, 1                                      # update the computed rows counter

    slli t0, s3, 2                                      # size, in bytes, of one line (number_of_columns * 4)
    add s1, s1, t0                                      # next K matrix row

    j compute_scores_loop

compute_scores_end:
    mv a0, s0                                           # prepare the output argument
    
    lw s0, 28(sp)                                       # loads previous s0 from the stack
    lw s1, 24(sp)                                       # loads previous s1 from the stack
    lw s2, 20(sp)                                       # loads previous s2 from the stack
    lw s3, 16(sp)                                       # loads previous s3 from the stack
    lw s4, 12(sp)                                       # loads previous s4 from the stack
    lw s5, 8(sp)                                        # loads previous s5 from the stack
    lw s6, 4(sp)                                        # loads previous s6 from the stack
    lw ra, 0(sp)                                        # loads return address on the stack
    
    addi sp, sp, 32                                     # free space on the stack for 8 words

    jr ra                                               # return

# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:
    # TODO
    slli t0, a3, 2                                      # size, in bytes, of one line (number_of_columns * 4)
    mul t0, t0, a4                                      # total offset (line_size * target row number)
    add a0, a1, t0                                      # return
    jr ra

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
decide_next_token:
    # TODO
    addi sp, sp, -32                                    # reserve space on the stack for 8 words
    sw s0, 28(sp)                                       # store previous s0 in the stack
    sw s1, 24(sp)                                       # store previous s1 in the stack
    sw s2, 20(sp)                                       # store previous s2 in the stack
    sw s3, 16(sp)                                       # store previous s3 in the stack
    sw s4, 12(sp)                                       # store previous s4 in the stack
    sw s5, 8(sp)                                        # store previous s5 in the stack
    sw s6, 4(sp)                                        # store previous s6 in the stack
    sw ra, 0(sp)                                        # store return address on the stack

    mv s0, a0                                           # make a duplicate of the target vector adress
    mv s1, a1                                           # make a duplicate of the vocab embeddings adress
    mv s2, a2                                           # make a duplicate of the number of tokens in the vocab
    
    li s3, 4                                            # number of columns of the embeddings matrix

    li s6, 1                                            # number of computed embeddings

decide_next_token_initialization:
    mv a1, s0                                           # prepare arguments for dot
    mv a2, s1                                           # prepare arguments for dot
    mv a3, s3                                           # prepare arguments for dot

    jal ra, dot                                         # call dot for the first embedding

    mv s4, a1                                           # current max value
    mv s5, zero                                         # current index of max value

decide_next_token_embeddings_loop:
    beq s6, s2, decide_next_token_end                   # we've computed all the embeddings vector
    
    slli t0, s3, 2                                      # number_of_columns * 4
    add s1, t0, s1                                      # previous_pointer + offset = new_base

    mv a1, s0                                           # prepare arguments for dot
    mv a2, s1                                           # prepare arguments for dot
    mv a3, s3                                           # prepare arguments for dot

    jal ra, dot                                         # call dot

    ble a1, s4, decide_next_token_embeddings_loop_end   # no need to update the max values
    mv s4, a1                                           # new max value
    mv s5, s6                                           # update the max value index

decide_next_token_embeddings_loop_end:
    addi s6, s6, 1                                      # update the number of embeddings computed

    j decide_next_token_embeddings_loop

decide_next_token_end:
    mv a0, s5                                           # prepare output

    lw s0, 28(sp)                                       # loads previous s0 from the stack
    lw s1, 24(sp)                                       # loads previous s1 from the stack
    lw s2, 20(sp)                                       # loads previous s2 from the stack
    lw s3, 16(sp)                                       # loads previous s3 from the stack
    lw s4, 12(sp)                                       # loads previous s4 from the stack
    lw s5, 8(sp)                                        # loads previous s5 from the stack
    lw s6, 4(sp)                                        # loads previous s6 from the stack
    lw ra, 0(sp)                                        # loads return address on the stack

    addi sp, sp, 32                                     # free space on the stack for 8 words

    jr ra                                               # return



#############################################################################################################
# Aux
#############################################################################################################
# Converts the predicted token index into a pointer to the start of that token in the vocabulary.
# (in / out) a0: pointer to vocabulary buffer (char*)
# (in)  a1: target index of the predicted token (int)
indices_to_tokens:
    #TODO
    beq a1, zero, indices_to_tokens_end                 # if the target index is 0, the first word starts at the beginning of the buffer
    mv t0, zero                                         # counter of newlines encountered
    li t1, CONST_CHAR_NEWLINE                           # ASCII code to '\n'

loop_indices_to_tokens:
    lb t2, 0(a0)                                        # load current vocabulary character
    
    beq t2, t1, increase_char_newline                   # if character is '\n', we found a word boundary

    j loop_indices_to_tokens_end                        # if it's a regular character, skip to next byte

increase_char_newline:
    addi t0, t0, 1                                      # increment the newline counter
    
loop_indices_to_tokens_end:
    addi a0, a0, 1                                      # advance vocabulary pointer to next byte

    beq a1, t0, indices_to_tokens_end                   # if number of newlines equals target index, we reached the word

    j loop_indices_to_tokens                            # continue traversing the vocabulary buffer

indices_to_tokens_end:
    jr ra                                               # return


#############################################################################################################
# Dot product and argmax helper functions.
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:
    beq t1, a3, dot_end_loop                        # If t1 == SIZE, we are done
    lw t2, 0(a1)                                    # Load A[t1] into t2
    lw t3, 0(a2)                                    # Load B[t1] into t3
    mul t4, t2, t3                                  # t4 = A[t1] * B[t1]
    # Check if the multiplication of A[t1] and B[t1] overflows
    mulh t5, t2, t3                                 # t5 = high 32 bits of A[t1] * B[t1] (signed)
    srai t6, t4, 31                                 # t6 = sign extension of low 32 bits (0 or -1)
    bne t5, t6, overflow                            # Overflow if high bits != sign extension of low bits
    mv t6, t0                                       # Store the current result in t6 for overflow checking
    add t0, t0, t4                                  # t0 += A[t1] * B[t1]
    # Check if the previous addition caused an overflow
    # Careful: adding negative numbers will correctly result in a negative number, so we need to check for overflow in both directions.
    bgt t6, zero, check_positive_overflow           # If previous result was positive, check for positive overflow
    blt t6, zero, check_negative_overflow           # If previous result was negative, check for negative overflow
    j dot_continue_loop
check_positive_overflow:
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop
check_negative_overflow:
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bgt t0, zero, overflow                          # If t0 > 0 after adding a negative number, we have an overflow
    j dot_continue_loop
dot_continue_loop:
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_loop                       # if SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_loop:
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller

exit_with_code:
    li a7, CONST_SYSCALL_EXIT2
    ecall




#############################################################################################################
# Helper functions for printing and debugging.
#############################################################################################################

.data
PRINT_HEADER_VOCABULARY:    .string "=== Vocabulary ==="
PRINT_HEADER_INPUT:         .string "=== Input ==="
PRINT_HEADER_INPUT_INDICES: .string "=== Input Indices ==="
PRINT_HEADER_MATRIX:        .string "=== Matrix ==="
PRINT_HEADER_SCORES:        .string "=== Scores ==="
PRINT_HEADER_NEXT_TOKEN:    .string "=== Decision ==="
PRINT_VECTOR_LB:            .string "[ "
PRINT_VECTOR_RB:            .string "]"

.text
# Prints a null-terminated string followed by a newline.
# (in) a0: buffer to print (char*)
println:
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    ret

# Prints the vocabulary buffer.
# (in) a0: address of the vocabulary buffer (char*)
print_vocabulary:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_VOCABULARY
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input buffer as a string.
# (in) a0: address of the input buffer (char*)
print_input:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_INPUT
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input indices vector.
# (in) a0: address of the input indices vector (int*)
# (in) a1: size of the input indices vector (int)
print_indices:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    la a0, PRINT_HEADER_INPUT_INDICES
    jal println
    mv a0, s0
    mv a1, s1
    jal print_vector
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

print_scores:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, PRINT_HEADER_SCORES
    jal println
    la a0, SCORES_VECTOR
    lw a1, INPUT_TOTAL_TOKENS
    jal print_vector
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a0: address of matrix to print (int*)
# a1: number of rows
# a2: number of columns
print_matrix:
    addi sp, sp, -24
    sw ra, 0(sp)                                    # return address
    sw s0, 4(sp)                                    # matrix pointer
    sw s1, 8(sp)                                    # row index
    sw s2, 12(sp)                                   # col index
    sw s3, 16(sp)                                   # number of rows
    sw s4, 20(sp)                                   # number of columns
    mv s0, a0                                       # s0 = pointer to matrix
    mv s3, a1                                       # s3 = number of rows
    mv s4, a2                                       # s4 = number of columns
    li s1, 0                                        # s1 = current row index
    la a0, PRINT_HEADER_MATRIX
    jal println
print_matrix_row_loop:
    beq s1, s3, print_matrix_done
    li s2, 0
print_matrix_col_loop:
    beq s2, s4, print_matrix_next_row
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    addi s0, s0, 4
    addi s2, s2, 1
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    j print_matrix_col_loop
print_matrix_next_row:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_matrix_row_loop
print_matrix_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

# a0: address of vector to print (int*)
# a1: number of elements (int)
print_vector:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    mv s0, a0                                       # s0 = pointer to vector
    mv s1, a1                                       # s1 = number of elements
    la a0, PRINT_VECTOR_LB                          # Print "[ "
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
print_vector_loop:
    beq s1, zero, print_vector_done
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 4
    addi s1, s1, -1
    j print_vector_loop
print_vector_done:
    la a0, PRINT_VECTOR_RB                          # Print "]"
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret

print_predicted_token:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_NEXT_TOKEN
    jal println
    # s0 = start of target token, print it char by char until newline or null
print_predicted_token_char:
    lb t0, 0(s0)
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, print_predicted_token_nl            # newline terminator
    mv a0, t0
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 1
    j print_predicted_token_char
print_predicted_token_nl:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret