// main.cpp
//
#include <iostream>
#include <fstream>
using namespace std;

const int WIDTH = 1200;
const int HEIGHT = 900;

__global__ void mandelbrotKernel(int* data, int width, int height)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= width || y >= height) return;

    double zx, zy, cX, cY;
    int iters = 0;
    zx = zy = 0;
    cX = (-2.0 + ((double)x / width) * 3.0);
    cY = (-1.5 + ((double)y / height) * 3.0);

    while ((zx * zx) + (zy * zy) < 4.0 && iters < 1000)
    {
        double curr = zx * zx - zy * zy + cX;
        zy = 2 * zx * zy + cY;
        zx = curr;
        ++iters;
    }

    int pixel_index = (y * width + x) * 3;

    if (iters == 1000) {
        data[pixel_index] = 0;         // R
        data[pixel_index + 1] = 0;     // G
        data[pixel_index + 2] = 0;     // B
    } else {
        data[pixel_index] = (iters * 5) % 256;         // R
        data[pixel_index + 1] = (iters * 2) % 256;     // G
        data[pixel_index + 2] = (iters * 11) % 256;    // B
    }
}


int main()
{
    ofstream img("mandelbrot.ppm");
    int total_pixels = WIDTH * HEIGHT;
    int num_elements = total_pixels * 3;
    size_t bytes = num_elements * sizeof(int);

    int* data = new int[num_elements];

    int* d_data;
    cudaMalloc((void**)&d_data, bytes);

    dim3 blockSize(16, 16);
    dim3 gridSize((WIDTH + blockSize.x - 1) / blockSize.x, 
                (HEIGHT + blockSize.y - 1) / blockSize.y);

    mandelbrotKernel<<<gridSize, blockSize>>>(d_data, WIDTH, HEIGHT);
    cudaDeviceSynchronize();
    cudaMemcpy(data, d_data, bytes, cudaMemcpyDeviceToHost);
    
    img << "P3\n" << WIDTH << " " << HEIGHT << "\n255\n";
    
    for (int i = 0; i < num_elements; i += 3) {
        img << data[i] << " " << data[i+1] << " " << data[i+2] << "\n";
    }

    img.close();
    delete[] data;
    cudaFree(d_data);
    
    cout << "Mandelbrot set generated successfully!" << endl;
    
    return 0;
}