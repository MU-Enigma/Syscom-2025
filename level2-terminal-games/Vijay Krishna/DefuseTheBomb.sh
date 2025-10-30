#!/bin/bash

echo "OH NO! A BOMB! QUICK!"
echo "It has 3 wires:"
echo "A [red] wire, a [yellow] wire, and a [blue] wire."
echo ""
echo "Which wire do you cut? (red/yellow/blue):"
read wire_choice

# Define the wires in an array
wires=("red" "yellow" "blue")

# Pick a random wire to be the "safe" one
safe_wire_index=$((RANDOM % 3))
safe_wire=${wires[$safe_wire_index]}

echo ""

if [ "$wire_choice" == "$safe_wire" ]; then
    echo "SNAP! The bomb is defused!"
    echo "You did it! You saved the day!"
else
    # This happens if the wire check failed
    echo "BZZZZT! WRONG WIRE! KABOOM!"
    echo "You Died, Game Over."
    echo "The safe wire was the $safe_wire one."
fi

read -p "Press [Enter] to exit the Defuse The Bomb game."