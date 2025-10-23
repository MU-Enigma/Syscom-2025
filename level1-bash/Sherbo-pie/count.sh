#!/bin/bash

echo "Enter the filename:"
read file

if [ -f "$file" ]; then
      word_count=$(wc -w < "$file")
      echo "Number of words in $file: $word_count"
else
      echo "File not found!"
fi

