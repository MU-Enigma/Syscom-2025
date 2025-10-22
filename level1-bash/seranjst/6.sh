#!/bin/bash

NUM1=10
NUM2=3

echo "--- Math ---"

echo "Add: $((NUM1 + NUM2))"
echo "Sub: $((NUM1 - NUM2))"
echo "Mul: $((NUM1 * NUM2))"
echo "Div: $((NUM1 / NUM2))"
echo "Rem: $((NUM1 % NUM2))"

echo "--- Float ---"

echo "scale=3; $NUM1 / $NUM2" | bc