# Shell Script Examples

This repository contains a set of shell scripts demonstrating various operations and tasks.

```bash
#! /bin/bash

# Prompt the user for their name
echo "Enter your name:"
read name

# Display a greeting with the entered name
echo "Hello, $name! Nice to meet you :)"

```

Result from the above script:

![Image_Alt](https://github.com/tochinicky/dareyGit/assets/29289689/974c9ddf-7d2d-4d82-8097-d509a2ebac06)

# Directory Manipulation and Navigation

```bash

#!/bin/bash

#Display current directory
echo "Current directory: $PWD"

# Create a new directory
echo "Creating a new directory."
mkdir my_directory
echo "New directory created."

# Change to the new directory
echo "Changing to the new directory..."
cd my_directory
echo "Current directory: $PWD"

# Create some files
echo "Creating files.."
touch file1.txt
touch file2.txt
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
echo "Directory removed."

# List the files in the current directory
echo "Files in the current directory:"
ls

```

Result from the above script

![Image_Alt](https://github.com/tochinicky/dareyGit/assets/29289689/eaa31bc4-50a8-4ce7-a33a-30377b89f695)

# File Operation and Sorting

```bash

#!/bin/bash

# Create three files
echo "Creating files..."
echo "This is file3." > file3.txt
echo "This is file1." > file1.txt
echo "This is file2." > file2.txt
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
echo "Final sorted file:"
cat sorted_files_sorted_alphabetically.txt

```

Result from the above script:

![Image_Alt](https://github.com/tochinicky/dareyGit/assets/29289689/9c23b469-2e9b-4e18-8664-3e00e88360de)

# Working with Numbers and Calculations

```bash

#!/bin/bash

# Define two variables with numeric values
read -p "Enter your first number: " num1
read -p "Enter your second number: " num2

echo "Calculating some numerical operations. Please hold on..."
sleep 5

# Perform basic arithmetic operations
sum=$((num1 + num2))
difference=$((num1 - num2))
product=$((num1 * num2))
quotient=$((num1 / num2))
remainder=$((num1 % num2))

# Display the results
echo "Number 1: $num1"
echo "Number 2: $num2"
echo "Sum: $sum"
echo "Difference: $difference"
echo "Product: $product"
echo "Quotient: $quotient"
echo "Remainder: $remainder"

# Perform some more complex calculations
power_of_2=$((num1 ** 2))
square_root=$(awk "BEGIN { printf \"%.2f\", sqrt($num2) }")

# Display the results
echo "Number 1 raised to the power of 2: $power_of_2"
echo "Square root of number 2: $square_root"

```

Result from the above script:

![Image_Alt](https://github.com/tochinicky/dareyGit/assets/29289689/d6307bfd-2ea4-4083-abc1-ef35fc90a9ae)

# File Backup and Timestamping

```bash

#!/bin/bash

# Define the source directory and backup directory
source_dir="/Users/user/shell-scripting"
backup_dir="/Users/user/shell-scripting"

# Create a timestamp with the current date and time
timestamp=$(date +"%Y%m%d%H%M%S")

# Create a backup directory with the timestamp
backup_dir_with_timestamp="$backup_dir/backup_$timestamp"

# Create the backup directory
mkdir -p "$backup_dir_with_timestamp"

# Copy all files from the source directory to the backup directory
cp -r "$source_dir"/* "$backup_dir_with_timestamp"

# Display a message indicating the backup process is complete
echo "Backup completed. Files copied to: $backup_dir_with_timestamp"

```

Result from the above script:

![Image_Alt](https://github.com/tochinicky/dareyGit/assets/29289689/801933e4-8fbf-41cc-9b9e-bc0ef67ae299)
