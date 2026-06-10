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