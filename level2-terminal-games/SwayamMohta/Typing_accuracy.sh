#!/bin/bash
phrase="Bash is fun"
echo "Type this: $phrase"
read -p "> " input
if [[ "$input" == "$phrase" ]]; then
  echo "Correct!"
else
  echo "Incorrect, try again."
fi
