# Level 3: Python Version Control System (VCS)

This project is a hands-on implementation of a Git-like Version Control System (VCS) written in Python. Starting from a basic, buggy script, this level focuses on building out the core functionality that powers Git under the hood.

The primary goal is to gain a deep understanding of how Git's fundamental objects (blobs, trees, commits) and its staging area (the index) work by implementing them from scratch.

## Features Implemented

This VCS now supports the following commands:

1.  **`.gitignore` Support**: The repository respects `.gitignore` rules, including patterns like `*.log`, `build/`, and exceptions like `!important.txt`.
2.  **`vcs add`**: Stages files for commit. This command reads files, creates **blob** objects in `.git/objects/`, and updates the **`.git/index`** (the staging area) with the file's hash and metadata.
3.  **`vcs commit`**: Creates a new commit. This command reads the index, builds a **tree** object from the staged files, and creates a **commit** object that points to that tree and its parent commit.
4.  **`vcs rm`**: Removes files from the staging area (`--cached`) and optionally from the working directory.
5.  **`vcs status`**: Provides a full repository status, showing:
    - Changes to be committed (Staged files)
    - Changes not staged for commit (Modified files)
    - Untracked files
6.  **`vcs cat-file`**: A debugging tool to inspect any Git object. Supports a `-p` flag for pretty-printing commits, trees, and blobs.
7.  **`vcs checkout`**: Switches the `HEAD`, working directory, and index to match a specific commit or branch.
8.  **`vcs log`**: Displays the commit history for the current branch in a familiar, text-based format.
9.  **`vcs merge` (Simplified)**: A placeholder implementation that successfully creates a _merge commit_ (a commit with two parents) but does not perform a true 3-way file merge.
10. **`vcs rebase` (Stub)**: A stub command that acknowledges the request but does not perform the complex rebase operation.

## Core Concepts

This project is a deep dive into Git's core data model:

- **Blob**: Stores the raw content of a file.
- **Tree**: Represents a directory, storing pointers (by SHA-1 hash) to the blobs and other trees within it.
- **Commit**: A snapshot of the repository at a specific time. It stores a pointer to the root **tree**, the parent commit(s), and metadata like the author and commit message.
- **The Index**: The critical `.git/index` file. It acts as the staging area, holding a list of all files in the _next_ commit. This is what `vcs add` modifies and `vcs commit` reads from.

## How to Use

_Note: This script requires Python 3._

1.  **Initialize a new repository:**

    ```bash
    python vcs.py init
    Initialized empty Git repository in /path/to/your/project/.git/
    ```

2.  **Create a file and add it:**

    ```bash
    echo "Hello World" > file.txt
    python vcs.py add file.txt
    ```

3.  **Check the status:**

    ```bash
    python vcs.py status
    On branch master

    Changes to be committed:
      (use "git rm --cached <file>..." to unstage)
            new file:   file.txt
    ```

4.  **Commit the changes:**

    ```bash
    python vcs.py commit -m "Initial commit"
    [master (root-commit) 6a2f8c5] Initial commit
    ```

5.  **View the commit history:**

    ```bash
    python vcs.py log

    commit 6a2f8c5b3d9c1b9f3e4a2d8c7b6e0a1d4f9c8b2
    Author: User <user@example.com> 1729864200 +0000
    Date:   Sat Oct 25 18:00:00 2025 +0000

        Initial commit
    ```

---

_Disclaimer: This code was built as a learning exercise. It is not perfect, may contain bugs, and does not implement all of Git's features (or edge cases). Its purpose is to demonstrate the fundamental design of a version control system._
