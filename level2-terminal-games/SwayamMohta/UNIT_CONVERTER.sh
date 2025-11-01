#!/bin/bash
# ==========================================
#   UNIT CONVERTER TOOL
#   Author: <your GitHub username>
#   Description: Converts between temperature,
#                distance, and weight units.
# ==========================================

while true; do
    clear
    echo "============================="
    echo "      UNIT CONVERTER TOOL"
    echo "============================="
    echo "1) Celsius → Fahrenheit"
    echo "2) Fahrenheit → Celsius"
    echo "3) Kilometers → Miles"
    echo "4) Miles → Kilometers"
    echo "5) Kilograms → Pounds"
    echo "6) Pounds → Kilograms"
    echo "7) Exit"
    echo "============================="
    read -p "Enter your choice [1-7]: " choice

    case $choice in
        1)
            read -p "Enter temperature in Celsius: " c
            f=$(echo "scale=2; ($c * 9/5) + 32" | bc)
            echo "$c°C = $f°F"
            ;;
        2)
            read -p "Enter temperature in Fahrenheit: " f
            c=$(echo "scale=2; ($f - 32) * 5/9" | bc)
            echo "$f°F = $c°C"
            ;;
        3)
            read -p "Enter distance in Kilometers: " km
            miles=$(echo "scale=3; $km * 0.621371" | bc)
            echo "$km km = $miles miles"
            ;;
        4)
            read -p "Enter distance in Miles: " miles
            km=$(echo "scale=3; $miles / 0.621371" | bc)
            echo "$miles miles = $km km"
            ;;
        5)
            read -p "Enter weight in Kilograms: " kg
            lbs=$(echo "scale=3; $kg * 2.20462" | bc)
            echo "$kg kg = $lbs lbs"
            ;;
        6)
            read -p "Enter weight in Pounds: " lbs
            kg=$(echo "scale=3; $lbs / 2.20462" | bc)
            echo "$lbs lbs = $kg kg"
            ;;
        7)
            echo "Exiting... Goodbye 👋"
            break
            ;;
        *)
            echo "Invalid choice! Please enter a number between 1 and 7."
            ;;
    esac

    echo ""
    read -p "Press Enter to continue..."
done
