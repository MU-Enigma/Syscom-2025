import os
import sys
import json
import hashlib
import time
import argparse
import fnmatch

# -----------------------
# Constants
# -----------------------
GIT_DIR = ".git"
OBJECTS_DIR = os.path.join(GIT_DIR, "objects")
INDEX_FILE = os.path.join(GIT_DIR, "index")
HEAD_FILE = os.path.join(GIT_DIR, "HEAD")
IGNORE_FILE = ".gitignore"

os.makedirs(OBJECTS_DIR, exist_ok=True)

# -----------------------
# Helper Functions
# -----------------------
def read_gitignore():
    ignore_patterns = []
    path = os.path.join(os.getcwd(), IGNORE_FILE)
    if os.path.exists(path):
        with open(path, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    ignore_patterns.append(line)
    return ignore_patterns

def is_ignored(file_path, ignore_patterns):
    ignored = False
    for pattern in ignore_patterns:
        if pattern.startswith("!"):
            if fnmatch.fnmatch(file_path, pattern[1:]):
                return False
        else:
            if fnmatch.fnmatch(file_path, pattern) or file_path.startswith(pattern.rstrip("/")):
                ignored = True
    return ignored

def load_index():
    if os.path.exists(INDEX_FILE):
        with open(INDEX_FILE, "r") as f:
            return json.load(f)
    return {}

def save_index(index):
    with open(INDEX_FILE, "w") as f:
        json.dump(index, f, indent=2)

def hash_object(content):
    return hashlib.sha1(content).hexdigest()

def write_object(sha1_hash, content):
    path = os.path.join(OBJECTS_DIR, sha1_hash)
    if not os.path.exists(path):
        with open(path, "wb") as f:
            f.write(content)

# -----------------------
# Commands
# -----------------------
def cmd_add(files):
    ignore_patterns = read_gitignore()
    index = load_index()
    for file_path in files:
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            continue
        if is_ignored(file_path, ignore_patterns):
            print(f"Ignored: {file_path}")
            continue
        with open(file_path, "rb") as f:
            content = f.read()
        sha1_hash = hash_object(content)
        write_object(sha1_hash, content)
        index[file_path] = {"hash": sha1_hash, "mtime": os.path.getmtime(file_path)}
        print(f"Added: {file_path}")
    save_index(index)

def build_tree(index):
    tree = {f: data["hash"] for f, data in index.items()}
    return tree

def write_commit(tree_hash, message, author="user"):
    parent = None
    if os.path.exists(HEAD_FILE):
        with open(HEAD_FILE, "r") as f:
            parent = f.read().strip() or None
    commit = {
        "tree": tree_hash,
        "parent": parent,
        "author": author,
        "timestamp": time.time(),
        "message": message
    }
    commit_bytes = json.dumps(commit, indent=2).encode()
    commit_hash = hashlib.sha1(commit_bytes).hexdigest()
    commit_path = os.path.join(OBJECTS_DIR, commit_hash)
    with open(commit_path, "wb") as f:
        f.write(commit_bytes)
    with open(HEAD_FILE, "w") as f:
        f.write(commit_hash)
    print(f"Committed: {commit_hash}")
    return commit_hash

def cmd_commit(message):
    index = load_index()
    if not index:
        print("Nothing to commit")
        return
    tree = build_tree(index)
    tree_bytes = json.dumps(tree, indent=2).encode()
    tree_hash = hashlib.sha1(tree_bytes).hexdigest()
    write_commit(tree_hash, message)
    save_index({})

def cmd_status():
    index = load_index()
    ignore_patterns = read_gitignore()
    staged = list(index.keys())
    modified = []
    untracked = []

    for f in os.listdir("."):
        if f.startswith(".git") or not os.path.isfile(f):
            continue
        if is_ignored(f, ignore_patterns):
            continue
        if f in index:
            if os.path.getmtime(f) != index[f]["mtime"]:
                modified.append(f)
        else:
            untracked.append(f)

    print("On branch master\n")
    print("Staged files:")
    for f in staged:
        print(f"  {f}")
    print("\nModified files:")
    for f in modified:
        print(f"  {f}")
    print("\nUntracked files:")
    for f in untracked:
        print(f"  {f}")
    if not staged and not modified and not untracked:
        print("Nothing to commit, working tree clean")

def cmd_rm(files, cached=False):
    index = load_index()
    for f in files:
        if f not in index:
            print(f"File not staged: {f}")
            continue
        index.pop(f)
        if not cached and os.path.exists(f):
            os.remove(f)
            print(f"Removed: {f}")
        else:
            print(f"Unstaged: {f}")
    save_index(index)

def cmd_cat_file(sha1_hash):
    obj_path = os.path.join(OBJECTS_DIR, sha1_hash)
    if not os.path.exists(obj_path):
        print("Object not found")
        return
    with open(obj_path, "rb") as f:
        content = f.read()
    try:
        data = json.loads(content)
        print(json.dumps(data, indent=2))
    except:
        print(content.decode(errors="ignore"))

def cmd_checkout(commit_hash):
    commit_path = os.path.join(OBJECTS_DIR, commit_hash)
    if not os.path.exists(commit_path):
        print("Commit not found")
        return
    with open(commit_path, "rb") as f:
        commit = json.loads(f.read())
    tree_hash = commit["tree"]
    tree_path = os.path.join(OBJECTS_DIR, tree_hash)
    with open(tree_path, "rb") as f:
        tree = json.loads(f.read())
    for f, hash in tree.items():
        obj_path = os.path.join(OBJECTS_DIR, hash)
        with open(obj_path, "rb") as obj_f:
            content = obj_f.read()
        os.makedirs(os.path.dirname(f), exist_ok=True)
        with open(f, "wb") as out_f:
            out_f.write(content)
    with open(HEAD_FILE, "w") as f:
        f.write(commit_hash)
    print(f"Checked out commit {commit_hash}")

def cmd_log():
    if not os.path.exists(HEAD_FILE):
        print("No commits yet")
        return
    commit_hash = open(HEAD_FILE).read().strip()
    while commit_hash:
        commit_path = os.path.join(OBJECTS_DIR, commit_hash)
        with open(commit_path, "rb") as f:
            commit = json.loads(f.read())
        print(f"Commit: {commit_hash}")
        print(f"Author: {commit['author']}")
        print(f"Message: {commit['message']}")
        print(f"Timestamp: {time.ctime(commit['timestamp'])}\n")
        commit_hash = commit["parent"]

def main():
    parser = argparse.ArgumentParser(description="Python VCS")
    subparsers = parser.add_subparsers(dest="command")

    add_parser = subparsers.add_parser("add")
    add_parser.add_argument("files", nargs="+")
    commit_parser = subparsers.add_parser("commit")
    commit_parser.add_argument("-m", "--message", required=True)
    subparsers.add_parser("status")
    rm_parser = subparsers.add_parser("rm")
    rm_parser.add_argument("files", nargs="+")
    rm_parser.add_argument("--cached", action="store_true")
    cat_parser = subparsers.add_parser("cat-file")
    cat_parser.add_argument("hash")
    checkout_parser = subparsers.add_parser("checkout")
    checkout_parser.add_argument("commit")
    subparsers.add_parser("log")

    args = parser.parse_args()

    if args.command == "add":
        cmd_add(args.files)
    elif args.command == "commit":
        cmd_commit(args.message)
    elif args.command == "status":
        cmd_status()
    elif args.command == "rm":
        cmd_rm(args.files, cached=args.cached)
    elif args.command == "cat-file":
        cmd_cat_file(args.hash)
    elif args.command == "checkout":
        cmd_checkout(args.commit)
    elif args.command == "log":
        cmd_log()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
