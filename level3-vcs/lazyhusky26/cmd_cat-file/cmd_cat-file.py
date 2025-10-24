import sys
import os
import zlib

def read_object(sha1_prefix):
    git_dir = '.git'
    if not os.path.isdir(git_dir):
        print("Error: .git directory not found", file=sys.stderr)
        sys.exit(1)

    obj_dir = os.path.join(git_dir, 'objects', sha1_prefix[:2])
    obj_file = os.path.join(obj_dir, sha1_prefix[2:])

    if not os.path.isfile(obj_file):
        print(f"Error: object {sha1_prefix} not found", file=sys.stderr)
        sys.exit(1)

    with open(obj_file, 'rb') as f:
        compressed_data = f.read()

    try:
        decompressed = zlib.decompress(compressed_data)
    except zlib.error as e:
        print(f"Error decompressing object {sha1_prefix}: {e}", file=sys.stderr)
        sys.exit(1)

    nul_index = decompressed.find(b'\x00')
    header = decompressed[:nul_index].decode()
    obj_type, size_str = header.split(' ')
    size = int(size_str)

    content = decompressed[nul_index+1:]

    if len(content) != size:
        print(f"Warning: size mismatch in object {sha1_prefix} (expected {size}, got {len(content)})", file=sys.stderr)

    return obj_type, content

def print_blob(content):
    print(content.decode(errors='replace'))

def print_commit(content):
    text = content.decode(errors='replace')
    print(text)

def print_tag(content):
    text = content.decode(errors='replace')
    print(text)

def print_tree(content):
    i = 0
    while i < len(content):
        space_index = content.find(b' ', i)
        mode = content[i:space_index].decode()

        null_index = content.find(b'\x00', space_index)
        filename = content[space_index+1:null_index].decode()

        sha_bin = content[null_index+1:null_index+21]
        sha_hex = sha_bin.hex()

        print(f"{mode} {sha_hex}\t{filename}")

        i = null_index + 21

def main():
    if len(sys.argv) != 2:
        print("Usage: cmd_cat-file.py <sha1>", file=sys.stderr)
        sys.exit(1)

    sha1 = sys.argv[1]
    if len(sha1) < 4 or len(sha1) > 40:
        print("Error: SHA1 hash length invalid", file=sys.stderr)
        sys.exit(1)

    if len(sha1) < 40:
        print("Error: please provide full 40 character SHA1", file=sys.stderr)
        sys.exit(1)

    obj_type, content = read_object(sha1)

    if obj_type == 'blob':
        print_blob(content)
    elif obj_type == 'commit':
        print_commit(content)
    elif obj_type == 'tag':
        print_tag(content)
    elif obj_type == 'tree':
        print_tree(content)
    else:
        print(f"Unknown object type: {obj_type}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
