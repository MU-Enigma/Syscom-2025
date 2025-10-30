echo "enter first number"
read number1
echo "enter second number"
read number2
echo "enter operator (+ - * /)"
read operator
case $operator in
    '+') result=$((number1 + number2)) ;;
    '-') result=$((number1 - number2)) ;;
    '*') result=$((number1 * number2)) ;;
    '/') result=$((number1 / number2));;
esac
echo "Result: $result"