#!/bin/bash
# Fake OS Boot Simulator (No emojis)

# Function to print with typing effect
type_print() {
    local msg="$1"
    local delay="${2:-0.05}"
    for ((i=0; i<${#msg}; i++)); do
        echo -n "${msg:$i:1}"
        sleep "$delay"
    done
    echo
}

# Function to print loading bar
loading_bar() {
    local duration=$1
    echo -n "["
    for ((i=0; i<20; i++)); do
        echo -n "#"
        sleep $(echo "$duration/20" | bc -l)
    done
    echo "] Done!"
}

# Clear screen
clear

# Boot sequence
echo -e "\e[32mBooting FakeOS...\e[0m"
sleep 1

type_print "Checking CPU..." 0.05
loading_bar 1
type_print "CPU OK"

type_print "Checking RAM..." 0.05
loading_bar 1
type_print "RAM OK"

type_print "Checking storage devices..." 0.05
loading_bar 1
type_print "Storage OK"

type_print "Loading kernel..." 0.05
sleep 1
type_print "Kernel loaded successfully"

type_print "Starting system services..." 0.05
loading_bar 2
type_print "All services started"

# Optional fake error message for realism
if ((RANDOM % 2)); then
    type_print "Warning: Network adapter not detected, using fallback..." 0.05
else
    type_print "Network adapter initialized successfully"
fi

# Boot complete
type_print "System ready! Welcome to FakeOS"
echo
echo "Type 'help' to see commands or 'exit' to shutdown."
