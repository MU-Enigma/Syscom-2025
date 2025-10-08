#!/bin/bash

# This script prompts the user for their name and then greets them.

# Display a prompt for the user.
echo "What’s your name?"

# The 'read' command pauses the script and waits for user input.
# Whatever the user types is stored in the variable 'USER_NAME'.
read USER_NAME

# Greet the user using the name they provided.
echo "Nice to meet you, $USER_NAME!"