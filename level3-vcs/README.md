#  Level 3 — Extend and Implement the Version Control System (VCS)

Welcome to **Level 3**!
Here, you’ll work with a **Python-based version control system** inspired by Git — implemented in `vcs.py`.
Your goal is to extend its functionality, add new commands, and make it behave more like a real Git client.

This level is designed to give you hands-on experience with how Git actually works under the hood — how commits, trees, and objects are structured and tracked.

---

##  Project Overview

The provided code (`vcs.py`) already contains the foundational structure for:

* Repositories and configuration
* Blob, tree, and commit objects
* Object storage, hashing, and reading mechanisms

However, many important commands are either missing or incomplete.
Your task is to **implement them** directly inside this file.

---

##  Tasks to Complete

### 1. `.gitignore` — Repo Hygiene

Implement a `.gitignore` system that prevents certain files from being staged.

* Read a `.gitignore` file at the root of the repo.
* Support simple patterns:

  * `*.log` → ignore `.log` files
  * `build/` → ignore everything inside `build`
  * `!important.txt` → exception (don’t ignore)

---

### 2. `cmd_add` — Stage Files

Implement the logic to add files to the staging area.

* Read files from the working directory.
* Create blob objects and store them in `.git/objects/`.
* Update the index with file path, SHA-1 hash, and metadata.
* Respect `.gitignore` patterns.

---

### 3. `cmd_commit` — Create Commits

Allow users to commit staged files with a message.

* Read the index and build a tree object.
* Create a commit object including:

  * Tree hash
  * Parent commit (if any)
  * Author name and timestamp
  * Commit message
* Write the commit to `.git/objects/` and update `HEAD`.

---

### 4. `cmd_rm` — Remove Files

Add functionality to remove files from the index and optionally from the working directory.

* Support multiple files or directories.
* Warn when removing non-existent or unstaged files.

---

### 5. `cmd_status` — Show Repo Status

Implement a command that shows the repo’s current state.

* List:

  * **Staged files** (ready to commit)
  * **Modified files** (changed but not staged)
  * **Untracked files** (not in index and not ignored)
* Clearly display categories and respect `.gitignore`.

---

### 6. `cmd_cat-file` — Display Git Objects

Create a way to view Git objects for debugging.

* Read any object (`blob`, `tree`, `commit`, `tag`) from `.git/objects/`.
* Display relevant info in readable format.

---

### 7. `merge` — Merge Commits / Branches

Implement a simplified merge mechanism:

* Find a common ancestor.
* Combine changes into a single merge commit.
* Handle conflicts gracefully.

---

### 8. `rebase` — Replay Commits

Allow users to replay commits from one branch onto another.

* Rewrite commit history.
* Handle conflicts similar to `merge`.

---

### 9. `cmd_checkout` — Checkout Commits

Enable switching between commits or branches.

* Apply the tree from a specific commit to the working directory.
* Recreate files and folders accurately.

---

### 10. `cmd_log` — Display Commit History

Display the commit history for the current branch.

* Traverse commits via parent references.
* Show commit hash, author, and message.
* (Optional) Add a graph-like visualization.

---

##  Learning Goals

* Understand how commits, trees, and blobs are structured and stored.
* Learn the workflow behind staging, committing, and checking out files.
* Gain experience contributing to a realistic open-source Python project.

---

## How to Contribute

1. **Fork the repo** and clone your copy.
2. **Create a new branch** for your feature:

   ```bash
   git checkout -b feature/cmd_add
   ```
3. Implement your code inside `level3-vcs/vcs.py`.
4. Test your implementation locally.
5. Commit and push your changes:

   ```bash
   git add .  
   git commit -m "Implemented cmd_add for staging files"  
   git push origin feature/cmd_add  
   ```
6. Open a Pull Request explaining your solution and referencing the task name.

---

**Directory:** `level3-vcs/`
**Main file:** `vcs.py`
**Goal:** Implement Git-like functionality and understand the fundamentals of version control.

---

**Happy Coding and Debugging! 🐍**
