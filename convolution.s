
.data
input:      .space 40000
weights:    .space 9
bias:       .space 1
output:     .space 40000

.text
.global _start
_start:
main:
// ---------- Main Procedure ----------
LDUR X1, =input
LDUR X2, =weights
LDUR X3, =bias
LDUR X4, =output
BL convolution
exit:
// Exit sys call terminates program
MOV X8, #93
SVC 0

// ---------- Convolution Procedure ----------
// Parameters:
// x0 = n
// x1 = &input: pointer to N x N matrix of signed words
// x2 = &weights: pointer to 3 x 3 matrix of signed bytes
// x3 = &bias: pointer to a single signed byte
// x4 = &output: pointer to (N - 2) x (N - 2) matrix of signed words
// Register Mapping:
// x19 = j
// x20 = i
// x21 = y
// x22 = x
// x23 = sum
// x24 = n
// x25 = &input
// x26 = &weights
// x27 = &bias
// x28 = &output

//used registers x5-x16 to store immediate values and offsets 

convolution:
// Preserve LR and saved registers
SUB SP, SP, #96
STUR X19, [SP, #0]
STUR X20, [SP, #8]
STUR X21, [SP, #16]
STUR X22, [SP, #24]
STUR X23, [SP, #32]
STUR X24, [SP, #40]
STUR X25, [SP, #48]
STUR X26, [SP, #56]
STUR X27, [SP, #64]
STUR X28, [SP, #72]
STUR LR, [SP, #80]

// Preserve Parameters
//move the input matrx size n into x24
MOV X24, X0
//load address of input into x25
LDUR X25, =input
//load address of weights into x26
LDUR X26, =weights
//load address of bias into x27
LDUR X27, =bias
//load the bias value which is a signed byte
LDURSB X27, [X27]
//load address of output matrix into x28
LDUR X28, =output

// j = 0
MOV X19, XZR

convolution_loop_j:
// exit if j >= n - 2
//multiply j by n to get offset for the input
MUL X5, X19, X24
//left shift x5 by 2 for word size
LSL X5, X5, #2
//add the offset to input address, and load point for row j 
ADD X10, X25, X5

//subtract 2 from n
SUB X0, X24, #2
//multiply j to get offset for the output
MUL X6, X19, X0
//left shift by 2 for word size
LSL X6, X6, #2
//add offset to output addres, and load pointer for row j output
ADD X11, X28, X6

//left shift n by 2
LSL X7, X24, #2
//add result together to use to access weight offsets
ADD X16, X7, X7

// B.GE convolution_exit_loop_j

// i = 0
MOV X20, XZR

convolution_loop_i:
// exit if i >= n - 2
//multiply i by 4 to get byte offset for input row
LSL X8, X20, #2
//add byte offset to input row pointer
ADD X12, X10, X8
//add byte offset to output row pointer
ADD X13, X11, X8

//load word from input matrix (the current position)
LDURSW X8, [X12]
//load signed byte from weights matrix (current weight)
LDURSB X9, [X26]
//multiply input value by weight, store in sum (x23)
MUL X23, X8, X9

//load the next word from input matrix
LDURSW X8, [X12, #4]
//load next weight byte
LDURSB X9, [X26, #1]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//load the next word from input matrix
LDURSW X8, [X12, #8]
//load next weight byte
LDURSB X9, [X26, #2]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//move on to new row in n 
ADD X14, X12, X7

//load word from next row in input 
LDURSW X8, [X14]
//load next weight byte
LDURSB X9, [X26, #3]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//load word from next row in input 
LDURSW X8, [X14, #4]
//load next weight byte
LDURSB X9, [X26, #4]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//load word from next row in input 
LDURSW X8, [X14, #8]
//load next weight byte
LDURSB X9, [X26, #5]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//add offset for next row in n to x12
ADD X15, X12, X16

//load next word from matrix at address in x15 into x8
LDURSW X8, [X15]
//load next weight byte
LDURSB X9, [X26, #6]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//load next word with offset of 4 bytes
LDURSW X8, [X15, #4]
//load next weight byte
LDURSB X9, [X26, #7]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//load next word with offset of 8 bytes
LDURSW X8, [X15, #8]
//load next weight byte
LDURSB X9, [X26, #8]
//multiply input value by weight
MUL X8, X8, X9
//add to sum
ADD X23, X23, X8

//add bias to conv sum
ADD X23, X23, X27


//this part handles relu activation
//arithmetic shift right by 63 (for saturation)
ASR X9, X23, #63
//sign correction
EOR X9, X23, X9
//apply result back to sum
AND X23, X23, X9

//store result in output matrix
STURW X23, [X13]
//increment column index i  by 1
ADD X20, X20, #1

//compare i with n 
CMP X20, X0
//branch to label if i < n-2
B.LT convolution_loop_i


//increment row index j by 1 
ADD X19, X19, #1

//compare j with n
CMP X19, X0
//branch to label if j < n - 2
B.LT convolution_loop_j


convolution_exit_loop_j:
// Restore LR and saved registers
LDUR X19, [SP, #0]
LDUR X20, [SP, #8]
LDUR X21, [SP, #16]
LDUR X22, [SP, #24]
LDUR X23, [SP, #32]
LDUR X24, [SP, #40]
LDUR X25, [SP, #48]
LDUR X26, [SP, #56]
LDUR X27, [SP, #64]
LDUR X28, [SP, #72]
LDUR LR, [SP, #80]
ADD SP, SP, #96

MOV X8, #93
SVC 0