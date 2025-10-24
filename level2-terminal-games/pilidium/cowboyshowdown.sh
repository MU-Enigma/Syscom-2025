#!/bin/bash

MIN_WAIT=2
MAX_WAIT=5
WIN_THRESHOLD=0.23 # This is now a hard limit

# ANSI codes to add colour formatting and other things:
# \e[2J clears terminal screen
# \e[H  moves cursor to top-left corner (home position)
readonly C_CLEAR=$'\e[2J\e[H'
readonly C_RED=$'\e[31m'        # Sets subsequent text to red
readonly C_GREEN=$'\e[32m'      # Sets subsequent text to green
readonly C_YELLOW=$'\e[33m'     # Sets subsequent text to yellow
readonly C_CYAN=$'\e[36m'       # Sets subsequent text to cyan
readonly C_OFF=$'\e[0m'         # Resets text formatting to default

# ASCII scenes:
scene_wait() {
cat << EOF


  ${C_CYAN}The long awaited duel begins...${C_OFF}

    (^_^;)              (¬_¬)
    /|T|\\               /|T|\\
     / \\                 / \\
=======================================
 ${C_YELLOW}WAIT FOR THE SIGNAL...${C_OFF}
 PRESS [ENTER] WHEN YOU SEE "DRAW!"
 DON'T DRAW EARLY!
EOF
}
scene_cheat() {
cat << EOF


                            ${C_CYAN}No honour at all!${C_OFF}

    (O_O)               (¬_¬)
    /|T|\\ ?             /|T|\\
     / \\                 / \\
=======================================
 ${C_RED}Y O U   C H E A T E D !${C_OFF}
 You drew before the signal!
EOF
}
scene_draw() {
cat << EOF


  ${C_CYAN}Now or NEVER!!!!!${C_OFF}

  !! ${C_RED}D R A W${C_OFF} !!
    (O_O)               (O_O)
    /|T|\\ ----      ----/|T|\\
     / \\                 / \\
=======================================
EOF
}
scene_win() {
cat << EOF


        ${C_CYAN}Farewell, friend...${C_OFF}

    (^_^)
    /|T|\\ ----
     / \\               ... (x_x)
=======================================
 ${C_GREEN}Y O U   W I N !${C_OFF}
 Your time: $1 seconds.
EOF
}
scene_lose() {
cat << EOF


                            ${C_CYAN}Au revoir, mon ami...${C_OFF}

                        (¬_¬)
                    ---- /|T|\\
    (x_x) ...             / \\
=======================================
 ${C_RED}Y O U   L O S E !${C_OFF}
 You were too slow! (>$WIN_THRESHOLD s)
EOF
}

# Game logic:

echo -ne "$C_CLEAR"         # -n for suppressing automatic newline, -e for interpreting backslashes
scene_wait

wait_time=$((RANDOM % (MAX_WAIT - MIN_WAIT + 1) + MIN_WAIT))

read -t $wait_time          # User should wait before drawing their gun until timeout expires

# If the user doesn't wait, then exit status ($?) will be zero
if [ $? -eq 0 ]; then
    echo -ne "$C_CLEAR"
    scene_cheat
    exit 0
fi

echo -ne "$C_CLEAR"
scene_draw

start_time=$(date +%s.%N)   # Stores date in the format of (seconds since epoch).(nanoseconds passed in the current second)

read -t $WIN_THRESHOLD      # User is supposed to draw their gun now
read_status=$?              # Store the exit status of the read command

end_time=$(date +%s.%N)

echo -ne "$C_CLEAR"

if [ $read_status -eq 0 ]; then
    reaction_time=$(echo "$end_time - $start_time" | bc)
    scene_win "$reaction_time"
else
    scene_lose
fi

exit 0