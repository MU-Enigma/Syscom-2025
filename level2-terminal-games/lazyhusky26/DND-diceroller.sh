#!/bin/bash

echo "Rolling the dice..."
roll=$((RANDOM % 20 + 1))
echo "You rolled $roll!"