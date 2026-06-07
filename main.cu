// main.cpp
//
#include <iostream>
#include <fstream>
using namespace std;

const int WIDTH = 1200;
const int HEIGHT = 900;

int main()
{
    ofstream img("mandelbrot.ppm");

    cout << "Generating Mandelbrot Set" << endl;

    img << "P3\n" << WIDTH << " " << HEIGHT << "\n255\n";

    for (int y = 0; y < HEIGHT; ++y)
    {
        for (int x = 0; x < WIDTH; ++x)
        {
            double zx, zy, cX, cY;
            int iters = 0;
            zx = zy = 0;
            cX = (-2.0 + ((double)x / WIDTH) * 3.0);
            cY = (-1.5 + ((double)y / HEIGHT) * 3.0);

            while ((zx * zx) + (zy * zy) < 4.0 && iters < 1000)
            {
                double curr = zx * zx - zy * zy + cX;
                zy = 2 * zx * zy + cY;
                zx = curr;
                ++iters;
            }
            
            if (iters == 1000) {
                img << "0 0 0\n"; // Black for points in the set
            } else {
                int r = (iters * 5) % 256;
                int g = (iters * 2) % 256;
                int b = (iters * 11) % 256;
                img << r << " " << g << " " << b << "\n";
            }
                
        }
    }

    img.close();
    cout << "Done! Saved to mandelbrot.ppm" << endl;

    return 0;
}