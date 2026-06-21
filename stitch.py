from PIL import Image, ImageDraw

def create_split_screen():
    print("Loading 4K raw renders...")
    # Load the raw binary PPM files
    img_before = Image.open("before.ppm").convert("RGB")
    img_after = Image.open("after.ppm").convert("RGB")

    width, height = img_before.size

    # Create a new blank canvas for the final image
    final_img = Image.new('RGB', (width, height))

    print("Cropping and stitching...")
    # Crop left half of 'before', right half of 'after'
    left_half = img_before.crop((0, 0, width // 2, height))
    right_half = img_after.crop((width // 2, 0, width, height))

    # Paste them onto the final canvas
    final_img.paste(left_half, (0, 0))
    final_img.paste(right_half, (width // 2, 0))

    # Draw a crisp white divider line down the exact center
    draw = ImageDraw.Draw(final_img)
    line_thickness = 8
    draw.line([(width // 2, 0), (width // 2, height)], fill="white", width=line_thickness)

    print("Compressing and saving to JPG...")
    # Save as a highly compressed JPG suitable for a web portfolio
    final_img.save("mandelbrot_portfolio.jpg", "JPEG", quality=90)
    print("Done! Portfolio asset generated.")

if __name__ == "__main__":
    create_split_screen()