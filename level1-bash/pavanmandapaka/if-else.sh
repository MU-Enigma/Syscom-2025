echo "Enter age: "

read age

if [ $age -lt 18 ] ; 
then
  echo "You are a minor"
else
  echo "You are an adult"
fi
