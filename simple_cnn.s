// ---------- SimpleCNN Model Parameters/Constants ----------
.data
// Kernels used for convolution. (6 x 5 x 5) signed bytes
conv_weights:   .byte 1, 2, 1, 1, 5, 2, 7, 4, 4, 4, -5, 1, 2, 0, 0, -9, -4, -4, -3, -2, 0, -3, -3, -2, 0, -4, 1, 3, 2, -1, -2, 3, 3, 1, -5, 5, 4, 2, 0, -4, 5, -1, -3, -2, -4, -5, -6, -1, -1, -2, 0, 3, 0, -3, 0, 8, 4, 2, -6, -6, -1, 1, 10, -2, -5, -8, -3, 9, 5, 1, -1, -4, 0, 4, 6, -3, 8, -2, -5, -3, 4, 5, -6, -5, -1, 4, 6, -3, 0, 1, 0, 1, 1, 0, 1, 1, 1, -1, 1, -1, -5, -3, 0, 4, 2, -2, 0, -1, 4, 4, -3, 0, -2, 3, 3, -3, -1, 0, 5, 2, -3, -4, -5, 0, 5, -7, -3, -2, -2, 4, -3, -4, -4, -6, -3, 3, -1, -1, -3, -5, 4, 3, 3, 1, -5, 3, 1, 2, 4, 2
// Biases used for convolution (6) signed bytes
conv_biases:    .byte -67, -114, -96, -54, -120, -128

// ---------- SimpleCNN Input/Outputs Matrices ----------
.bss
// Input image that is used by the convolution_max_pool procedure. (28 x 28) unsigned bytes
image:                  .space 784
// Temporary matrix used by the convolution_max_pool procedure to store the intermediate
// result of convolution. This is passed to the max_pool function. (24 x 24) signed ints
conv_output:            .space 2304
// This is used to store the result of the convolution_max_pool procedure
// This is passed to the max_pool function. (6 x 12 x 12) signed ints
conv_max_pool_output:   .space 3456

// ---------- Main Procedure (Non-Leaf) ----------
.text
.global _start
_start:

    LDUR X0, =image
    LDUR X1, =conv_weights
    LDUR X2, =conv_biases
    LDUR X3, =conv_max_pool_output
    BL convolution_max_pool
exit:
    // Exit sys call terminates program
    MOV X8, #93
    SVC 0

// ---------- ConvolutionMaxPool Procedure (Leaf) ----------
// Parameters:
//   X0: image
//   X1: weights
//   X2: biases
//   X3: output

//Register Mapping 
//   X0: image (this is the input image data for convolution)
//   X1: weights (the weights for convolution kernels)
//   X2: biases (the biases for each kernel)
//   X3: output (the output matrix for max-pooling results)

//Additional registers that I used to complete this procedure

//SP: the stack pointer, used for saving/restoring registers

//X9: temp register used for holding the running sum of convolution result 
//X14: temp register for the memory address calculations
//X15: temp register for the weights/immediate calculations
//X16: temp register for the column/kernel offsets 

//X19: base address of the image 
//X20: base address of the weights
//X21: base address of the biases 
//X22: base address of output matrix address

//X23: kernel index (k)
//X24: loop counter for j loop
//X25: loop counter for i loop
//X26: loop counter for y loop
//X27: loop counter for x loop 





