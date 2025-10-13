echo "how old are u?"
read age
if [ $age -lt 18 ]
then
    echo "u r a minor,run from diddy" 
else
    echo "u r an adult,safe from diddy"
fi