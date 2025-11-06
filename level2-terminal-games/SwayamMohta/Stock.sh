#!/bin/bash
# STOCK TRADER
money=1000; stocks=0
echo "💹 STOCK TRADER TYPHOON"
for ((t=1;t<=10;t++)); do
  price=$((RANDOM%100+50))
  echo "Day $t | Stock: ₹$price | Money: ₹$money | You own: $stocks"
  echo "[B]uy / [S]ell / [N]ext"
  read -n1 -p "> " choice; echo
  case $choice in
    b) ((money>=price)) && ((stocks++)) && ((money-=price)) && echo "Bought 1!" || echo "Not enough money.";;
    s) ((stocks>0)) && ((stocks--)) && ((money+=price)) && echo "Sold 1!" || echo "No stocks to sell.";;
    *) echo "Next day...";;
  esac
done
((money+=stocks*price))
echo "📈 Final Balance: ₹$money"
