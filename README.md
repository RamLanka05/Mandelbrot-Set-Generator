# Mandelbrot-Set-Generator
A Mandelbrot set generator built to explore parallel processing and CUDA concepts.

## Overview
This project renders high-resolution images of the Mandelbrot set by mapping pixel coordinates to the complex plane and calculating the escape-time algorithm ($Z = Z^2 + C$). Originally prototyped on the CPU, the math and rendering pipelines have been fully ported to the GPU using the CUDA Toolkit to unlock massive performance gains and enable deep-zoom 4K rendering.

## Features
* **GPU Acceleration:** Replaces nested CPU loops with a fully parallelized CUDA kernel, allowing millions of pixels to be calculated simultaneously across GPU threads.
* **4K UHD Resolution:** Capable of generating ultra-high-definition (3840 x 2160) fractals in a fraction of a second.
* **Dynamic Camera System:** Implements an aspect-ratio-locked, mathematical camera system (`centerX`, `centerY`, `zoom`) to explore deep, specific fractal structures like Seahorse Valley.
* **Smooth Gradient Coloring:** Bypasses basic modulo coloring by utilizing a GPU-side linear interpolation (lerp) engine to calculate ultra-smooth transitions across custom, multi-stop RGB palettes. 
* **Optimized Binary I/O:** Utilizes the `P6` binary PPM image format and direct memory block writing (`reinterpret_cast`) to eliminate the massive CPU bottlenecks caused by ASCII text conversions.

## Tools needed to run program
* C++ Compiler (MSVC, GCC, or Clang)
* [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)
* A CUDA-capable NVIDIA GPU

## Usage

This project is compiled using the NVIDIA CUDA Compiler (`nvcc`).


1. Clone the repository and navigate to the project directory:
```bash
    git clone [https://github.com/yourusername/Mandelbrot-Set-Generator.git](https://github.com/yourusername/Mandelbrot-Set-Generator.git
    cd Mandelbrot-Set-Generator
```

2. Compile and run the CUDA source file:
```bash
    nvcc main.cu -o main.exe | .\main.exe
```

This command will output a mandelbrot.ppm file which will have the compiled mandelbrot set.

## Future Roadmap

* **Real-Time Interactive Viewer:** Transition from a static batch-renderer to a live, navigable application. By leveraging **GLFW** and **CUDA-OpenGL Interoperability**, the CUDA kernel will write pixel data directly to an OpenGL texture on the VRAM, bypassing the CPU entirely to enable 60+ FPS panning and deep-zooming.
* **Continuous Color Smoothing:** Upgrade the discrete integer escape loop to a fractional escape algorithm (normalized iteration count). Utilizing the logarithm of the complex magnitude will eliminate stepped color banding and produce mathematically seamless gradient transitions.
* **Supersampling Anti-Aliasing (SSAA):** Implement a sub-pixel sampling architecture within the CUDA kernel. By calculating and averaging multiple offset coordinates per pixel, the renderer will eliminate jagged artifacts and deliver ultra-crisp, textbook-quality image fidelity.

## Author

### Sathvik Ram Lanka

- **GitHub:** [@RamLanka05](https://github.com/RamLanka05)
- **LinkedIn:** [Sathvik Ram Lanka](https://www.linkedin.com/in/sathvik-r-lanka/)
- **Affiliation:** Statistics & Computer Science, University of Illinois Urbana-Champaign