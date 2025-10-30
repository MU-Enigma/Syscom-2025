#!/bin/bash

# A simple calculator using user input and a case statement.

echo "Enter first number:"
read NUM1

echo "Enter second number:"
read NUM2

echo "Enter operation (+ - * /):"
read OPERATION

# The case statement checks the value of the OPERATION variable
# and runs the code corresponding to the matching pattern.
case $OPERATION in
  "+")
    RESULT=$((NUM1 + NUM2))
    ;;
  "-")
    RESULT=$((NUM1 - NUM2))
    ;;
  "*")
    # In bash, '*' is a special character (wildcard), so we must "escape" it
    # with a backslash (\) to treat it as a literal multiplication symbol.
    RESULT=$((NUM1 * NUM2))
    ;;
  "/")
    RESULT=$((NUM1 / NUM2))
    ;;
  *)
    # The *) pattern is a "default" case that runs if no other pattern matches.
    echo "Invalid operation."
    exit 1 # Exit the script with an error status
    ;;
esac # 'case' spelled backward ends the statement.

echo "Result: $RESULT"