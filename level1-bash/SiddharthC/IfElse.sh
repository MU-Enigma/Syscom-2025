# if_else.sh

read -p "Enter a number: " num
if [[ "$num" -gt 0 ]]; then
echo "$num is positive"
elif [[ "$num" -lt 0 ]]; then
echo "$num is negative"
else
echo "$num is zero"
fi
