#!/bin/bash
# Fortune Teller Game

fortunes=(
    "You will have a great day "
    "Something unexpected will make you smile "
    "A challenge will reveal your strength "
    "Today is your lucky day "
    "You will meet someone interesting soon "
    "Be careful with your decisions today "
    "An opportunity is coming — don’t miss it "
)

while true; do
    echo "🔮 Welcome to the Fortune Teller!"
    read -p "Ask a yes/no question (or type 'quit' to exit): " question
    if [[ "$question" == "quit" ]]; then
        echo "Goodbye, seeker of truth "
        break
    fi
    sleep 1
    echo "Hmm... let me see into your future..."
    sleep 2
    echo "${fortunes[$((RANDOM % ${#fortunes[@]}))]}"
    echo ""
done
