#!/bin/bash

# Store the script name
script_name=$(basename "$0")

# Initialize a variable to keep the total count of lines
total_lines=0

# Loop through all files in the current directory
for file in *; do
    # Skip the script itself
    if [ "$file" = "$script_name" ]; then
        continue
    fi

    # Ensure it's a regular file
    if [ -f "$file" ]; then
        # Count the lines in the file
        lines=$(wc -l < "$file")
        echo "$file: $lines"
        # Add the number of lines to the total
        total_lines=$((total_lines + lines))
    fi
done

# Print the total number of lines
echo "Total lines in directory: $total_lines"
