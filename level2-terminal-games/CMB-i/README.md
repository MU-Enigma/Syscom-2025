# Level 2: Simple Terminal Game  
**Goal:** Build something interactive in the terminal.

---
## 1. Rock–Paper–Scissors

### About
A minimal 3-round Rock–Paper–Scissors game written in pure **Bash**.  
You play against a random CPU opponent.

### Features
- Simple input (`r`, `p`, or `s`)
- Randomized CPU choice
- 3 rounds total
- Score tracking and final winner display
- Runs on any Unix-like terminal (Linux, macOS)

---
## 2. Russian Roulette

### About
A suspenseful chance-based terminal game written in pure Bash.
Spin the cylinder, pull the trigger, and hope your luck holds — all safely simulated with random numbers.

### Features
- Randomized “bullet” chamber each round
- Interactive input with Enter or quit option (q)
- Realistic suspense with timed pauses
- Infinite rounds until the player “loses” or quits
- Works on any Unix-like terminal (Linux, macOS)
---
## How to Run

```bash
# Navigate to the project directory
cd level2-terminal-games/

# Make it executable
chmod +x rps.sh

# Play!
./rps.sh
