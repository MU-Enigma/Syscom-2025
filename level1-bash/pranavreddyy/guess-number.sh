#!/bin/bash

# A simple number guessing game.

# 1. Generate a random number between 1 and 100.
#    $RANDOM gives a number from 0-32767.
#    The modulo (%) operator gives the remainder of a division.
#    So, ($RANDOM % 100) gives a number from 0-99. We add 1 to make it 1-100.
TARGET=$(( ($RANDOM % 100) + 1 ))

echo "I've picked a number between 1 and 100. Can you guess it?"

# 2. Start an infinite 'while' loop. We will exit it manually later.
while true; do
  # 3. Read the user's guess.
  read GUESS

  # 4. Check if the guess is correct.
  if [ "$GUESS" -eq "$TARGET" ]; then
    echo "You guessed it! The number was $TARGET."
    break # 'break' exits the loop.
  # 5. Check if the guess is too low.
  elif [ "$GUESS" -lt "$TARGET" ]; then
    echo "Too low! Try again."
  # 6. Otherwise, the guess must be too high.
  else
    echo "Too high! Try again."
  fi # End the if/elif/else statement
done # End the while loop