convolution_max_pool:
    //NOTE: allocate space on the stack for registers (so parameters and LR)

    SUB SP, SP, #48

    //Step 2: save the loop counter registers on the stack 
    
    //save link register 
    STUR LR, [SP, #0]

    //this saves base address of image 
    STUR X19, [SP, #8]

    //this saves base address of weights 
    STUR X20, [SP, #16]

    //this saves base address of biases 
    STUR X21, [SP, #24]

    //this saves output matrix address 
    STUR X22, [SP, #32]

    //x19 = image base pointer 
    MOV X19, X0
    //x20 = weights base pointer
    MOV X20, X1
    //x21 = biases base pointer
    MOV X21, X2
    //x22 = output pointer 
    MOV X22, X3
    //x23 = kernel (k)
    MOV X23, XZR


    

LOOPK_2:
    //compare if k < TOTAL_KERNELS
    CMP X23, #6  
    //branch to 'exit_k_loop' label if X11 >= TOTAL_KERNELS 
    B.GE exit_k_loop_

    //load the address of the conv_output
    LDUR X18, =conv_output

    //Step 5: handle inner loop j 

    //initialize the j loop (j = 0)
    MOV X24, XZR 

LOOPJ_2:
    //compare if j < CONV_OUTPUT_SIZE
    CMP X24, #24
    //branch to 'exit_j_loop' label if X24 >= CONV_OUTPUT_SIZE   
    B.GE exit_j_loop_  

    //Step 6: handle inner most loop i (conv column index)

    //initialize the i loop (i = 0)
    MOV X25, XZR 

LOOPI_2:
    //compare if i < CONV_OUTPUT_SIZE
    CMP X25, #24  
    //branch to 'exit_i_loop' label if X25 >= CONV_OUTPUT_SIZE  
    B.GE exit_i_loop_    

    //initialize the _sum variable (int _sum = 0)
    MOV X9, XZR 

    //Step 7: handle outer nested loop y

    //initialize the y loop (y = 0)
    MOV X26, XZR

LOOPY_2:
    //compare if y < CONV_KERNEL_SIZE
    CMP X26, #5  
    //branch to 'exit_y_loop' label if X26 >= CONV_OUTPUT_SIZE   
    B.GE exit_y_loop_

    //Step 8: handle inner nested loop x

    //initialize the x loop (x = 0)
    MOV X27, XZR
    
LOOPX_2:
    //compare if x < CONV_KERNEL_SIZE
    CMP X27, #5  
    //branch to 'exit_x_loop' label if X27 >= CONV_OUTPUT_SIZE   
    B.GE exit_x_loop_

    //need to load the input[j+y][i+x]

    //X15 = image width (the stride)
    MOV X15, #28

    //X14 = result of j + y
    ADD X14, X24, X26
    //X14 = (j+y) * 28
    MUL X14, X14, X15
    //X16 = i+x
    ADD X16, X25, X27
    //X14 = (j+y)*28 + (i+x)
    ADD X14, X14, X16
    //load the input[j+y][i+x]
    LDURB X14, [X19, X14]

    //move 25 into X15 (from the kernel)
    MOV X15, #25
    //X15 = 25 * k 
    MUL X15, X15, X23
    //move 5 into X16
    MOV X16, #5
    //X16 = 5 * y
    MUL X16, X16, X26 
    //X15 = (25*k)+(5*y)
    ADD X15, X15, X16
    //X15 = (25*k)+(5*y)+x
    ADD X15, X15, X27
    //load the weights[k][y][x]
    LDURSB X15, [X20, X15]
    //X14 = input[j+y][i+x] * weights [k][y][x]
    MUL X14, X14, X15
    //X9 = sum += sum + input[j+y][i+x] * weights [k][y][x]
    ADD X9, X9, X14 

    // x += 1 (x++)
    ADD X27, X27, #1  

    //repeat the x loop 
    B LOOPX_2


exit_x_loop_:
    //y += 1 (y++)
    ADD X26, X26, #1
    //repeat the y loop 
    B LOOPY_2

exit_y_loop_:
    //load the bias
    LDURSB X0, [X21, X23]
    //add bias to _sum variable 
    ADD X0, X0, X9  

    //branch to ReLU function 
    BL relu 

    //calculate the index for the convolution_output[j][i]

    //move 24 into X24
    MOV X14, #24
    //X14 = 24 * j
    MUL X14, X14, X24
    //X14 = 24*j+i 
    ADD X14, X14, X25 
    //left shift by 8 (this is 2^3)
    LSL X14, X14, #2
    //store the output in convolution_output[j][i]
    //so this is relu(sum + biases[k])
    STURW X0, [X18, X14] 

    // i += 1 (i++)
    ADD X25, X25, #1  
    // Repeat i loop
    B LOOPI_2
        

exit_i_loop_:
    //j += 1 (j++)
    ADD X24, X24, #1
    //repeat j loop 
    B LOOPJ_2 

exit_j_loop_:
    //max pooling will be performed after convolution 

    //move kernel index k to X0 
    MOV X0, X23
    //address of conv_output(move to X1)
    MOV X1, X18
    //address of max_pool output (move to X2)
    MOV X2, X22

    //call the max pooling function 
    BL max_pool

    //k += 1 (k++)
    ADD X23, X23, #1
    //repeat k loop 
    B LOOPK_2

exit_k_loop_:
    //NOTE: restore the registers from the stack 

    //restore LR
    LDUR LR, [SP, #0]   
    //restore X19
    LDUR X19, [SP, #8] 
    //restore x20
    LDUR X20, [SP, #16]
    //restore x21
    LDUR X21, [SP, #24] 
    //restore x22
    LDUR X22, [SP, #32]  
    
    //deallocate space on the stack
    ADD SP, SP, #48
    //return control back to conv_max_pool function (caller)
    BR LR

// ---------- MaxPool Procedure (Leaf) ----------
// Parameters:
//   X0: k (kernel index)
//   X1: input (base pointer to conv_output matrix)
//   X2: output (base pointer to conv_max_pool_output matrix)

//Register Mapping:
//X0: k (kernel index), this chooses the output channel for pooling
//X1: input (base pointer to conv_output matrix)
//X2: output (base pointer to conv_max_pool_output matrix)

//Additional registers that I used to complete this procedure:


//X9: the index for the j loop (outer loop for traversing through the input matrix)
//X10: the index for the i loop (inner loop for traversing through the input matrix)
//X11: max value (stores the max value in the 2x2 window)
//X12: the index for the y loop (height of the pooling window)
//X13: the index for the x loop (width of the pooling window)
//X14: temporary register for calculating the current input matrix element 
//X15: temporary register for loading the value from conv_output matrix at the calculated address  
//X16: temporary register used to calculate the column address offset (i*2+x)
//X17: temporary register used to store the address for the current output matrix element (this is used for storing the max value)
//X18: temporary register to store the row offset calculation (j*12)

//The purpose of this procedure is to perform max pooling on the input matrix. 
//It is tasked with scanning the section of the input, takes the max value in a 2x2 window,
//and stores that max value in the output matrix. 

max_pool:  

    //Step 1: handle the outer loop (j)
    MOV X9, XZR //initialize the j loop index (j = 0 ) 
LOOPJ: 
    //compare if j < MAX_POOL_OUTPUT_SIZE
    CMP X9, #12 
    //branch to 'exit_j_loop' label if X9 >= MAX_POOL_OUTPUT_SIZE
    B.GE exit_j_loop   

    //Step 2: handle the inner loop (i) 
    //initialize the i loop index (i = 0)
    MOV X10, XZR  
LOOPI:
    //compare if i < MAX_POOL_OUTPUT_SIZE
    CMP X10, #12    
    //branch to 'exit_i_loop' label if X10 >= MAX_POOL_OUTPUT_SIZE
    B.GE exit_i_loop    

    //Step 4: handle the max pooling (this is the 2x2 window)
    //initialize max value variable (_max) to 0
    MOV X11, XZR

    //Step 5: handle the nested outer loop (y)
    //initialize the y loop index (y = 0)
    MOV X12, XZR 
LOOPY:
    //compare if y < MAX_POOL_WINDOW_SIZE
    CMP X12, #2    
    //branch to 'exit_y_loop' label if X12 >= MAX_POOL_OUTPUT_SIZE
    B.GE exit_y_loop    

    //Step 6: handle the nested inner loop (x)
    //initialize x loop index (x = 0)
    MOV X13, XZR
LOOPX:
    //compare if x < MAX_POOL_WINDOW_SIZE
    CMP X13, #2   

    //branch to 'exit_x_loop' if X13 >= MAX_POOL_OUTPUT_SIZE
    B.GE exit_x_loop    

    //Step 7: handle the indices for the input matrix (j, i)

    //X11 = j * MAX_POOL_STRIDE (this is the row base index)
    //left shift j (j*2)
    LSL X14, X9, #1 

    //X11 = j * MAX_POOL_STRIDE + y (this is the row index)
    ADD X14, X14, X12 

    //move the input matrix width into X12
    MOV X15, #24

    //multiply the result by 24 (this is the input matrix width) to get the address of the offset
    MUL X14, X14, X15

    
    //left shift i (i*2)
    LSL X16, X10, #1 

    //X16 = i * 2 + x
    ADD X16, X16, X13 

    

    //X14 = (j*2+y)*24+(i*2+x)*24
    ADD X14, X14, X16

    //left shift by 8 to convert the index to byte offset
    LSL X14, X14, #2

    //Step 8: load the input value and update the max value 

    //load the input value from conv_output at base pointer + calculated offset
    
    LDURSW X15, [X1, X14] 

    //compare the current max value (X15) with input (X11)
    CMP X15, X11
           

    //if X15 <= X11 (if the current value is less than the max value)   
    B.LE keep_max
    
  
    //otherwise, if X11 >= X15, move X11 into X15 (we update X15)
    MOV X11, X15

    //X11 is up to date
    B.LE keep_max

keep_max:
    //x += 1 (x++)
    ADD X13, X13, #1 
    //branch back to nested inner loop x for the next x
    B LOOPX         

exit_x_loop:
    // y += 1 (y++)
    ADD X12, X12, #1 
    //branch back to nested outer loop y for the next y
    B LOOPY 

exit_y_loop:
    //Step 9: store the max value in the output matrix
    //store _max in the conv_max_pool_output
    //output[k][j][i] = _max; 

    //move constant 144 into X17
    MOV X17, #144
    //x17 = k *144 (this is the offset for the output channel)
    MUL X17, X17, X0

    //move constant 12 into X18
    MOV X18, #12
    //X18 = j *12 (this is the offset for the row in the output)
    MUL X18, X18, X9
    
    //add the offsets of j and i to get the final output index 
    ADD X17, X17, X18
    //X17 = final output index + i
    ADD X17, X17, X10

    //X17 = [(144*k)+(12*j)+i] *4 
    LSL X17, X17, #2

    //store the max value at the calculated output address (which is X2 + X17)
    STURW X11, [X2, X17]
    

    //i += 1 (i++)
    ADD X10, X10, #1
    //branch back to the inner loop i 
    B LOOPI

 
exit_i_loop:
    //j += 1 (j++)
    ADD X9, X9, #1   
    //branch back to outer loop j for the next j
    B LOOPJ 

exit_j_loop:
    //branch back to link register
    //return control to max_pool 
    BR LR   


// ---------- ReLU Procedure (Leaf) ----------
// Parameters:
//   X0: x (convolution + bias)
// Returns:
//   X0: max(0, x)

//Register Mapping:
//X0: Will be used for both the input (x) and the output (max(0,x))

//The purpose of this procedure is to compare the input value of x in X0 with 0.
//If x is greater than 0, the procedure will return x.
//However, if x is less than or equal to 0, the procedure will return 0. 

relu:
    //compare x, which is in X0 with 0
    CMP X0, #0 
    //this will branch to the 'set_x' label if x > 0
    B.GE set_x 
    //this will move 0 into X0 if x <= 0
    MOV X0, XZR  
set_x:
    //note that X0 already has the value of x if x > 0 
    //this will return to the caller (return control back to relu function, this time with X0 containing the value of x)
    BR LR   
