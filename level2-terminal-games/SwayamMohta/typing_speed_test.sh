#!/bin/bash

# Color codes
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLDWHITE='\033[1;37m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

sentences=(
  "The quick brown fox jumps over the lazy dog."
  "Pack my box with five dozen liquor jugs."
  "Sphinx of black quartz, judge my vow."
  "How vexingly quick daft zebras jump!"
  "Bright vixens jump; dozy fowl quack."
  "Jackdaws love my big sphinx of quartz."
  "The five boxing wizards jump quickly."
  "Crazy Fredrick bought many very exquisite opal jewels."
  "We promptly judged antique ivory buckles for the next prize."
  "Sixty zippers were quickly picked from the woven jute bag."
  "Amazingly few discotheques provide jukeboxes."
  "Jived fox nymph grabs quick waltz."
  "Glib jocks quiz nymph to vex dwarf."
  "Two driven jocks help fax my big quiz."
  "Quick zephyrs blow, vexing daft Jim."
  "Few black taxis drive up major roads on quiet hazy nights."
  "The wizard quickly jinxed the gnomes before they vaporized."
  "Big fjords vex quick witted gazelle hunters."
  "Grumpy wizards make toxic brew for the evil queen and jack."
  "Jinxed wizards pluck ivy from the big quilt."
)

# Clear the terminal
clear

echo -e "${YELLOW}Get ready! Typing Speed Test will start in:${NC}"
for i in {6..1}; do
  echo -e "${YELLOW}$i...${NC}"
  sleep 1
done

# Pick a random sentence
RANDOM=$$
sentence=${sentences[$RANDOM % ${#sentences[@]}]}

echo
echo -e "${CYAN}Type the following sentence exactly as shown:${NC}"
echo
echo -e "${CYAN}\"$sentence\"${NC}"
echo

echo -ne "${BOLDWHITE}Your input: ${NC}"
start_time=$(date +%s)

read -r user_input

end_time=$(date +%s)
elapsed_sec=$((end_time - start_time))

word_count=$(echo "$sentence" | wc -w)
if [ $elapsed_sec -gt 0 ]; then
  wpm=$(( word_count * 60 / elapsed_sec ))
else
  wpm=0
fi

correct_chars=0
len=${#sentence}
input_len=${#user_input}
min_len=$(( len < input_len ? len : input_len ))

for (( i=0; i<min_len; i++ )); do
  if [ "${sentence:i:1}" == "${user_input:i:1}" ]; then
    ((correct_chars++))
  fi
done

accuracy=$(( correct_chars * 100 / len ))

echo
echo -e "${GREEN}Results:${NC}"
echo -e "${GREEN}--------${NC}"
echo -e "${GREEN}Time taken:${NC} $elapsed_sec seconds"
echo -e "${GREEN}Words per minute (WPM):${NC} $wpm"
echo -e "${GREEN}Accuracy:${NC} $accuracy%"

if [ $accuracy -lt 100 ]; then
  echo -e "${RED}Keep practicing to improve your accuracy!${NC}"
else
  echo -e "${GREEN}Perfect typing! Great job!${NC}"
fi
