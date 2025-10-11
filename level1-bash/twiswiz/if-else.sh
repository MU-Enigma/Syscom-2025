#!/bin/bash
echo "Enter a number: "
read num
if [ "$num" -le 10 ]; then
	echo "Thats 10 or less!"
else
	echo "Thats more than 10"
fi
