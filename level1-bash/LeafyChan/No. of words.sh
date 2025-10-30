#!/bin/bash
echo "Enter filename:"
read file
if [ ! -f "$file" ]; then
  echo "File not found!"
  exit 1
fi
wc -w < "$file"