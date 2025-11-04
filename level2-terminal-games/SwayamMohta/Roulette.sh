#!binbash
# roulette.sh - Simple roulette game

echo 🎡 Welcome to Mini Roulette!
read -p Bet on a number (0–36)  bet

roll=$((RANDOM % 37))
echo The wheel spins... 🎯 Result $roll

if [ $bet -eq $roll ]; then
  echo 💰 You win 36x your bet!
else
  echo 😢 You lose.
fi
