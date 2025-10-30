import sys
import os
import time
import collections
from vcs_buggy import (
    repo_find,
    object_read,
    object_write,
    GitCommit,
    GitTree,
    GitTreeLeaf,
    ref_resolve,
    repo_file,
    object_find
)

def find_common_ancestor(repo, commit1_sha, commit2_sha):
    def get_parents(sha):
        obj = object_read(repo, sha)
        if obj.fmt != b'commit':
            return []
        parents = obj.kvlm.get(b'parent', [])
        if isinstance(parents, bytes):
            return [parents.decode()]
        return [p.decode() for p in parents]

    visited = set()
    queue = [commit1_sha]

    while queue:
        current = queue.pop(0)
        visited.add(current)
        for parent in get_parents(current):
            if parent not in visited:
                queue.append(parent)

    queue = [commit2_sha]
    while queue:
        current = queue.pop(0)
        if current in visited:
            return current
        for parent in get_parents(current):
            queue.append(parent)

    return None

def merge_trees(base_tree, head_tree, other_tree):
    merged = {}
    conflicts = []

    base_entries = {i.path.decode(): i for i in base_tree.items}
    head_entries = {i.path.decode(): i for i in head_tree.items}
    other_entries = {i.path.decode(): i for i in other_tree.items}

    all_files = set(base_entries.keys()) | set(head_entries.keys()) | set(other_entries.keys())

    for f in sorted(all_files):
        base = base_entries.get(f)
        head = head_entries.get(f)
        other = other_entries.get(f)

        if head == other:
            merged[f] = head or base
        elif base == head and other:
            merged[f] = other
        elif base == other and head:
            merged[f] = head
        else:
            conflicts.append(f)
            merged[f] = head

    tree = GitTree(repo=None)
    tree.items = [GitTreeLeaf(item.mode, path.encode(), item.sha)
                  for path, item in merged.items() if item]
    return tree, conflicts

def cmd_merge(args):
    repo = repo_find()

    current_ref = ref_resolve(repo, "HEAD")
    other_ref = object_find(repo, args.branch)

    print(f"Merging branch '{args.branch}' into current branch...")

    current_commit = object_read(repo, current_ref)
    other_commit = object_read(repo, other_ref)

    base_sha = find_common_ancestor(repo, current_ref, other_ref)
    if not base_sha:
        print("No common ancestor found. Performing simple merge.")
        base_sha = current_ref

    base_commit = object_read(repo, base_sha)

    base_tree = object_read(repo, base_commit.kvlm[b'tree'].decode())
    head_tree = object_read(repo, current_commit.kvlm[b'tree'].decode())
    other_tree = object_read(repo, other_commit.kvlm[b'tree'].decode())

    merged_tree, conflicts = merge_trees(base_tree, head_tree, other_tree)
    tree_sha = object_write(merged_tree)

    commit = GitCommit(repo)
    commit.kvlm = collections.OrderedDict()
    commit.kvlm[b'tree'] = tree_sha.encode()
    commit.kvlm[b'parent'] = [current_ref.encode(), other_ref.encode()]
    commit.kvlm[b'author'] = b"Your Name <you@example.com> " + str(int(time.time())).encode()
    commit.kvlm[b'committer'] = commit.kvlm[b'author']
    commit.kvlm[b''] = b"Merge branch '" + args.branch.encode() + b"'"

    commit_sha = object_write(commit)

    head_path = repo_file(repo, "HEAD")
    ref_path = None
    with open(head_path) as f:
        ref_data = f.read().strip()
        if ref_data.startswith("ref: "):
            ref_path = repo_file(repo, ref_data[5:])

    if ref_path:
        with open(ref_path, "w") as f:
            f.write(commit_sha + "\n")

    print(f"Merge commit created: {commit_sha[:7]}")

    if conflicts:
        print("Conflicts detected in:")
        for f in conflicts:
            print(f"  {f}")
        print("\nPlease resolve manually.")
    else:
        print("Merge successful! No conflicts detected.")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Simplified merge command")
    parser.add_argument("branch", help="Branch name or commit to merge into current branch")
    args = parser.parse_args()
    cmd_merge(args)
