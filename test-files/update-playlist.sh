#!/bin/bash

# Check if the input playlist file is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <input_playlist.m3u8>"
  exit 1
fi

input_playlist="$1"
output_playlist="updated_$input_playlist"

# Create a temporary directory to store the downloaded segments
temp_dir=$(mktemp -d)

# Function to clean up temporary directory on exit
cleanup() {
  rm -rf "$temp_dir"
}
trap cleanup EXIT

# Function to log errors
log_error() {
  echo "Error: $1" >> error_log.txt
}

# Read the input playlist file
while IFS= read -r line
do
  # Check if the line is an EXTINF line
  if [[ $line == \#EXTINF:* ]]; then
    # Read the next line which should be the URL
    read -r url

    # Generate a unique filename using a hash of the URL
    url_hash=$(echo -n "$url" | md5sum | cut -d ' ' -f 1)
    segment_file="$temp_dir/$url_hash.ts"

    # Use curl to download the segment to the temporary directory
    if ! curl -s -o "$segment_file" "$url"; then
      log_error "Failed to download $url"
      continue
    fi

    # Check if the file was downloaded correctly
    if [ ! -s "$segment_file" ]; then
      log_error "Empty file downloaded from $url"
      continue
    fi

    # Get the duration of the segment using ffprobe
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$segment_file" 2>>error_log.txt)

    # Check if ffprobe was successful
    if [ $? -ne 0 ]; then
      log_error "ffprobe failed for $segment_file"
      continue
    fi

    # Round the duration to three decimal places for EXTINF
    rounded_duration=$(printf "%.3f" "$duration")

    # Output the corrected EXTINF line and the URL to the new playlist file
    echo "#EXTINF:$rounded_duration," >> "$output_playlist"
    echo "$url" >> "$output_playlist"
  else
    # Copy non-EXTINF lines directly to the new playlist file
    echo "$line" >> "$output_playlist"
  fi
done < "$input_playlist"

echo "Updated playlist saved to $output_playlist"
