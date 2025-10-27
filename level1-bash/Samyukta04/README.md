# Level 1 – Bash Basics

Simple Bash scripts covering the basics of shell scripting.

## Scripts
| Script Name     | Description                                                        | Key Concepts                  |
| --------------- | ------------------------------------------------------------------ | ----------------------------- |
| `h1.sh`         | Prints “Hello, World!” to the terminal.                            | `echo`, basic output          |
| `systeminfo.sh` | Displays kernel, disk usage, and uptime info.                      | `uname`, `df`, `uptime`       |
| `calc.sh`       | Performs simple arithmetic (+ − × ÷) using command-line arguments. | `$1`, `case`, arithmetic      |
| `count.sh`      | Counts words or lines in a file.                                   | `wc`, file input              |
| `loop.sh`       | Demonstrates loops by printing numbers or patterns.                | `for`, iteration              |
| `var.sh`        | Example of variables and arguments in Bash.                        | variables, user input         |
| `attendance.sh` | Calculates attendance percentage and checks exam eligibility.      | conditionals, `bc`, `if-else` |

## How to Run
```bash
chmod +x *.sh
./h1.sh
