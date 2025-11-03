#!/bin/bash
# 💻 Hacker Typer Game v2
# - Printed text is green
# - User keystrokes are not echoed (hidden)
# - Q/q quits; Ctrl+C handled cleanly

GREEN="\033[32m"
RESET="\033[0m"
LINES=(
  "[+] Initializing kernel modules..."
  "[+] Bypassing firewall..."
  "[+] Accessing root privileges..."
  "[+] Uploading payload..."
  "[+] Downloading confidential data..."
  "[+] Encrypting local system..."
  "[+] Access Granted ✅"
  "[+] Opening secure channel..."
  "[+] Spawning reverse shell..."
  "[+] Dumping logs..."
)

cleanup() {
  tput cnorm    # restore cursor
  stty sane     # restore terminal settings (echo on)
  echo -e "${RESET}\nSession ended."
  exit
}
trap cleanup INT TERM EXIT

clear
tput civis              # hide cursor
stty -echo              # turn off echo (extra safety)
echo -e "${GREEN}💀 Welcome to Hacker Typer v2 💀${RESET}"
echo -e "${GREEN}Start typing... (press Q to quit)${RESET}"
echo

# Main loop: read single key silently and print green lines
while true; do
  # read single key silently (-s), no newline (-n1)
  IFS= read -rsn1 key

  # Quit on Q/q
  if [[ "$key" == "Q" || "$key" == "q" ]]; then
    break
  fi

  # If user pressed Enter, print a newline (kept invisible to the user)
  # but most keys just trigger printing a random "hacker" line
  if [[ -z "$key" ]]; then
    echo
    continue
  fi

  # Print a random line in green. Use a small typewriter effect.
  line="${LINES[$((RANDOM % ${#LINES[@]}))]}"
  printf "${GREEN}"
  for ((i=0; i<${#line}; i++)); do
    printf "%s" "${line:i:1}"
    # short delay for effect; tweak or remove if you want faster output
    sleep 0.003
  done
  printf "${RESET}\n"

  # small pause so output isn't instant spam; reduce for faster printing
  sleep 0.04
done

cleanup
