import cv2
import os

def extract_growth_stages(video_path, output_folder):
    # 1. Create the output folder (it will be created inside the 'Plant Video' folder)
    os.makedirs(output_folder, exist_ok=True)
    
    # 2. Load the video
    cap = cv2.VideoCapture(video_path)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    print(f"Loaded video. Total frames available: {total_frames}")
    
    if total_frames == 0:
        print("Error: Could not read video. Check if the file name is correct.")
        return

    # 3. Calculate the step size to get exactly 100 frames
    step = total_frames / 100.0
    
    print("Extracting 100 optimized WebP stages...")
    
    for i in range(100):
        # Calculate exactly which frame to pull
        frame_id = int(i * step)
        
        # Move to that specific frame
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_id)
        ret, frame = cap.read()
        
        if ret:
            # 4. Save as a compressed WebP image
            file_name = f"stage_{i + 1}.webp"
            output_path = os.path.join(output_folder, file_name)
            
            # Save with 85% quality
            cv2.imwrite(output_path, frame, [cv2.IMWRITE_WEBP_QUALITY, 85])
            print(f"Generated: {file_name}")
        else:
            print(f"Failed to grab frame {frame_id}")

    cap.release()
    print("\nSuccess! All 100 growth stages are ready.")

# Since you navigated to the folder in Step 1, the script only needs the file name
extract_growth_stages('mp_.mp4', 'growth_stages')