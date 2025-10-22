# 🚢 Battleship - Terminal Edition

A classic Battleship game implemented in Bash for the terminal. Hunt down enemy ships on a 5×5 grid with strategic targeting!

## 📋 Features

### Core Gameplay
- **5×5 Grid**: Simple A-E columns and 1-5 rows
- **3 Ships to Sink**:
  - 🛥️ Destroyer (2 cells)
  - 🚤 Submarine (3 cells)
  - 🚢 Battleship (4 cells)
- **Random Ship Placement**: Ships are placed horizontally or vertically with no overlaps
- **Fog of War**: Only see your hits (X) and misses (o) - ship locations remain hidden
- **Win Condition**: Sink all three ships to win!

### Polished Features
- ✅ **Input Validation**: Rejects invalid coordinates (like Z9 or 6A)
- 🚫 **Duplicate Shot Detection**: Warns you if you've already fired at a location
- 🎨 **Color Support**: 
  - Green `X` for hits
  - Blue `o` for misses
  - Use `--no-color` flag to disable
- 📊 **Real-time Stats**: Track shots, hits, misses, and accuracy
- 🎯 **Difficulty Modes**:
  - **Normal**: Standard gameplay
  - **Easy**: Shows remaining cells for each ship after every shot

## 🚀 Installation

### Prerequisites
- Bash shell (Linux, macOS, WSL on Windows, or Git Bash)

### Setup
```bash
# Clone or download the script
chmod +x battleship.sh
```

## 🎮 How to Play

### Basic Usage
```bash
./battleship.sh
```

### With Options
```bash
# Easy mode with hints
./battleship.sh --easy

# Disable colors
./battleship.sh --no-color

# Combine options
./battleship.sh --easy --no-color
```

### Game Instructions

1. **Start the Game**: Run the script and ships will be randomly placed
2. **Enter Coordinates**: Type coordinates like `A5`, `B3`, or `C1` (case-insensitive)
3. **See Results**: 
   - `HIT!` - You hit a ship
   - `Miss.` - You missed
   - `You sunk the [Ship]!` - You destroyed a ship completely
4. **Win**: Sink all three ships to see your final score and accuracy

### Coordinate System
```
   A B C D E
1  . . . . .
2  . . . . .
3  . . . . .
4  . . . . .
5  . . . . .
```

- **Columns**: A, B, C, D, E (left to right)
- **Rows**: 1, 2, 3, 4, 5 (top to bottom)
- **Example inputs**: `A1`, `b3`, `D5`, `c2`

## 📊 Game Display

### Board Symbols
- `.` - Unknown/Not yet fired at
- `X` - Hit (shown in green with colors enabled)
- `o` - Miss (shown in blue with colors enabled)

### Stats Display
```
Shots: 12 | Hits: 5 | Misses: 7
```

### Easy Mode Display
Shows remaining cells for each ship:
```
Ships remaining:
  Destroyer: 1 cells left
  Submarine: 2 cells left
  Battleship: 3 cells left
```

## 🎯 Victory Screen

When you sink all ships, you'll see:
```
╔════════════════════════════════════╗
║         VICTORY!                   ║
╚════════════════════════════════════╝

All ships destroyed!
Total shots: 15
Hits: 9
Misses: 6
Accuracy: 60.0%
```

## 🔧 Running on Different Systems

### Linux/macOS
```bash
./battleship.sh
```

### Windows (WSL)
```bash
# Option 1: Navigate in WSL
wsl
cd /mnt/c/path/to/your/folder
./battleship.sh

# Option 2: Direct command from PowerShell
wsl bash /mnt/c/path/to/your/folder/battleship.sh
```

### Windows (Git Bash)
```bash
bash battleship.sh
```

## 💡 Tips & Strategy

1. **Start with a Pattern**: Try shooting in a checkerboard or cross pattern to find ships quickly
2. **Follow Up Hits**: When you hit a ship, try adjacent cells (up, down, left, right)
3. **Track Your Progress**: In easy mode, focus on ships with fewer remaining cells first
4. **Corner Strategy**: Ships can't hide in corners - start from edges and work inward

## 🐛 Troubleshooting

### Script won't run
```bash
# Make sure it's executable
chmod +x battleship.sh

# Check if bash is available
which bash
```

### Colors not showing
- Some terminals don't support ANSI colors
- Use the `--no-color` flag: `./battleship.sh --no-color`

### Script exits immediately
- Make sure you're using bash, not sh
- Run with: `bash battleship.sh`

## 📜 License

Feel free to use, modify, and distribute this game!

## 🎲 Example Game

```
=== BATTLESHIP ===
   A B C D E
1  . . o . .
2  . X X . .
3  . . o . .
4  . . . . .
5  o . . . .

Shots: 6 | Hits: 2 | Misses: 4

Enter coordinates to fire: B3
HIT!
You sunk the Destroyer!
```

---

**Have fun and happy hunting! 🎯🚢**