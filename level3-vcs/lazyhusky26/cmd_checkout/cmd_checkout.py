import sys
import os
import zlib
import shutil

def read_object(repo, sha1):
    obj_path = os.path.join(repo, 'objects', sha1[:2], sha1[2:])
    with open(obj_path, 'rb') as f:
        compressed = f.read()
    data = zlib.decompress(compressed)
    nul_index = data.find(b'\x00')
    header = data[:nul_index].decode()
    obj_type, _ = header.split(' ', 1)
    content = data[nul_index + 1:]
    return obj_type, content

def read_tree(repo, sha1, path="."):
    obj_type, content = read_object(repo, sha1)
    if obj_type != "tree":
        print(f"Error: Object {sha1} is not a tree", file=sys.stderr)
        sys.exit(1)

    i = 0
    while i < len(content):
        space_index = content.find(b' ', i)
        mode = content[i:space_index].decode()

        null_index = content.find(b'\x00', space_index)
        name = content[space_index + 1:null_index].decode()
        sha = content[null_index + 1:null_index + 21].hex()

        i = null_index + 21

        if mode.startswith("04"):
            dir_path = os.path.join(path, name)
            os.makedirs(dir_path, exist_ok=True)
            read_tree(repo, sha, dir_path)
        else:  # File
            _, blob_data = read_object(repo, sha)
            file_path = os.path.join(path, name)
            with open(file_path, "wb") as f:
                f.write(blob_data)

def cmd_checkout(args):
    git_dir = ".git"
    if not os.path.isdir(git_dir):
        print("Error: .git directory not found", file=sys.stderr)
        sys.exit(1)

    ref = args.commit
    ref_path = os.path.join(git_dir, "refs", "heads", ref)
    head_path = os.path.join(git_dir, "HEAD")

    if os.path.isfile(ref_path):
        with open(ref_path) as f:
            sha1 = f.read().strip()
    else:
        sha1 = ref

    obj_type, commit_data = read_object(git_dir, sha1)
    if obj_type != "commit":
        print(f"Error: {sha1} is not a commit", file=sys.stderr)
        sys.exit(1)

    lines = commit_data.split(b"\n")
    tree_line = next(l for l in lines if l.startswith(b"tree "))
    tree_sha = tree_line.split()[1].decode()

    for root, dirs, files in os.walk(".", topdown=False):
        if ".git" in root:
            continue
        for f in files:
            os.remove(os.path.join(root, f))
        for d in dirs:
            dir_path = os.path.join(root, d)
            if d != ".git":
                try:
                    os.rmdir(dir_path)
                except OSError:
                    pass

    read_tree(git_dir, tree_sha)

    with open(head_path, "w") as f:
        if os.path.isfile(ref_path):
            f.write(f"ref: refs/heads/{ref}\n")
        else:
            f.write(f"{sha1}\n")

    print(f"Checked out {ref} ({sha1[:7]})")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Checkout a commit or branch")
    parser.add_argument("commit", help="Commit hash or branch name to checkout")
    args = parser.parse_args()
    cmd_checkout(args)
