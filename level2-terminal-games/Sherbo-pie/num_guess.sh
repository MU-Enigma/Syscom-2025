#!/bin/bash

secret=$((RANDOM % 100 +1))
guess=0
while [ "$guess" -ne "$secret" ]; do
     echo "Guess the number(1-100) : "
     read guess

     if [ "$guess" -lt "$secret" ]; then
         echo "Your Guess is too low!"
     elif [ "$guess" -gt "$secret" ]; then
         echo "Your Guess is too high!"
     elif [ "$guess" -eq "$secret" ]; then
         echo "Congratulations! You Guessed it!"
     else
         echo "Invalid input"
     fi
done


