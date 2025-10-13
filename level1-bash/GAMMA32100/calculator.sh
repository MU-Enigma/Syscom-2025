echo "Enter first number:"
read a

echo "Enter operation (+, -, *, /):"
read o

echo "Enter second number:"
read b

result=$(echo "$a $o $b" | bc -l)

echo "Result: $result"