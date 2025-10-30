import os
import sys
import argparse
from pathlib import Path

from vcs_helpers import read_index, write_index, repo_root

def remove_from_index(paths, cached=False):
    """
    Remove specified paths from the index (and optionally from working directory).
    """
    root = repo_root()
    index = read_index()
    updated_index = []

    index_paths = {entry['path']: entry for entry in index}
    removed = set()

    for path in paths:
        full_path = os.path.join(root, path)
        path_obj = Path(full_path)

        # Expand directory to all tracked files under it
        if path_obj.is_dir():
            tracked_files = [
                p for p in index_paths if p.startswith(path.rstrip('/') + '/')
            ]
        else:
            tracked_files = [path] if path in index_paths else []

        if not tracked_files:
            print(f"warning: '{path}' is not staged and will be ignored", file=sys.stderr)
            continue

        for tracked in tracked_files:
            removed.add(tracked)
            if not cached:
                try:
                    os.remove(os.path.join(root, tracked))
                except FileNotFoundError:
                    pass  # Already gone — we don't mind

    # Rewrite index without the removed files
    for entry in index:
        if entry['path'] not in removed:
            updated_index.append(entry)

    write_index(updated_index)

def main(argv=None):
    parser = argparse.ArgumentParser(description="Remove files from index and optionally from working directory.")
    parser.add_argument('paths', nargs='+', help='Files or directories to remove')
    parser.add_argument('--cached', action='store_true', help='Only remove from index, not working directory')
    args = parser.parse_args(argv)

    remove_from_index(args.paths, cached=args.cached)

if __name__ == '__main__':
    main()
