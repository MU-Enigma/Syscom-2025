import sys
import os
import zlib

def read_object(git_dir, sha1):
    obj_path = os.path.join(git_dir, "objects", sha1[:2], sha1[2:])
    if not os.path.exists(obj_path):
        print(f"Error: object {sha1} not found", file=sys.stderr)
        sys.exit(1)

    with open(obj_path, "rb") as f:
        compressed = f.read()

    data = zlib.decompress(compressed)
    nul_index = data.find(b"\x00")
    header = data[:nul_index].decode()
    obj_type, _ = header.split(" ", 1)
    content = data[nul_index + 1:]
    return obj_type, content


def get_commit_parents(commit_data):
    parents = []
    for line in commit_data.split(b"\n"):
        if line.startswith(b"parent "):
            parents.append(line.split()[1].decode())
    return parents


def parse_commit(commit_data):
    lines = commit_data.split(b"\n")
    author_line = next((l for l in lines if l.startswith(b"author ")), None)
    message_start = commit_data.find(b"\n\n")

    author = author_line.decode()[7:] if author_line else "Unknown"
    message = commit_data[message_start + 2:].decode().strip() if message_start != -1 else ""
    return author, message


def find_head_commit():
    git_dir = ".git"
    head_path = os.path.join(git_dir, "HEAD")

    if not os.path.exists(head_path):
        print("Error: HEAD not found", file=sys.stderr)
        sys.exit(1)

    with open(head_path) as f:
        ref = f.read().strip()

    if ref.startswith("ref: "):
        ref_path = os.path.join(git_dir, ref[5:])
        with open(ref_path) as f:
            return f.read().strip()
    else:
        return ref


def cmd_log():
    git_dir = ".git"
    if not os.path.isdir(git_dir):
        print("Error: not a git repository", file=sys.stderr)
        sys.exit(1)

    current = find_head_commit()
    visited = set()

    while current and current not in visited:
        visited.add(current)

        obj_type, data = read_object(git_dir, current)
        if obj_type != "commit":
            print(f"Error: {current} is not a commit", file=sys.stderr)
            break

        author, message = parse_commit(data)

        print(f"commit {current}")
        print(f"Author: {author}\n")
        print(f"    {message}\n")

        parents = get_commit_parents(data)
        current = parents[0] if parents else None


if __name__ == "__main__":
    cmd_log()
