#!/bin/bash

#Display current directory
echo "Current directory: $PWD"

# Create a new directory
echo "Creating a new directors."
mkdir my_directory
echo "New directory created."

# Change to the new directory

echo "Changing to the new directory..."
cd my_directory
echo "Current directory: $PWD"
# Create some files
echo "Creating files.."
touch file1.txt touch file2.txt
echo "Files created."

# List the files in the current directory
echo "Files in the current directory: "
ls
# Move one level up
echo "Moving one level up."
cd ..
echo "Current directory: $PWD"

# Remove the new directory and its contents
echo "Removing the new directory.."
rm -rf my_directory
echo "Directory removed"

# List the files in the current directory
echo "Files in the current directory:"
ls