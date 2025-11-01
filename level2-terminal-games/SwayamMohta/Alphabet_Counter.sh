#!/bin/bash
read -p "Enter a string: " input
echo "The string contains $(echo $input | tr -cd 'a-zA-Z' | wc -c) alphabet characters."
