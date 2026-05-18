import cv2
import os
import glob

# 1. Define folders
input_folder = "growth_stages"
output_folder = "growth_stages_cropped"

os.makedirs(output_folder, exist_ok=True)

# 2. Find all 100 WebP images
image_files = glob.glob(os.path.join(input_folder, "*.webp"))
print(f"Found {len(image_files)} images to crop...")

for file in image_files:
    # Read the image
    img = cv2.imread(file)
    if img is None:
        continue

    # Get the current dimensions
    height, width = img.shape[:2]

    # ==========================================
    # 3. YOUR EXACT CROP MEASUREMENTS
    # ==========================================
    y1 = 198               # Cuts exactly 198 pixels off the top
    y2 = height - 199      # Cuts exactly 199 pixels off the bottom
    x1 = 0                 # No cut on the left
    x2 = width             # No cut on the right
    
    # Apply the crop
    cropped_img = img[y1:y2, x1:x2]

    # 4. Save the new cropped image
    filename = os.path.basename(file)
    output_path = os.path.join(output_folder, filename)
    
    # Save as WebP keeping the 85% optimization
    cv2.imwrite(output_path, cropped_img, [cv2.IMWRITE_WEBP_QUALITY, 85])
    print(f"Perfectly cropped and saved: {filename}")

print("\nSuccess! All 100 images have been cropped to your exact specifications.")