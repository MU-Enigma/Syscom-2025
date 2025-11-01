#!/bin/bash


# Define moods and corresponding colors
declare -A moods
moods=( 
    ["Happy"]="\033[1;33m"   # Yellow
    ["Sad"]="\033[1;34m"     # Blue
    ["Excited"]="\033[1;35m" # Magenta
    ["Angry"]="\033[1;31m"   # Red
    ["Relaxed"]="\033[1;32m" # Green
)

echo "🎨 Terminal Mood Light"
echo "Choose your mood from the list below:"
select mood in "${!moods[@]}" "Exit"; do
    if [[ "$mood" == "Exit" ]]; then
        echo -e "\033[0m Goodbye! 👋"
        break
    elif [[ -n "${moods[$mood]}" ]]; then
        color=${moods[$mood]}
        clear
        echo -e "${color}Your terminal reflects your mood: $mood\033[0m"
        echo -e "${color}Have a great day! 🌟\033[0m"
    else
        echo "❌ Invalid choice."
    fi
    echo ""
done
