# loops.sh

echo "For loop from 1 to 5"
for i in {1..5}; do
echo "Number: $i"
done

echo "\nWhile loop from 5 to 1"
count=5
while [[ $count -gt 0 ]]; do
echo "Countdown: $count"
((count--))
done
