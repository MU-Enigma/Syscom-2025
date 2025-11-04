#!/bin/bash
# Loop example

echo "Counting from 1 to 5:"
for i in {1..5}
do
    echo "Number $i"
done

echo "Now using a while loop:"
count=1
while [ $count -le 5 ]
do
    echo "Count is $count"
    ((count++))
done
