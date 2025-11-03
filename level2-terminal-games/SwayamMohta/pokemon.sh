#!/bin/bash
# pokemon-battle.sh - Simple text Pokémon battle

player_hp=50
enemy_hp=50
pokemons=("Pikachu" "Charmander" "Squirtle" "Bulbasaur")
enemy=${pokemons[$((RANDOM % 4))]}

echo "⚔️ Welcome to Pokémon Battle!"
read -p "Choose your Pokémon (Pikachu/Charmander/Squirtle/Bulbasaur): " player

echo "You chose $player!"
echo "A wild $enemy appears!"

while [ $player_hp -gt 0 ] && [ $enemy_hp -gt 0 ]; do
  damage=$((RANDOM % 10 + 5))
  enemy_hp=$((enemy_hp - damage))
  echo "$player attacks! $enemy takes $damage damage. (HP: $enemy_hp)"

  [ $enemy_hp -le 0 ] && break

  damage=$((RANDOM % 10 + 5))
  player_hp=$((player_hp - damage))
  echo "$enemy attacks! $player takes $damage damage. (HP: $player_hp)"
done

if [ $player_hp -le 0 ]; then
  echo "💀 $player fainted! You lose."
else
  echo "🏆 You defeated $enemy!"
fi
