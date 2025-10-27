
echo "Enter 1st number: "

read num1

echo "Enter 2nd number: "

read num2

echo "Enter operation (+ - * /): "

read op

case $op in

+)
    result=$((num1+num2))
    ;;
-)
    result=$((num1-num2))
    ;;
\*)
    result=$((num1*num2))
    ;;
/)
    result=$((num1/num2))
    ;;
*)
    echo "Invalid operator"
    exit 1
    ;;
esac
echo "Result: $result"