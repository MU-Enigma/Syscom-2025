#!/bin/bash

# Wait for Enter to start the stopwatch
echo "Press Enter to start the stopwatch."
read -r  # Wait for Enter

# Start the stopwatch
start_time=$(date +%s)
echo "Stopwatch started. Press Enter again to stop."

# Wait for Enter again to stop the stopwatch
read -r  # Wait for Enter to stop the stopwatch

# Calculate elapsed time
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Display elapsed time
echo "Elapsed time: $elapsed_time seconds"
