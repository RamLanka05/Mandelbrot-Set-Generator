// main.cpp
//
#include <iostream>
#include <fstream>
using namespace std;

// 4K
const int WIDTH = 3840;
const int HEIGHT = 2160;


__global__ void mandelbrotKernel(unsigned char* data, int width, int height)
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
        // Core is still perfectly crisp black
        data[pixel_index]     = 0;
        data[pixel_index + 1] = 0;
        data[pixel_index + 2] = 0;
    } else {
        // --- CUSTOM GRADIENT PALETTE ---
        // Define an array of colors you want to cycle through (R, G, B)
        const int NUM_COLORS = 5;
        const double purple_palette[5][3] = {
            { 15,   0,   30  },  // 0. Dark Void Purple
            { 75,   0,   130 },  // 1. Deep Indigo
            { 180,  40,  255 },  // 2. Vibrant Violet
            { 255,  200, 255 },  // 3. Starlight Pink/White
            { 5,    0,   15  }   // 4. Near Black
        };
        

        const double bgp_palette[5][3] = {
            { 10,   25,  90  },  // 0. Deep Blue
            { 0,    120, 180 },  // 1. Ocean Teal
            { 40,   200, 120 },  // 2. Bright Green
            { 120,  90,  220 },  // 3. Soft Purple
            { 10,   15,  45  }   // 4. Midnight Blue
        };

        double mu = (double)iters / 100.0; 
        
        // Wrap around smoothly using the fractional part
        int color1_idx = ((int)mu) % NUM_COLORS;
        int color2_idx = (color1_idx + 1) % NUM_COLORS;
        double t = mu - (int)mu; // How far we are between color1 and color2 (0.0 to 1.0)

        // Linear interpolation (lerp) formula: A + t * (B - A)
        data[pixel_index]     = (unsigned char)(purple_palette[color1_idx][0] + t * (purple_palette[color2_idx][0] - purple_palette[color1_idx][0])); // R
        data[pixel_index + 1] = (unsigned char)(purple_palette[color1_idx][1] + t * (purple_palette[color2_idx][1] - purple_palette[color1_idx][1])); // G
        data[pixel_index + 2] = (unsigned char)(purple_palette[color1_idx][2] + t * (purple_palette[color2_idx][2] - purple_palette[color1_idx][2])); // B
    }
}


int main()
{
    int total_pixels = WIDTH * HEIGHT;
    int num_elements = total_pixels * 3;
    size_t bytes = num_elements * sizeof(unsigned char);

    unsigned char* data = new unsigned char[num_elements];
    unsigned char* d_data;
    cudaMalloc((void**)&d_data, bytes);

    dim3 blockSize(16, 16);
    dim3 gridSize((WIDTH + blockSize.x - 1) / blockSize.x, 
                  (HEIGHT + blockSize.y - 1) / blockSize.y);

    mandelbrotKernel<<<gridSize, blockSize>>>(d_data, WIDTH, HEIGHT);
    cudaDeviceSynchronize();
    cudaMemcpy(data, d_data, bytes, cudaMemcpyDeviceToHost);

    ofstream img("mandelbrot.ppm", ios::out | ios::binary);

    img << "P6\n" << WIDTH << " " << HEIGHT << "\n255\n";
    img.write(reinterpret_cast<char*>(data), bytes);
    img.close();

    delete[] data;
    cudaFree(d_data);
    
    cout << "Mandelbrot set generated successfully with smooth gradients!" << endl;
    
    return 0;
}