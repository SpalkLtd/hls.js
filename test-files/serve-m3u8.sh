#!/bin/bash

# Check if http-server is installed
if ! command -v http-server &> /dev/null
then
    echo "http-server not found. Installing..."
    npm install -g http-server
fi

# Check if a directory was provided as an argument
if [ -z "$1" ]
then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Navigate to the specified directory
cd "$1" || {
    echo "Directory not found: $1"
    exit 1
}

# Start http-server
echo "Starting http-server in $(pwd)"
http-server

// http://127.0.0.1:8083/53a03e82-3e48-4053-8be8-de53326459fa.m3u8
