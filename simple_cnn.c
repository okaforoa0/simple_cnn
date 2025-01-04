#include "simple_cnn.h"
 
//gcc -o simple_cnn simple_cnn.c (use this to compile code)

//This functon compares the value of x with 0. If x is greater than 0, then the function returns x. 
//Otherwise, if x is less than 0, the function will return 0.

int relu(int x)	// this function will take a parameter of x as an integer
{
	return x > 0 ? x : 0; //return x if it is greater than 0, otherwise return 0
}


//This function performs a convolution on the input image and uses the given weights and biases,
//which is applied using the function ReLu to the result of each convolution

void convolution_max_pool(IMAGE input, CONV_WEIGHT_MATRIX weights, CONV_BIAS_MATRIX biases, CONV_MAX_POOL_OUTPUT_MATRIX output) //this function takes parameters input, weights, biases, and output
{
	for (int k = 0; k < TOTAL_KERNELS; k++){ //iterate over each kernel
		CONV_OUTPUT_MATRIX convulution_output; //declare a matrix to hold the convolution output values for the current kernel

		for (int j = 0; j < CONV_OUTPUT_SIZE; j++){ //iterate over the rows of the output matrix
			for (int i = 0; i < CONV_OUTPUT_SIZE; i++){ //iterative over the columns of the output matrix
				int _sum = 0; //here, initialize sum variable for the convolution result at position (j,i)

				for (int y = 0; y < CONV_KERNEL_SIZE; y++) { //iterate over the rows of the kernel
					for (int x = 0; x < CONV_KERNEL_SIZE; x++) { //iterate over the columns of the kernel
						_sum += input[j+y][i+x] * weights[k][y][x]; //continue to accumulate the product of the input pixel and weight
					}
				}
				
				convulution_output[j][i] = relu(_sum + biases[k]); //call relu function and add bias, then we store that value in convolution output
			}
		}
		
		max_pool(k, convulution_output, output); //call max_pool function on the convolution output and store that result in the output matrix
	}

}

//This function performs max pooling on the input matrix. 
//It is tasked with scanning the section of the input, takes the max value in a 2x2 window, and stores that max value in the output matrix. 

void max_pool(int k, CONV_OUTPUT_MATRIX input, CONV_MAX_POOL_OUTPUT_MATRIX output) //this function takes parameters k, input, and output 
{
	for (int j = 0; j < MAX_POOL_OUTPUT_SIZE; j++) {//iterate over the rows of the output
		for (int i = 0; i < MAX_POOL_OUTPUT_SIZE; i++) {//iterate over the columns of the ouput
			int _max = 0; //here, initialize max variable for the current pooling window

			//this is to iterate over the pooling window
			for (int y = 0; y < MAX_POOL_WINDOW_SIZE; y++) {//iterate over the height of the pooling window
				for (int x = 0; x < MAX_POOL_WINDOW_SIZE; x++) { //iterate over the width of the pooling window
					int input_index_j = j * MAX_POOL_STRIDE + y; //calculate row index in input
					int input_index_i = i * MAX_POOL_STRIDE + x; //now calculate column index in input 

					//if the max value if greater than the input value, return the max value
					//otherwise, if it is less than the input value, return that input value
					_max = (_max > input[input_index_j][input_index_i]) ? _max : input[input_index_j][input_index_i]; //need to update the max value found in the pooling window
				}
			}
			
			output[k][j][i] = _max; //store the max value found in the output matrix 
		}
	}

}
