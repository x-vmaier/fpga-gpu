from PIL import Image

# Desired VGA resolution
TARGET_WIDTH = 320
TARGET_HEIGHT = 240

# Open original image
im = Image.open("image.jpg").convert("RGB")
im_resized = im.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.LANCZOS)

# Create output image for preview (after RGB444 quantization)
preview = Image.new("RGB", (TARGET_WIDTH, TARGET_HEIGHT))
preview_pixels = preview.load()

with open("image.coe", "w") as f:
    f.write("memory_initialization_radix=16;\n")
    f.write("memory_initialization_vector=\n")

    total_pixels = TARGET_WIDTH * TARGET_HEIGHT
    pixel_index = 0

    for y in range(TARGET_HEIGHT):
        for x in range(TARGET_WIDTH):
            r, g, b = im_resized.getpixel((x, y))

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
            preview_pixels[x, y] = (r8, g8, b8)

# Save preview image
preview.save("image_rgb444_preview.png")
preview.show()
