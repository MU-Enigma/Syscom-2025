import os
import sys
import hashlib
from pathlib import Path
from vcs_helpers import repo_find, read_gitignore, is_ignored

def read_index(repo):
    """Read .git/index into a dict {path: (mode, sha)}"""
    index_path = os.path.join(repo.gitdir, "index")
    entries = {}
    if os.path.exists(index_path):
        with open(index_path, "r") as f:
            for line in f:
                parts = line.strip().split(" ")
                if len(parts) == 3:
                    mode, sha, path = parts
                    entries[path] = (mode, sha)
    return entries

def hash_file(path):
    """Compute a git-like blob hash for a file."""
    with open(path, "rb") as f:
        data = f.read()
    header = b"blob " + str(len(data)).encode() + b"\x00" + data
    return hashlib.sha1(header).hexdigest()

def cmd_status(args=None):
    repo = repo_find()
    ignore_patterns = read_gitignore(repo)
    index = read_index(repo)

    staged = []
    modified = []
    untracked = []

    for root, dirs, files in os.walk(repo.worktree):
        if ".git" in dirs:
            dirs.remove(".git")

        for file in files:
            rel_path = os.path.relpath(os.path.join(root, file), repo.worktree)
            if is_ignored(rel_path, ignore_patterns):
                continue

            full_path = os.path.join(root, file)
            if rel_path in index:
                try:
                    new_sha = hash_file(full_path)
                    _, old_sha = index[rel_path]
                    if new_sha != old_sha:
                        modified.append(rel_path)
                    else:
                        staged.append(rel_path)
                except FileNotFoundError:
                    modified.append(rel_path)
            else:
                untracked.append(rel_path)

    print("On branch master\n")

    if staged:
        print("Changes to be committed:")
        for f in staged:
            print(f"    {f}")
        print()

    if modified:
        print("Changes not staged for commit:")
        for f in modified:
            print(f"    {f}")
        print()

    if untracked:
        print("Untracked files:")
        for f in untracked:
            print(f"    {f}")
        print()

    if not (staged or modified or untracked):
        print("nothing to commit, working tree clean")

if __name__ == "__main__":
    cmd_status()
