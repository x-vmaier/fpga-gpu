from PIL import Image

# Desired VGA resolution
TARGET_WIDTH = 320
TARGET_HEIGHT = 240

# Open original image
im = Image.open("image.jpg").convert("RGB")

# Resize using high-quality resampling
im_resized = im.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.LANCZOS)

# Create output image for preview (after RGB444 quantization)
preview = Image.new("RGB", (TARGET_WIDTH, TARGET_HEIGHT))
preview_pixels = preview.load()

with open("image.hex", "w") as f:
    for y in range(TARGET_HEIGHT):
        for x in range(TARGET_WIDTH):
            r, g, b = im_resized.getpixel((x, y))

            # Quantize to 4 bits per channel
            r4 = r >> 4
            g4 = g >> 4
            b4 = b >> 4

            # Write HEX for FPGA
            f.write(f"{r4:X}{g4:X}{b4:X}\n")

            # Expand back to 8-bit for preview
            r8 = (r4 << 4) | r4
            g8 = (g4 << 4) | g4
            b8 = (b4 << 4) | b4

            preview_pixels[x, y] = (r8, g8, b8)

# Save preview image
preview.save("image_rgb444_preview.png")
preview.show()
