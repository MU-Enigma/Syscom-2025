#!/bin/bash
echo "Celsius to Fahrenheit Converter"
echo "Enter temperature in Celsius:"
read c
f=$(echo "scale=2; ($c * 9/5) + 32" | bc)
echo "$c°C = $f°F"