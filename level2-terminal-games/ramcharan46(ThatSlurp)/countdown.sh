#!/usr/bin/env bash
echo "enter the number of secounds for the countdown:"
read sec
while [$sec -gt 0];do
    echo "$sec"
    sleep 1
    sec--
done
echo "the countdown ends :D"