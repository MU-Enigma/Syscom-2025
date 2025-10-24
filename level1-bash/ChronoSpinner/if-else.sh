echo Enter a number

read num

if [ $num -lt 7 ]
then
    echo "$num is less than 10"
elif [ $num -eq 7 ]
then
    echo "The entered number is equal to 10"
else
    echo "$num is greater than 10"
fi