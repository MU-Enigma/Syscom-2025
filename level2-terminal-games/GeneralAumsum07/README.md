# Level 2 — GeneralAumsum07

This folder contains my Level 2 Bash game submissions for **Syscom 2025**.

---

## 🎮 Game 1: Number Guess

### 📘 Description
A simple terminal game where the computer picks a random number between **1 and 10**,  
and the player keeps guessing until they get it right.

### ⚙️ How It Works
- The game randomly generates a secret number from 1–10 using `$RANDOM`.
- You type your guesses one by one.
- The script tells you if your guess is **too high**, **too low**, or **correct**.
- The game runs until you guess the correct number.

### 🖥️ How to Run
```bash
cd level2-terminal-games/GeneralAumsum07
chmod +x number_guess.sh    # give permission to execute
./number_guess.sh           # run the game
```

## 🎮 Game 2: Rock Paper Scissors

### 📘 Description
A classic terminal game where you play one round of **Rock–Paper–Scissors** against the computer.

### ⚙️ How It Works
- You enter your choice: `rock`, `paper`, or `scissors`.
- The computer randomly picks its own choice.
- The script compares both and tells you whether you **win**, **lose**, or **tie**.

### 🖥️ How to Run
```bash
cd level2-terminal-games/GeneralAumsum07
chmod +x rps.sh            # give permission to execute
./rps.sh                   # run the game
```
## 🎮 Game 3: Dice Roller

### 📘 Description
A simple terminal dice roller that simulates rolling one or more six-sided dice.

### ⚙️ How It Works
- The player enters how many dice to roll.
- Each die generates a random number between **1 and 6**.
- Results for all dice are displayed on screen.

### 🖥️ How to Run
```bash
cd level2-terminal-games/GeneralAumsum07
chmod +x dice_roller.sh     # give permission to execute
./dice_roller.sh            # run the game
```