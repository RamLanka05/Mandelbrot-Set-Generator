// main.cpp
// 
#include <iostream>
#include <fstream>
using namespace std;

const int WIDTH = 800;
const int HEIGHT = 600;

int main() {
    ofstream img("mandelbrot.ppm");

    img << "P3\n" << WIDTH << " " << HEIGHT << "\n255\n";
    img.close();
    cout << "Done! Saved to mandelbrot.ppm" << endl;

    return 0;
}