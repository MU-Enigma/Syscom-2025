import os
import hashlib
import time

GIT_DIR = ".git"
OBJECTS_DIR = os.path.join(GIT_DIR, "objects")
INDEX_FILE = os.path.join(GIT_DIR, "index")
HEAD_FILE = os.path.join(GIT_DIR, "HEAD")

def read_index():
    entries = []
    if not os.path.exists(INDEX_FILE):
        return entries
    with open(INDEX_FILE, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            mode, sha1, path = line.split(" ", 2)
            entries.append({"mode": mode, "sha1": sha1, "path": path})
    return entries

def write_object(data):
    sha1 = hashlib.sha1(data).hexdigest()
    dir_path = os.path.join(OBJECTS_DIR, sha1[:2])
    os.makedirs(dir_path, exist_ok=True)
    file_path = os.path.join(dir_path, sha1[2:])
    if not os.path.exists(file_path):
        with open(file_path, "wb") as f:
            f.write(data)
    return sha1

def build_tree(entries):
    tree_entries = []
    for e in entries:
        mode = e["mode"].encode()
        filename = e["path"].encode()
        sha1_bin = bytes.fromhex(e["sha1"])
        tree_entry = mode + b" " + filename + b"\0" + sha1_bin
        tree_entries.append(tree_entry)
    return b"".join(tree_entries)

def get_head_commit():
    if not os.path.exists(HEAD_FILE):
        return None
    with open(HEAD_FILE, "r") as f:
        ref = f.read().strip()
    if ref.startswith("ref: "):
        ref_path = os.path.join(GIT_DIR, ref[5:])
        if os.path.exists(ref_path):
            with open(ref_path, "r") as rf:
                return rf.read().strip()
        else:
            return None
    else:
        return ref if ref else None

def update_head(commit_sha1):
    with open(HEAD_FILE, "r") as f:
        ref = f.read().strip()
    if ref.startswith("ref: "):
        ref_path = os.path.join(GIT_DIR, ref[5:])
        with open(ref_path, "w") as rf:
            rf.write(commit_sha1 + "\n")
    else:
        with open(HEAD_FILE, "w") as f:
            f.write(commit_sha1 + "\n")

def create_commit(tree_sha1, parent_sha1, author, message):
    timestamp = int(time.time())
    timezone = "+0000"
    lines = []
    lines.append(f"tree {tree_sha1}")
    if parent_sha1:
        lines.append(f"parent {parent_sha1}")
    lines.append(f"author {author} {timestamp} {timezone}")
    lines.append("")
    lines.append(message)
    content = "\n".join(lines).encode()
    header = f"commit {len(content)}\0".encode()
    return header + content

def cmd_commit(message, author="Author <author@example.com>"):
    index_entries = read_index()
    if not index_entries:
        print("Nothing to commit, index is empty.")
        return
    tree_content = build_tree(index_entries)
    tree_sha1 = write_object(tree_content)
    parent_sha1 = get_head_commit()
    commit_content = create_commit(tree_sha1, parent_sha1, author, message)
    commit_sha1 = write_object(commit_content)
    update_head(commit_sha1)
    print(f"[{commit_sha1}] {message}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python cmd_commit.py 'commit message'")
        exit(1)
    msg = sys.argv[1]
    cmd_commit(msg)
