#!/bin/bash

echo "bread"

while true; do
    read -p "> " input
    if [ "$input" == "bread" ]; then
        echo "bread"
    fi
done
