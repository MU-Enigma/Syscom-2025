#!/bin/bash
echo "get ready to press enter anytime now... NOW! hehe just kidding :D , look out for the real thing"
sleep 5
echo "ok fr now.."
sleep $((RANDOM % 3 + 1))
echo "GO! Press Enter!"
start=$SECONDS
read s
echo "Your time:$((SECONDS - start))s"