import sys
import os
import time
import collections

def find_commit_ancestors(repo, start_sha):
    commits = []
    visited = set()
    stack = [start_sha]

    while stack:
        sha = stack.pop()
        if sha in visited:
            continue
        visited.add(sha)
        commits.append(sha)
        commit = object_read(repo, sha)
        parents = commit.kvlm.get(b'parent', [])
        if isinstance(parents, bytes):
            parents = [parents]
        for p in parents:
            stack.append(p.decode())
    return commits

def rebase_commits(repo, base_sha, onto_sha, commits_to_rebase):
    current_sha = onto_sha
    conflicts_occurred = False

    for commit_sha in reversed(commits_to_rebase):
        commit = object_read(repo, commit_sha)
        base_commit = object_read(repo, base_sha)

        base_tree = object_read(repo, base_commit.kvlm[b'tree'].decode())
        head_tree = object_read(repo, current_sha.kvlm[b'tree'].decode())
        commit_tree = object_read(repo, commit.kvlm[b'tree'].decode())

        merged_tree, conflicts = merge_trees(base_tree, head_tree, commit_tree)
        if conflicts:
            print(f"Conflicts detected when applying commit {commit_sha[:7]}:")
            for f in conflicts:
                print(f"  {f}")
            print("Rebase stopped. Please resolve conflicts manually.")
            conflicts_occurred = True
            break

        tree_sha = object_write(merged_tree)

        new_commit = GitCommit(repo)
        new_commit.kvlm = collections.OrderedDict()
        new_commit.kvlm[b'tree'] = tree_sha.encode()
        new_commit.kvlm[b'parent'] = [current_sha.encode()]
        new_commit.kvlm[b'author'] = commit.kvlm[b'author']
        new_commit.kvlm[b'committer'] = commit.kvlm.get(b'committer', commit.kvlm[b'author'])
        new_commit.kvlm[b''] = commit.kvlm[b'']

        new_commit_sha = object_write(new_commit)
        current_sha = new_commit_sha
        base_sha = commit_sha

    return current_sha, conflicts_occurred

def cmd_rebase(args):
    repo = repo_find()

    current_ref = ref_resolve(repo, "HEAD")
    onto_ref = object_find(repo, args.branch)

    print(f"Rebasing current branch onto '{args.branch}'")

    base_sha = find_common_ancestor(repo, current_ref, onto_ref)
    if not base_sha:
        print("No common ancestor found; cannot rebase.", file=sys.stderr)
        sys.exit(1)

    all_current_commits = find_commit_ancestors(repo, current_ref)
    if base_sha in all_current_commits:
        index = all_current_commits.index(base_sha)
        commits_to_rebase = all_current_commits[:index]
    else:
        commits_to_rebase = all_current_commits

    new_head_sha, conflicts = rebase_commits(repo, base_sha, onto_ref, commits_to_rebase)

    if conflicts:
        print("Rebase aborted due to conflicts.")
        sys.exit(1)

    head_path = repo_file(repo, "HEAD")
    ref_path = None
    with open(head_path) as f:
        ref_data = f.read().strip()
        if ref_data.startswith("ref: "):
            ref_path = repo_file(repo, ref_data[5:])

    if ref_path:
        with open(ref_path, "w") as f:
            f.write(new_head_sha + "\n")

    print(f"Rebase complete! HEAD is now at {new_head_sha[:7]}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Simplified rebase command")
    parser.add_argument("branch", help="Branch or commit to rebase onto")
    args = parser.parse_args()
    cmd_rebase(args)
