import argparse
from PIL import Image

# Desired VGA resolution
TARGET_WIDTH = 320
TARGET_HEIGHT = 240

def load_image(path) -> Image:
    im = Image.open(path).convert("RGB")
    return im.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.LANCZOS)

def generate_coe(image: Image, output_file, preview: bool) -> None:
    if preview:
        # Create output image for preview
        prev_image = Image.new("RGB", (TARGET_WIDTH, TARGET_HEIGHT))
        preview_pixels = prev_image.load()

    with open(output_file, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")

        total_pixels = TARGET_WIDTH * TARGET_HEIGHT
        pixel_index = 0

        for y in range(TARGET_HEIGHT):
            for x in range(TARGET_WIDTH):
                r, g, b = image.getpixel((x, y))

                r4 = r >> 4
                g4 = g >> 4
                b4 = b >> 4

                value = f"{r4:X}{g4:X}{b4:X}"

                pixel_index += 1
                if pixel_index < total_pixels:
                    f.write(value + ",\n")
                else:
                    f.write(value + ";\n")

                # Preview reconstruction
                r8 = (r4 << 4) | r4
                g8 = (g4 << 4) | g4
                b8 = (b4 << 4) | b4
                if preview:
                    preview_pixels[x, y] = (r8, g8, b8)

    if preview:
        # Save preview image
        prev_image.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='Image to Memory', description='Converts a image (e.g. jpg) to a .coe file for BRAM.')
    parser.add_argument('filename', help='Input image file')
    parser.add_argument('-o', '--out', help='Output filename', default='image.coe')
    parser.add_argument('-p', '--preview', action='store_true', default=False)
    args = parser.parse_args()

    image = load_image(args.filename)
    generate_coe(image, args.out, args.preview)
