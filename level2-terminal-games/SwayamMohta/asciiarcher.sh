#!/usr/bin/env bash
# ascii_archer.sh
# Robust ASCII Archer: press SPACE or ENTER to shoot when the moving target (O) is above the archer (^)
# Works well in Linux, WSL, Git Bash. If using PowerShell, run: bash ascii_archer.sh

# --- Config ---
WIDTH=31              # width of play field (odd recommended so archer is centered)
CENTER=$((WIDTH/2))
POS=0                 # target position (will move)
DIR=1                 # target direction
SCORE=0
MISS=0
MAX_MISS=3
TICK=0.08             # seconds per frame (smaller => faster)

# Ensure proper terminal mode and restore on exit
cleanup() {
  stty "$STTY_ORIG"
  tput cnorm   # show cursor
  printf "\n"
}
trap cleanup EXIT

# Save current stty and set raw mode for single key reads
STTY_ORIG=$(stty -g)
stty -echo -icanon time 0 min 0
tput civis    # hide cursor

# draw one frame
draw_frame() {
  clear
  # top line (target row)
  for ((i=0; i<WIDTH; i++)); do
    if (( i == POS )); then printf "O"; else printf "-"; fi
  done
  printf "\n"
  # archer line
  for ((i=0; i<WIDTH; i++)); do
    if (( i == CENTER )); then printf "^"; else printf " "; fi
  done
  printf "\n"
  printf "Score: %d   Misses: %d / %d\n" "$SCORE" "$MISS" "$MAX_MISS"
  printf "Press SPACE or ENTER to shoot. Ctrl+C to quit.\n"
}

# shoot logic: only called when a real key is read (space or newline)
shoot() {
  if (( POS == CENTER )); then
    SCORE=$((SCORE + 1))
    echo "Hit!"
  else
    MISS=$((MISS + 1))
    echo "Miss!"
  fi
  # brief pause to show result
  sleep 0.35
}

# Main loop
# We'll use dd to read 1 byte non-blocking reliably across many environments,
# but fallback to read if dd not available. Using stty above makes read -n1 non-blocking too.
USE_DD=1
if ! command -v dd >/dev/null 2>&1; then
  USE_DD=0
fi

while (( MISS < MAX_MISS )); do
  draw_frame

  # Try reading one byte non-blocking
  key=""
  if (( USE_DD )); then
    # dd with timeout: read 1 byte if available, otherwise returns quickly
    # bs=1 count=1 status=none to suppress output messages
    IFS= read -r -n1 -t "$TICK" key 2>/dev/null || true
  else
    # fallback: read with timeout (may be slightly less precise)
    IFS= read -r -n1 -t "$TICK" key 2>/dev/null || true
  fi

  # If key is not empty, process it
  if [[ -n "$key" ]]; then
    # Enter can come as $'\n' or $'\r' depending on environment
    if [[ "$key" == " " || "$key" == $'\n' || "$key" == $'\r' ]]; then
      shoot
    fi
    # If other keys pressed, ignore them
  fi

  # Move target after processing input
  POS=$((POS + DIR))
  if (( POS <= 0 )); then
    POS=0
    DIR=1
  elif (( POS >= WIDTH-1 )); then
    POS=$((WIDTH-1))
    DIR=-1
  fi
done

# End game
clear
echo "====================="
echo "      GAME OVER      "
echo "====================="
echo "Final Score: $SCORE"
echo "Misses: $MISS / $MAX_MISS"
