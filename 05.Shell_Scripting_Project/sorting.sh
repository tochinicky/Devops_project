#!/bin/bash

# Create three files
echo "Creating files..."
echo "This is file3.txt" > file3.txt echo "This is file." > file1.txt 
echo "This is file2.txt" > file2.txt 
echo "Files created."
# Display the files in their current order
echo "Files in their current order:" 
ls
# Sort the files alphabetically
echo "Sorting files alphabetically.."
ls | sort > sorted_files.txt
echo "Files sorted."

# Display the sorted files
echo "Sorted files:" 
cat sorted_files.txt

# Remove the original files
echo "Removing original files..." 
rm file1.txt file2.txt file3.txt 
echo "Original files removed."

# Rename the sorted file to a more descriptive name
echo "Renaming sorted file..."
mv sorted_files.txt sorted_files_sorted_alphabetically.txt 
echo "File renamed."

# Display the final sorted file
echo "Final sorted file;"
cat sorted_files_sorted_alphabetically.txt