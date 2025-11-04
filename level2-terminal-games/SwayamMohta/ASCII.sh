#!/bin/bash
# 🎨 ASCII Art Maker v3 - Arrow Key Movement Drawing

width=30
height=15

# Initialize grid
for ((y=0; y<height; y++)); do
  for ((x=0; x<width; x++)); do
    grid[$((y*width+x))]="."
  done
done

cursor_x=0
cursor_y=0
draw_char="#"
draw_mode=0   # 0 = move, 1 = draw
colors=("\033[31m" "\033[32m" "\033[33m" "\033[34m" "\033[35m" "\033[36m")
reset="\033[0m"

draw_canvas() {
  tput cup 0 0
  echo "🎨 ASCII ART MAKER v3 | Arrow Keys: Move | SPACE: Toggle Draw | C: Clear | S: Save | Q: Quit"
  echo "──────────────────────────────────────────────────────────────"
  for ((y=0; y<height; y++)); do
    for ((x=0; x<width; x++)); do
      if [[ $x -eq $cursor_x && $y -eq $cursor_y ]]; then
        # highlight cursor
        echo -ne "\033[7m${grid[$((y*width+x))]}\033[0m"
      else
        echo -ne "${grid[$((y*width+x))]}"
      fi
    done
    echo
  done
  echo "──────────────────────────────────────────────────────────────"
  echo "Mode: $([[ $draw_mode -eq 1 ]] && echo '✏️ Drawing' || echo '🧭 Moving') | Char: '$draw_char'"
}

save_canvas() {
  filename="ascii_art_$(date +%H%M%S).txt"
  {
    echo "ASCII ART MAKER - Saved on $(date)"
    for ((y=0; y<height; y++)); do
      for ((x=0; x<width; x++)); do
        # remove escape colors before saving
        echo -n "$(echo -e "${grid[$((y*width+x))]}" | sed 's/\x1b\[[0-9;]*m//g')"
      done
      echo
    done
  } > "$filename"
  echo -e "\n✅ Saved as $filename"
  sleep 1
}

tput civis
clear

draw_canvas
while true; do
  IFS= read -rsn1 key
  case "$key" in
    $'\x1b')
      read -rsn2 -t 0.001 key
      case "$key" in
        "[A") ((cursor_y--));;
        "[B") ((cursor_y++));;
        "[C") ((cursor_x++));;
        "[D") ((cursor_x--));;
      esac ;;
    " ")
      ((draw_mode = 1 - draw_mode)) ;;  # toggle draw mode
    [Cc])
      for ((i=0; i<${#grid[@]}; i++)); do grid[$i]="."; done ;;
    [Ss])
      save_canvas ;;
    [Qq])
      tput cnorm
      clear
      echo "👋 Goodbye!"
      exit ;;
  esac

  # Keep cursor in bounds
  ((cursor_x < 0)) && cursor_x=0
  ((cursor_y < 0)) && cursor_y=0
  ((cursor_x >= width)) && cursor_x=$((width - 1))
  ((cursor_y >= height)) && cursor_y=$((height - 1))

  # Draw if mode is active
  if [[ $draw_mode -eq 1 ]]; then
    color=${colors[$((RANDOM % ${#colors[@]}))]}
    grid[$((cursor_y*width+cursor_x))]="${color}${draw_char}${reset}"
  fi

  draw_canvas
done
