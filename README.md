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
