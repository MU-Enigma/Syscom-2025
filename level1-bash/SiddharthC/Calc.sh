# calculator.sh


read -p "Enter first number: " a
read -p "Enter second number: " b


echo "Operations: 1)add 2)sub 3)mul 4)div"
read -p "Choose operation (1-4): " op


case "$op" in
1)
result=$((a + b))
echo "Result: $result";;
2)
result=$((a - b))
echo "Result: $result";;
3)
result=$((a * b))
echo "Result: $result";;
4)
if [[ "$b" -eq 0 ]]; then
echo "Cannot divide by zero"
else
result=$((a / b))
echo "Result: $result"
fi;;
*)
echo "Invalid option";;
esac
