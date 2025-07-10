import time
import sys
import os

# Simulate data for a specified duration (in seconds)
def simulate_data(duration):
    start_time = time.time()
    time_elapsed = 0.0

    while time_elapsed < duration:
        # Calculate dummy data based on time_elapsed
        # Speed: 100 + ((time < 5 || time > 10) ? time : -time) * 10
        speed = 100 + (time_elapsed if (time_elapsed < 5 or time_elapsed > 10) else -time_elapsed) * 10
        # Current: 1.0 + time * 0.1
        current = 1.0 + time_elapsed * 0.1
        # Temperature: 20.0 + time * 0.5
        temp = 20.0 + time_elapsed * 0.5

        # Write data to /tmp/motor_data.txt
        try:
            with open('./tmp/motor_data.txt', 'w') as f:
                f.write(f"{speed},{current},{temp}\n")
        except Exception as e:
            print(f"Error writing to file: {e}")

        # Increment time and sleep for 0.5 seconds
        time.sleep(0.5)
        time_elapsed = time.time() - start_time
        print(f"value of Speed: {speed}")

if __name__ == "__main__":
    # Default duration is 60 seconds unless specified
    duration = float(sys.argv[1]) if len(sys.argv) > 1 else 60.0
    print(f"Simulating data for {duration} seconds...")
    simulate_data(duration)
    print("Simulation complete.")