#!/bin/bash

START_NUMBER=5

echo "Start..."

for i in $(seq $START_NUMBER -1 1); do
    echo "$i..."
    sleep 1
done

echo "Done."