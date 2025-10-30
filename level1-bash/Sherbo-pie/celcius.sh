#!/bin/bash

echo "Enter temp in Celsius:"
read a

f=$((a * 9 / 5 + 32))
echo "Temp in Fahrenheit: $f"

