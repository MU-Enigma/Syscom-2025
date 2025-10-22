#!/bin/bash

FILE_TO_CHECK="test_file.txt"

echo "Checking..."

if [ -f "$FILE_TO_CHECK" ]; then
    echo "Found!"
    ls -l "$FILE_TO_CHECK"
else
    echo "Missing."
    touch "$FILE_TO_CHECK"
    echo "Made file."
fi