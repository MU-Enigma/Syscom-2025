#!/usr/bin/env bash

echo "welcome to the luck meter, here, you can find out how lucky you are :D"
echo "enter your name:"
read name
echo "you are $((RANDOM % 100 + 1))% lucky :O"