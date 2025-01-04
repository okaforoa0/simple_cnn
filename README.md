**Part 1: SimpleCNN Project Overview**
**Project Summary**

- Explore the basics of convolutional neural networks (CNNs) through image classification of handwritten digits.
- Implement and optimize a CNN in both C and LEGv8 Assembly to classify images.
- Focus on implementing the first two layers of a CNN:
    *Convolution Layer – Extracts features from images.
    *Max Pooling Layer – Reduces the size of feature maps while preserving important information.
  
**Key Features Implemented**
1. Convolution Layer
  - Extracts image features using kernels (small matrices of weights).
  - Outputs a feature map by calculating weighted sums across image subsections.
  - Uses:
    *Input image size: 28x28 pixels.
    *Kernels: 6 kernels, each sized 5x5.
    *Output: 6 feature maps, each sized 24x24.
    
2. Activation Function
- Enables the network to learn non-linear relationships.
- Uses the ReLU (Rectified Linear Unit) function: h(x) = max(0, x).


3. Max Pooling Layer
- Downsamples feature maps while keeping essential information.
- Uses:
    *Window size: 2x2.
    *Stride: 2 (filter moves two steps at a time).
    *Input: Feature maps from the convolution layer (6 x 24 x 24).
    *Output: 6 downsampled feature maps, each sized 12x12.

  
**Implemented Functions**
- ReLU Function
  *Applies the ReLU activation function to each value.
  *Signature: relu(x)
- Max Pooling Function
  *Performs max pooling on the feature map to reduce its size.
  *Signature: max_pool(k, input, output)
  
- Convolution + Max Pool
  *Combines convolution and max pooling to process the input image through the first two CNN layers.
  *Signature: convolution_max_pool(image, weights, biases, output)
  
**Implementation Highlights**
- C Implementation
  *Provided a simple_cnn.h header and simple_cnn.c template file for the CNN.
  *Includes a Makefile for compiling and testing:
    **Compile: make
    **Run: ./simple_cnn "./images/29.png"
    **Clean: make clean
  
**LEGv8 Assembly Implementation**
- Includes:
  *simple_cnn.s: Main assembly code and function labels.
  *armsim_simple_cnn.py: Python script for simulating the assembly implementation.

**Part 2: Fully Connected Layer and Output Handling**

In the second part of the SimpleCNN project, the focus is on completing the neural network pipeline by implementing the Fully Connected (Linear) Layer, Arg Max, Prediction Reporting, and Accuracy Reporting. These steps are critical for transforming the outputs from earlier layers into meaningful predictions and evaluating model performance.

**1. Fully Connected (Linear) Layer**

The Fully Connected Layer takes the feature map from the Max Pooling layer and generates class scores. Key operations in this layer include:

Flattening the Input: The 3D input feature map is flattened into a 1D array.
Matrix Multiplication: The flattened input is multiplied by a weight matrix and added to biases to generate the output class scores.
   - Input: A 3D matrix representing the feature map.
   - Weights: A 4D matrix of signed bytes.
   - Biases: A 1D matrix of signed bytes.
   - Output: A 1D matrix of signed integers representing the class scores.
     
This process can be mathematically expressed as:
𝑦=𝑊⋅𝑥+𝑏

where:
   - x is the flattened feature map.
   - W is the weight matrix.
   - b is the bias vector.
   - y is the output vector of scores.

**2. Arg Max**

The Arg Max function selects the class with the highest score from the Fully Connected Layer output. This class is the model's predicted label for the input image.

   - Input: A 1D array of class scores.
   - Output: The index of the highest score in the array.

**3. Reporting Predictions**

The report_prediction procedure outputs the prediction results for each image in the dataset. It prints in the format: \text{[image_index]:[expected_output],[actual_output]}
Additionally, it tracks the number of correct and incorrect predictions using global variables.

**4. Reporting Accuracy**

The report_accuracy procedure calculates and prints the overall accuracy of the model in percentage format: \text{[accuracy_percent]%}

Accuracy is determined as:
Accuracy= Correct Predictions/Total Predictions × 100

**Program Flow**

- Input Processing: The output from the Max Pooling layer is passed to the Fully Connected Layer.
- Prediction: The class with the highest score is selected using Arg Max.
- Output Reporting: Predictions for each image are logged using report_prediction.
- Accuracy Reporting: The overall model accuracy is computed and displayed using report_accuracy.

**Linux System Calls**

Printing outputs to the terminal in assembly is achieved using Linux system calls. Key registers for the write system call are:

   - X0: File descriptor (#1 for STDOUT).
   - X1: Address of the string to display.
   - X2: Length of the string.
   - X8: System call number (0x40 for write).
   
**Implementation Steps**

The project is implemented in four main functions in assembly:

   - report_prediction: Logs predictions and tracks performance.
   - report_accuracy: Calculates and displays accuracy.
   - arg_max: Identifies the predicted class with the highest score.
   - linear: Implements the Fully Connected Layer computation.
   
**Running the Project**

After completing the implementation:

   - Upload the project files to the Raspberry Pi server.
   - Compile using make.
   - Run the project using ./simple_cnn.
   - Verify output accuracy by comparing assembly outputs with the provided Python implementation.
