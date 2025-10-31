#!/bin/bash
read -p "Enter your password: " password
if [[ ${#password} -ge 8 && "$password" =~ [A-Z] && "$password" =~ [0-9] ]]; then
    echo "Password is strong!"
else
    echo "Password is weak. It should be at least 8 characters long, contain a number, and an uppercase letter."
fi
