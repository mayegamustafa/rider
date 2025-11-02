from PIL import Image
import os

# Define the sizes for different densities
DENSITIES = {
    'ldpi': 36,
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192
}

# Source image path
source_image = 'delivery.png'
base_path = 'android/app/src/main/res'

# Open and process the image
img = Image.open(source_image)
img = img.convert('RGBA')

# Create icons for each density
for density, size in DENSITIES.items():
    # Create the mipmap directory if it doesn't exist
    output_dir = os.path.join(base_path, f'mipmap-{density}')
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Resize and save the icon
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    output_path = os.path.join(output_dir, 'ic_launcher.png')
    resized.save(output_path)
    # Also save as round icon
    output_path = os.path.join(output_dir, 'ic_launcher_round.png')
    resized.save(output_path)
    print(f'Created icon for {density}: {size}x{size}')
