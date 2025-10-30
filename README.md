# Syscom

Welcome to the **SysCom** Repository!  
This repository is designed for participants of all skill levels to learn, contribute, and collaborate on open-source software through a progressive 4-level challenge — starting from simple Bash scripting to debugging and improving a real version control system.

The tasks are broken down into levels to suit all difficulty ranges.  
Levels 1 and 2 are a great starting point if you're new to Git/GitHub or command-line tools.  
Once you’re comfortable contributing, you can move on to Levels 3 and 4, where you’ll be working on real bugs and features in a custom-built VCS project.

If you're participating in Hacktoberfest, please remember that only **merged Pull Requests (PRs)** count as valid contributions — opening issues alone will not.  
All PRs should include a clear explanation of your solution. Reviewers may request changes; please respond constructively and update your PR as needed.

---

## Level 1: Bash Foundations

**Goal:** Learn the basics of command-line automation and Bash scripting.  

You’ll start by contributing small, beginner-friendly shell scripts that help you get comfortable with Linux commands, file handling, and GitHub workflows.  

**Examples:**
- Print “Hello, World” using `echo`
- Display system info using `uname`, `df`, or `uptime`
- Simple calculator using command-line arguments
- Convert Celsius to Fahrenheit
- Count words or lines in a file

**Directory:** `level1-bash/`  
**Goal:** Learn Bash basics, file permissions, and your first GitHub PR.

---

## Level 2: Simple Terminal Game

**Goal:** Build something interactive in the terminal.  

This level introduces logic, loops, and user input handling through simple games.  
It’s a fun way to improve your scripting logic while still staying within the terminal environment.

**Examples:**
- Tic-Tac-Toe (text-based)
- Hangman
- Number Guessing Game
- Rock–Paper–Scissors

**Directory:** `level2-terminal-games/`  
**Goal:** Learn program flow, decision-making, and user I/O in the terminal.

---

## Level 3: Working on Issues in a Version Control System

**Goal:** Contribute to a real codebase and understand how Git-like tools are built.  

You’ll work on **issues** in a simplified **Version Control System (VCS)** built for learning.  
Here, you’ll fix bugs, optimize commands, and improve CLI tools related to commits, branching, or file tracking.

**Example Issues:**
- Fix incorrect commit history output  
- Handle empty repository initialization  
- Add confirmation before destructive operations  
- Improve help menu or command flags  

**Tags:** `level3`, `bug`, `feature`, `general`  
**Directory:** `level3-vcs/`  
**Goal:** Learn debugging, structured contributions, and the open-source issue workflow.

---

## Level 4: Finding and Fixing Issues in the VCS

Here, you’ll explore the VCS source code, identify new issues, and propose fixes or enhancements.  
Think like a maintainer — open meaningful issues, suggest improvements, and implement them.

**Examples:**
- Add new commands (e.g., `vcs merge`, `vcs diff`)  
- Fix performance bottlenecks in file tracking  
- Improve error handling or logging  
- Propose UI/UX improvements for CLI messages  

**Directory:** `level4-advanced/`  
**Goal:** Learn end-to-end open-source contribution — from identifying problems to implementing solutions.

---

## Contribution Guide

Follow these steps to make your first contribution:

### 1. Fork this repo
Click the **Fork** button in the top-right corner of this page to create a copy under your GitHub account.

### 2. Clone your fork
Bring your fork to your local machine:

```bash
git clone https://github.com/<your-username>/Syscom.git
cd Syscom
```

### 3. Create a new branch
Keep your changes organized:

```bash
git checkout -b my-branch-name
```

### 4. Pick a level and make changes
- **Levels 1/2:** Create a folder under the respective level with your GitHub username and add your script(s).
- **Levels 3/4:** Work on assigned or self-found issues inside the `src/` directory.

### 5. Stage and commit
```bash
git add .
git commit -m "Added tic-tac-toe bash game"
```

### 6. Push and open a PR
```bash
git push origin my-branch-name
```
Then go to your fork → click **“Compare & pull request”**, and describe your changes clearly.

---

### Quick Tips
- Keep PRs focused (one feature/fix per PR).  
- Use meaningful commit messages.  
- Before starting new work, always sync your fork:
```bash
git remote add upstream https://github.com/<maintainer-username>/Syscom.git
git fetch upstream
git merge upstream/main
```
Keeping your fork updated helps you avoid merge conflicts later.

---

**Happy Contributing**  
“Every PR is a step toward mastering open source :P.”
(PS: i read that somewhere)
