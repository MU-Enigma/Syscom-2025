#!/bin/bash

player_hp=100
player_mp=50
enemy_hp=100
enemy_mp=50

function player_choice() {
  echo "Your HP: $player_hp, MP: $player_mp"
  echo "Enemy HP: $enemy_hp, MP: $enemy_mp"
  echo "Choose your action: attack, block, magic"
  read -r choice
  while [[ "$choice" != "attack" && "$choice" != "block" && "$choice" != "magic" ]]; do
    echo "Invalid choice. Choose: attack, block, magic"
    read -r choice
  done

  if [[ "$choice" == "magic" && $player_mp -lt 10 ]]; then
    echo "Not enough MP for magic! Choose again."
    player_choice
  else
    PLAYER_ACTION=$choice
  fi
}

function enemy_choice() {
  choices=("attack" "block" "magic")
  while true; do
    choice=${choices[$RANDOM % 3]}
    if [[ "$choice" == "magic" && $enemy_mp -lt 10 ]]; then
      continue
    else
      ENEMY_ACTION=$choice
      break
    fi
  done
  echo "Enemy chose $ENEMY_ACTION"
}

function resolve_turn() {
  player_damage=0
  enemy_damage=0

  # Player attack
  if [[ $PLAYER_ACTION == "attack" ]]; then
    if [[ $ENEMY_ACTION == "block" ]]; then
      player_damage=5   # 5 damage if blocked
    else
      player_damage=10
    fi
  elif [[ $PLAYER_ACTION == "magic" ]]; then
    player_mp=$((player_mp - 10))
    if [[ $ENEMY_ACTION == "block" ]]; then
      player_damage=10
    else
      player_damage=20
    fi
  fi

  # Enemy attack
  if [[ $ENEMY_ACTION == "attack" ]]; then
    if [[ $PLAYER_ACTION == "block" ]]; then
      enemy_damage=5    # 5 damage if blocked
    else
      enemy_damage=10
    fi
  elif [[ $ENEMY_ACTION == "magic" ]]; then
    enemy_mp=$((enemy_mp - 10))
    if [[ $PLAYER_ACTION == "block" ]]; then
      enemy_damage=10
    else
      enemy_damage=20
    fi
  fi

  enemy_hp=$((enemy_hp - player_damage))
  player_hp=$((player_hp - enemy_damage))

  echo "You dealt $player_damage damage."
  echo "Enemy dealt $enemy_damage damage."
  echo
}

while [[ $player_hp -gt 0 && $enemy_hp -gt 0 ]]; do
  player_choice
  enemy_choice
  resolve_turn
done

if [[ $player_hp -le 0 && $enemy_hp -le 0 ]]; then
  echo "It's a draw!"
elif [[ $player_hp -le 0 ]]; then
  echo "You lost!"
else
  echo "You won!"
fi
