#!/bin/bash

# Define two variables with numeric values
read -p "Enter your first number: " num1
read -p "Enter your second number: " num2

echo "calaulating some numerical operations. Please hold on... "
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