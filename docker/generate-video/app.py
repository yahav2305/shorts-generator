import os
import cv2
import numpy as np
import random
import math

def generate_looping_video():
    # 1. Configuration & Environment Variable
    duration_seconds = int(os.environ.get("VIDEO_LENGTH_SECONDS", 60))

    WIDTH, HEIGHT = 1080, 1920
    FPS = 60
    TOTAL_FRAMES = duration_seconds * FPS

    output_filename = os.environ.get("VIDEO_OUTPUT_DIR", '') + "/background_gameplay.mp4"
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_filename, fourcc, FPS, (WIDTH, HEIGHT))

    # 2. Game Constants
    player_y = HEIGHT - 350
    GAP_SIZE = 320         # Safe gap width
    OBSTACLE_SPEED = 18    # Downward speed
    SPAWN_RATE = 40        # Frames between spawns
    GRID_STEP = 100
    GRID_SPEED = 10        # Ensures (TOTAL_FRAMES * GRID_SPEED) % 100 == 0

    # Pre-calculate deterministic obstacle gap positions for the loop cycle
    spawn_frames = list(range(0, TOTAL_FRAMES, SPAWN_RATE))
    random.seed()
    gap_positions = [random.randint(100, WIDTH - GAP_SIZE - 100) for _ in spawn_frames]

    # Function to get obstacle positions at any arbitrary frame
    def get_obstacles_for_frame(frame_num):
        obstacles = []
        for i, spawn_f in enumerate(spawn_frames):
            # Calculate cyclic age of obstacle
            if frame_num >= spawn_f:
                age = frame_num - spawn_f
            else:
                age = frame_num + TOTAL_FRAMES - spawn_f

            y_pos = age * OBSTACLE_SPEED - 100
            if -100 <= y_pos <= HEIGHT + 100:
                obstacles.append({
                    'y': y_pos,
                    'gap_x': gap_positions[i]
                })
        # Sort obstacles from bottom to top
        obstacles.sort(key=lambda o: o['y'], reverse=True)
        return obstacles

    # 3. AI State & Pre-Simulation (Warm-up pass for seamless player state)
    player_x = WIDTH / 2
    trail = []

    print(f"Pre-simulating AI path for seamless looping state...")
    for frame_count in range(TOTAL_FRAMES):
        obstacles = get_obstacles_for_frame(frame_count)

        # AI Target Acquisition
        target_x = WIDTH / 2
        for obs in obstacles:
            if obs['y'] + 60 < player_y:
                target_x = obs['gap_x'] + (GAP_SIZE / 2)
                break

        player_x += (target_x - player_x) * 0.15
        trail.append((int(player_x), int(player_y + 30)))
        if len(trail) > 15:
            trail.pop(0)

    print(f"Rendering {duration_seconds}s video ({TOTAL_FRAMES} frames)...")

    # 4. Render & Record Loop
    for frame_count in range(TOTAL_FRAMES):
        frame = np.full((HEIGHT, WIDTH, 3), (15, 10, 15), dtype=np.uint8)

        # --- Harmonized Synthwave Grid (Seamless Loop) ---
        grid_color = (40, 25, 30)
        offset = (frame_count * GRID_SPEED) % GRID_STEP

        for y in range(offset, HEIGHT, GRID_STEP):
            cv2.line(frame, (0, y), (WIDTH, y), grid_color, 2)
        for x in range(0, WIDTH, GRID_STEP):
            cv2.line(frame, (x, 0), (x, HEIGHT), grid_color, 2)

        # --- Obstacles ---
        obstacles = get_obstacles_for_frame(frame_count)

        # Harmonic Color Phase (0 to 2*PI across video duration)
        color_phase = (2 * math.pi * frame_count) / TOTAL_FRAMES
        r = int(127 * math.sin(color_phase) + 128)
        b = int(127 * math.cos(color_phase) + 128)
        obs_color = (b, 100, r)

        for obs in obstacles:
            # Draw Left Block
            cv2.rectangle(frame, (0, int(obs['y'])),
                          (int(obs['gap_x']), int(obs['y'] + 60)),
                          obs_color, -1)
            # Draw Right Block
            cv2.rectangle(frame, (int(obs['gap_x'] + GAP_SIZE), int(obs['y'])),
                          (WIDTH, int(obs['y'] + 60)),
                          obs_color, -1)

        # --- AI Movement Update ---
        target_x = WIDTH / 2
        for obs in obstacles:
            if obs['y'] + 60 < player_y:
                target_x = obs['gap_x'] + (GAP_SIZE / 2)
                break

        player_x += (target_x - player_x) * 0.15

        # --- Player Trail ---
        trail.append((int(player_x), int(player_y + 30)))
        if len(trail) > 15:
            trail.pop(0)

        for i, (tx, ty) in enumerate(trail):
            size = int((i / 15.0) * 15)
            cv2.circle(frame, (tx, ty + (15 - i)*5), size, (255, 150, 0), -1)

        # --- Spaceship ---
        px, py = int(player_x), int(player_y)
        ship_pts = np.array([
            [px, py - 40],
            [px - 35, py + 30],
            [px - 15, py + 15],
            [px + 15, py + 15],
            [px + 35, py + 30]
        ])
        cv2.fillPoly(frame, [ship_pts], (255, 255, 0))

        out.write(frame)

        if frame_count % FPS == 0:
            print(f"Rendered {frame_count // FPS} / {duration_seconds} seconds")

    out.release()
    print(f"Done! Perfectly looping video saved to {output_filename}")

if __name__ == "__main__":
    generate_looping_video()