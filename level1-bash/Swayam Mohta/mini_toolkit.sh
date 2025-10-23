#!/bin/bash

while true; do
  clear
  echo "=============================="
  echo "     MINI BASH TOOLKIT"
  echo "=============================="
  echo "1. System Info"
  echo "2. Random Quote"
  echo "3. Roll a Dice"
  echo "4. Countdown Timer"
  echo "5. Exit"
  echo
  read -p "Enter your choice [1-5]: " choice

  case $choice in
    1)
      echo "--- System Information ---"
      echo "Hostname: $(hostname)"
      if command -v df &>/dev/null; then
        echo "Disk Usage:"
        df -h
      else
        echo "Disk info unavailable on this shell."
      fi
      ;;
    2)
      echo "Quote of the Day:"
      quotes=("Dream big, code bigger."
              "Stay curious, keep learning."
              "Simplicity is the soul of efficiency."
              "Debugging is like being the detective in a crime movie where you are also the murderer.")
      echo "\"${quotes[$RANDOM % ${#quotes[@]}]}\""
      ;;
    3)
      echo "Rolling the dice..."
      roll=$((RANDOM % 6 + 1))
      echo "You got: $roll"
      ;;
    4)
      read -p "Enter countdown time in seconds: " seconds
      echo "Starting timer for $seconds seconds..."
      while [ $seconds -gt 0 ]; do
        echo -ne "\rTime remaining: $seconds seconds "
        sleep 1
        ((seconds--))
      done
      echo -e "\nTime's up!"
      ;;
    5)
      echo "Goodbye"
      exit 0
      ;;
    *)
      echo "Invalid choice. Try again."
      ;;
  esac

  echo
  read -p "Press Enter to continue..."
done
