import armdb
import armsim
import sys
from simple_cnn import simple_cnn


def init():
    # Load the image into the memory of the assembly program
    image_matrix = simple_cnn.load_image(sys.argv[1])
    image_address = armsim.sym_table['image']
    for index in simple_cnn.iterate_matrix((simple_cnn.INPUT_IMAGE_SIZE, simple_cnn.INPUT_IMAGE_SIZE)):
        y, x = index
        pixel_address = image_address + y * simple_cnn.INPUT_IMAGE_SIZE + x
        pixel = image_matrix[(y, x)]
        armsim.mem[pixel_address:pixel_address + 1] = pixel.to_bytes(1, byteorder='little', signed=False)



def main():
    if not sys.argv[1:]:
        print("Usage: python3 armdb_simple_cnn.py <image_file_path>")
        return

    armdb.main('simple_cnn/simple_cnn.s', init)

    # Print out the output of conv_max_pool
    print("Conv Max Pool Output:")
    output_address = armsim.sym_table['conv_max_pool_output']
    for index in simple_cnn.iterate_matrix(
            (simple_cnn.TOTAL_KERNELS, simple_cnn.MAX_POOL_OUTPUT_SIZE, simple_cnn.MAX_POOL_OUTPUT_SIZE,)):
        k, j, i = index
        address = output_address + (((k * simple_cnn.MAX_POOL_OUTPUT_SIZE * simple_cnn.MAX_POOL_OUTPUT_SIZE)
                                     + (j * simple_cnn.MAX_POOL_OUTPUT_SIZE)
                                     + i) * 4)
        value = int.from_bytes(bytes(armsim.mem[address:address + 4]), byteorder='little', signed=True)
        print(value, end=" ")
        if i == simple_cnn.MAX_POOL_OUTPUT_SIZE - 1:
            print()
            if j == simple_cnn.MAX_POOL_OUTPUT_SIZE - 1:
                print()



if __name__ == "__main__":
    main()