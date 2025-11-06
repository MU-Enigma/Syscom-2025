#!/bin/bash

read -p "Enter the symbol to use: " symbol

read -p "Enter the number of layers: " layers

for ((i=1; i<=layers; i++))
do
    for ((j=i; j<layers; j++))
    do
        echo -n " "
    done

    for ((k=1; k<=(2*i-1); k++))
    do
        echo -n "$symbol"
    done

    echo
done
