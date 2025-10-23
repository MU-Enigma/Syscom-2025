#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <filename> <mode>"
  echo "Mode: words | lines"
  exit 1
fi

file=$1
mode=$2

if [ ! -f "$file" ]; then
  echo "Error: File not found!"
  exit 1
fi

case $mode in
  words) count=$(wc -w < "$file"); echo "Word count: $count";;
  lines) count=$(wc -l < "$file"); echo "Line count: $count";;
  *) echo "Invalid mode! Use 'words' or 'lines'."; exit 1;;
esac

