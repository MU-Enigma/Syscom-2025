import os
import fnmatch
import sys
import hashlib
import zlib
import collections

# --- GitObject System ---
class GitObject:
    def __init__(self, repo, data=None):
        self.repo = repo
        if data:
            self.deserialize(data)

    def serialize(self):
        raise Exception("Unimplemented")

    def deserialize(self, data):
        raise Exception("Unimplemented")


class GitBlob(GitObject):
    fmt = b'blob'

    def serialize(self):
        return self.blobdata

    def deserialize(self, data):
        self.blobdata = data


# --- Core Git File Handling ---
def repo_file(repo, *path, mkdir=False):
    path = os.path.join(repo.gitdir, *path)
    if mkdir:
        os.makedirs(os.path.dirname(path), exist_ok=True)
    return path


def object_write(obj, actually_write=True):
    data = obj.serialize()
    result = obj.fmt + b' ' + str(len(data)).encode() + b'\x00' + data
    sha = hashlib.sha1(result).hexdigest()

    if actually_write:
        path = repo_file(obj.repo, "objects", sha[0:2], sha[2:], mkdir=True)
        with open(path, "wb") as f:
            f.write(zlib.compress(result))
    return sha


def object_hash(fd, fmt, repo=None):
    data = fd.read()
    if fmt == b'blob':
        obj = GitBlob(repo, data)
    else:
        raise Exception(f"Unsupported format {fmt}")
    return object_write(obj, repo is not None)


# --- .gitignore Handling ---
def read_gitignore(repo):
    ignore_path = os.path.join(repo.worktree, ".gitignore")
    patterns = []

    if not os.path.exists(ignore_path):
        return patterns

    with open(ignore_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            patterns.append(line)

    return patterns


def matches_pattern(path, pattern):
    if pattern.endswith("/"):
        return path.startswith(pattern)
    return fnmatch.fnmatch(path, pattern)


def is_ignored(path, ignore_patterns):
    ignored = False
    for pattern in ignore_patterns:
        if pattern.startswith("!"):
            if matches_pattern(path, pattern[1:]):
                return False
        else:
            if matches_pattern(path, pattern):
                ignored = True
    return ignored


# --- Index Management ---
def add_to_index(repo, path, sha):
    index_path = repo_file(repo, "index", mkdir=True)
    entries = {}

    if os.path.exists(index_path):
        with open(index_path, "r") as f:
            for line in f:
                s, p = line.strip().split(" ", 1)
                entries[p] = s

    entries[path] = sha

    with open(index_path, "w") as f:
        for p in sorted(entries):
            f.write(f"{entries[p]} {p}\n")


# --- Repository Logic ---
class GitRepository:
    def __init__(self, path):
        self.worktree = path
        self.gitdir = os.path.join(path, ".git")
        if not os.path.isdir(self.gitdir):
            raise Exception(f"Not a Git repository: {path}")


def repo_find(path="."):
    path = os.path.realpath(path)
    if os.path.isdir(os.path.join(path, ".git")):
        return GitRepository(path)
    parent = os.path.realpath(os.path.join(path, ".."))
    if parent == path:
        raise Exception("No git directory found")
    return repo_find(parent)


# --- The Actual cmd_add Logic ---
def cmd_add(paths):
    repo = repo_find()
    ignore_patterns = read_gitignore(repo)

    for path in paths:
        if not os.path.isfile(path):
            print(f"warning: {path} is not a file. Skipping.")
            continue

        if is_ignored(path, ignore_patterns):
            print(f"warning: {path} is ignored by .gitignore. Skipping.")
            continue

        with open(path, "rb") as f:
            sha = object_hash(f, b'blob', repo)

        print(f"added: {path} -> {sha}")
        add_to_index(repo, path, sha)


# --- CLI Entry Point ---
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: cmd_add.py <file1> [file2 ...]")
        sys.exit(1)

    cmd_add(sys.argv[1:])
