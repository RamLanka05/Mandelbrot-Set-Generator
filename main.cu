#include <iostream>
#include <fstream>
#include <cmath>
using namespace std;

// 4K Resolution Settings
const int WIDTH = 3840;
const int HEIGHT = 2160;

__global__ void mandelbrotKernel(unsigned char* data, int width, int height, double centerX, double centerY, double zoom, bool optimize)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= width || y >= height) return;

    int pixel_index = (y * width + x) * 3;

    // --- MODE 1: UN-OPTIMIZED (ALIASED & BANDED) ---
    if (!optimize) {
        double cX = centerX + (x - width / 2.0) * (zoom / width);
        double cY = centerY + (y - height / 2.0) * (zoom / width);

        double zx = 0, zy = 0;
        int iters = 0;

        while ((zx * zx) + (zy * zy) < 16.0 && iters < 1000) {
            double curr = zx * zx - zy * zy + cX;
            zy = 2 * zx * zy + cY;
            zx = curr;
            ++iters;
        }

        if (iters == 1000) {
            data[pixel_index]     = 0;
            data[pixel_index + 1] = 0;
            data[pixel_index + 2] = 0;
        } else {
            const int NUM_COLORS = 5;
            const unsigned char bgp_palette[5][3] = {
                { 0,   180, 140 },  // Tealish Green
                { 10,  90,  220 },  // Royal Blue
                { 130, 40,  240 },  // Electric Purple
                { 210, 130, 255 },  // Soft Lavender
                { 5,   10,  30  }   // Midnight Navy
            };
            // Harsh discrete step-banding via raw modulo mapping
            int color_idx = iters % NUM_COLORS;
            data[pixel_index]     = bgp_palette[color_idx][0];
            data[pixel_index + 1] = bgp_palette[color_idx][1];
            data[pixel_index + 2] = bgp_palette[color_idx][2];
        }
    } 
    // --- MODE 2: OPTIMIZED (2x2 SSAA & CONTINUOUS LOG SMOOTHING) ---
    else {
        double totalR = 0, totalG = 0, totalB = 0;

        for (int subY = 0; subY < 2; ++subY) {
            for (int subX = 0; subX < 2; ++subX) {
                double offsetX = (subX + 0.5) / 2.0 - 0.5;
                double offsetY = (subY + 0.5) / 2.0 - 0.5;

                double cX = centerX + (x + offsetX - width / 2.0) * (zoom / width);
                double cY = centerY + (y + offsetY - height / 2.0) * (zoom / width);

                double zx = 0, zy = 0;
                int iters = 0;

                while ((zx * zx) + (zy * zy) < 16.0 && iters < 1000) {
                    double curr = zx * zx - zy * zy + cX;
                    zy = 2 * zx * zy + cY;
                    zx = curr;
                    ++iters;
                }

                if (iters == 1000) {
                    totalR += 0; totalG += 0; totalB += 0;
                } else {
                    const int NUM_COLORS = 5;
                    const double bgp_palette[5][3] = {
                        { 0,   180, 140 },
                        { 10,  90,  220 },
                        { 130, 40,  240 },
                        { 210, 130, 255 },
                        { 5,   10,  30  }
                    };

                    double mag = sqrt(zx * zx + zy * zy);
                    double nu = log(log(mag) / log(2.0)) / log(2.0);
                    double smooth_iters = (double)iters + 1.0 - nu;

                    double mu = smooth_iters / 50.0; 
                    int color1_idx = ((int)mu) % NUM_COLORS;
                    int color2_idx = (color1_idx + 1) % NUM_COLORS;
                    double t = mu - (int)mu;

                    totalR += bgp_palette[color1_idx][0] + t * (bgp_palette[color2_idx][0] - bgp_palette[color1_idx][0]);
                    totalG += bgp_palette[color1_idx][1] + t * (bgp_palette[color2_idx][1] - bgp_palette[color1_idx][1]);
                    totalB += bgp_palette[color1_idx][2] + t * (bgp_palette[color2_idx][2] - bgp_palette[color1_idx][2]);
                }
            }
        }

        data[pixel_index]     = (unsigned char)(totalR / 4.0);
        data[pixel_index + 1] = (unsigned char)(totalG / 4.0);
        data[pixel_index + 2] = (unsigned char)(totalB / 4.0);
    }
}

void savePPM(const char* filename, unsigned char* data, size_t bytes) {
    ofstream img(filename, ios::out | ios::binary);
    img << "P6\n" << WIDTH << " " << HEIGHT << "\n255\n";
    img.write(reinterpret_cast<char*>(data), bytes);
    img.close();
    cout << "Successfully saved: " << filename << endl;
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

    // Target Focus Coordinates (Seahorse Valley close-up)
    double cameraX = -0.743643887037151;
    double cameraY = 0.131825904205330;
    double cameraZoom = 0.002;

    // --- RUN 1: Generate Aliased Baseline ---
    cout << "Rendering un-optimized frame..." << endl;
    mandelbrotKernel<<<gridSize, blockSize>>>(d_data, WIDTH, HEIGHT, cameraX, cameraY, cameraZoom, false);
    cudaDeviceSynchronize();
    cudaMemcpy(data, d_data, bytes, cudaMemcpyDeviceToHost);
    savePPM("before.ppm", data, bytes);

    // --- RUN 2: Generate Anti-Aliased Smooth Frame ---
    cout << "Rendering optimized smooth SSAA frame..." << endl;
    mandelbrotKernel<<<gridSize, blockSize>>>(d_data, WIDTH, HEIGHT, cameraX, cameraY, cameraZoom, true);
    cudaDeviceSynchronize();
    cudaMemcpy(data, d_data, bytes, cudaMemcpyDeviceToHost);
    savePPM("after.ppm", data, bytes);

    delete[] data;
    cudaFree(d_data);
    
    cout << "\nAll processing loops completed cleanly!" << endl;
    return 0;
}