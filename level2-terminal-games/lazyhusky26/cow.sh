#!/bin/bash

read -p "Type something: " input

if [ "$input" = "cow" ]; then
    cat << "EOF"
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
EOF
else
    echo "Nothing happens."
fi
