#bash script for if- else conditions
echo "Enter a number: "
read num
if [ $num -gt 10 ]
then
    echo "$num is greater than 10"
else
    echo "$num is less than or equal to 10"
fi

read -p "Press Enter to close..."