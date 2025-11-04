#!/usr/bin/env bash
events=("go bald" "get touched by dheeraj" "be happy" "find the love of your life" "sleep all day" "turn gay" "find out your life was a lie" "die from getting touched by me")
echo "You will ${events[$RANDOM % ${#events[@]}]} tomorrow."
