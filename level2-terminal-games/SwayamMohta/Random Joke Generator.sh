#!/bin/bash
jokes=("Why don't skeletons fight each other? They don't have the guts."
       "I told my computer I needed a break, and now it won’t stop sending me Kit-Kats."
       "I used to play piano by ear, but now I use my hands."
       "Parallel lines have so much in common, it's a shame they'll never meet.")
random_joke=${jokes[$RANDOM % ${#jokes[@]} ]}
echo "$random_joke"
