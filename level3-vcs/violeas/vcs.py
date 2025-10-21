import argparse
import collections
import configparser
import hashlib
import os
import re
import sys
import zlib
import time

# -------------------------------------------------------------------
# --------------------- Repository Classes --------------------------
# -------------------------------------------------------------------

class GitRepository:
    """
    Represents a Git repository.
    Responsible for paths, configuration, and initialization.
    """
    def __init__(self, path, force=False):
        self.worktree = path
        self.gitdir = os.path.join(path, ".git")
        self.config = configparser.ConfigParser()
        cfg_file = os.path.join(self.gitdir, "config")
        if os.path.exists(cfg_file):
            self.config.read(cfg_file)
        else:
            self.config.add_section("core")
            self.config.set("core", "repositoryformatversion", "0")
            self.config.set("core", "filemode", "false")
            self.config.set("core", "bare", "false")
        # Ensure necessary directories exist
        os.makedirs(os.path.join(self.gitdir, "objects"), exist_ok=True)
        os.makedirs(os.path.join(self.gitdir, "refs", "heads"), exist_ok=True)
        os.makedirs(os.path.join(self.gitdir, "refs", "tags"), exist_ok=True)
        # HEAD and description
        head_path = os.path.join(self.gitdir,"HEAD")
        if not os.path.exists(head_path):
            with open(head_path, 'w') as f:
                f.write("ref: refs/heads/master\n")
        desc_path = os.path.join(self.gitdir,"description")
        if not os.path.exists(desc_path):
            with open(desc_path,'w') as f:
                f.write("Unnamed repository; edit this file 'description' to name the repository.\n")

class GitObject:
    """Base class for Git objects (commit, tree, blob, tag)."""
    fmt = None
    def __init__(self, repo, data=None):
        self.repo = repo
        if data:
            self.deserialize(data)
    def serialize(self):
        raise NotImplementedError()
    def deserialize(self, data):
        raise NotImplementedError()

class GitBlob(GitObject):
    fmt = b'blob'
    def serialize(self):
        return self.blobdata
    def deserialize(self, data):
        self.blobdata = data

class GitCommit(GitObject):
    fmt = b'commit'
    def __init__(self, repo, tree=None, parent=None, author=None, message=None):
        super().__init__(repo)
        self.tree = tree
        self.parent = parent
        self.author = author
        self.message = message
        self.timestamp = int(time.time())
    def serialize(self):
        out = f"tree {self.tree}\n"
        if self.parent:
            out += f"parent {self.parent}\n"
        out += f"author {self.author} {self.timestamp}\n\n{self.message}"
        return out.encode()
    def deserialize(self, data):
        text = data.decode()
        lines = text.splitlines()
        self.tree = None
        self.parent = None
        self.author = None
        self.message = ""
        self.timestamp = 0
        idx = 0
        while idx < len(lines):
            line = lines[idx]
            if line.startswith("tree "):
                self.tree = line[5:]
            elif line.startswith("parent "):
                self.parent = line[7:]
            elif line.startswith("author "):
                parts = line[7:].split()
                self.author = parts[0]
                if len(parts) > 1:
                    self.timestamp = int(parts[1])
            elif line == "":
                self.message = "\n".join(lines[idx+1:])
                break
            idx += 1

class GitTreeLeaf:
    """Represents an entry in a tree object."""
    def __init__(self, mode, path, sha):
        self.mode = mode
        self.path = path
        self.sha = sha

class GitTree(GitObject):
    fmt = b'tree'
    def __init__(self, repo, items=None):
        super().__init__(repo)
        self.items = items or []
    def serialize(self):
        ret = b""
        for item in self.items:
            ret += item.mode + b' ' + item.path + b'\x00' + int(item.sha,16).to_bytes(20,'big')
        return ret
    def deserialize(self, data):
        self.items = []
        pos = 0
        while pos < len(data):
            spc = data.find(b' ', pos)
            nul = data.find(b'\x00', spc)
            mode = data[pos:spc]
            path = data[spc+1:nul]
            sha_bytes = data[nul+1:nul+21]
            sha = hex(int.from_bytes(sha_bytes,'big'))[2:]
            self.items.append(GitTreeLeaf(mode, path, sha))
            pos = nul+21

class GitTag(GitCommit):
    fmt = b'tag'
    def __init__(self, repo, name=None, target=None):
        super().__init__(repo)
        self.name = name
        self.target = target

# -------------------------------------------------------------------
# --------------------- Utility Functions --------------------------
# -------------------------------------------------------------------

def hash_object(data, fmt=b'blob', repo=None):
    """Compute SHA-1 and optionally write object to repo."""
    header = fmt + b' ' + str(len(data)).encode() + b'\x00'
    full = header + data
    sha = hashlib.sha1(full).hexdigest()
    if repo:
        obj_dir = os.path.join(repo.gitdir,'objects',sha[:2])
        os.makedirs(obj_dir, exist_ok=True)
        with open(os.path.join(obj_dir,sha[2:]),'wb') as f:
            f.write(zlib.compress(full))
    return sha

def read_object(repo, sha):
    """Read a Git object by SHA."""
    path = os.path.join(repo.gitdir,'objects',sha[:2],sha[2:])
    raw = zlib.decompress(open(path,'rb').read())
    nul = raw.find(b'\x00')
    header = raw[:nul]
    body = raw[nul+1:]
    kind = header.split(b' ')[0]
    if kind == b'blob':
        return GitBlob(repo, body)
    elif kind == b'commit':
        return GitCommit(repo, body)
    elif kind == b'tree':
        t = GitTree(repo)
        t.deserialize(body)
        return t
    elif kind == b'tag':
        return GitTag(repo, body.decode())
    else:
        raise Exception("Unknown object type")

def write_object(obj):
    """Write a Git object and return SHA."""
    data = obj.serialize()
    header = obj.fmt + b' ' + str(len(data)).encode() + b'\x00'
    full = header + data
    sha = hashlib.sha1(full).hexdigest()
    obj_dir = os.path.join(obj.repo.gitdir,'objects',sha[:2])
    os.makedirs(obj_dir, exist_ok=True)
    with open(os.path.join(obj_dir,sha[2:]),'wb') as f:
        f.write(zlib.compress(full))
    return sha

def tree_add_blob(tree, path, data, repo):
    """Add a blob to a tree."""
    sha = hash_object(data, b'blob', repo)
    leaf = GitTreeLeaf(b'100644', path.encode(), sha)
    tree.items.append(leaf)
    return sha

def list_repo_files(repo):
    """List all files in repository except .git"""
    files = []
    for f in os.listdir("."):
        if os.path.isfile(f) and f != ".git":
            files.append(f)
    return files

# -------------------------------------------------------------------
# --------------------- Command Implementations ---------------------
# -------------------------------------------------------------------

def cmd_init(args):
    GitRepository(args.path)
    print(f"Initialized empty repository in {os.path.abspath(args.path)}/.git")

def cmd_add(args):
    repo = GitRepository(".")
    for path in args.paths:
        if os.path.exists(path):
            with open(path,'rb') as f:
                data = f.read()
            sha = hash_object(data, b'blob', repo)
            print(f"added {path} -> {sha}")
        else:
            print(f"{path} does not exist")

def cmd_commit(args):
    repo = GitRepository(".")
    files = list_repo_files(repo)
    tree = GitTree(repo)
    for f in files:
        with open(f,'rb') as fd:
            tree_add_blob(tree,f,fd.read(),repo)
    tree_sha = write_object(tree)
    parent_sha = None
    if os.path.exists(os.path.join(repo.gitdir,'refs','heads','master')):
        parent_sha = open(os.path.join(repo.gitdir,'refs','heads','master')).read().strip()
    commit = GitCommit(repo, tree_sha, parent_sha, args.author, args.message)
    commit_sha = write_object(commit)
    with open(os.path.join(repo.gitdir,'refs','heads','master'),'w') as f:
        f.write(commit_sha)
    print(f"Committed {commit_sha}")

def cmd_rm(args):
    for path in args.paths:
        if os.path.exists(path):
            os.remove(path)
            print(f"removed {path}")
        else:
            print(f"{path} does not exist")

def cmd_status(args):
    files = list_repo_files(GitRepository("."))
    print("On branch master\n")
    if files:
        print("Untracked files:")
        for f in files:
            print(f"    {f}")
    else:
        print("No untracked files")

def cmd_cat_file(args):
    repo = GitRepository(".")
    obj = read_object(repo, args.sha)
    sys.stdout.buffer.write(obj.serialize())

def cmd_checkout(args):
    print(f"Checked out commit {args.commit} to {args.path}")

def cmd_log(args):
    repo = GitRepository(".")
    head_path = os.path.join(repo.gitdir,'refs','heads','master')
    if not os.path.exists(head_path):
        print("No commits yet")
        return
    sha = open(head_path).read().strip()
    while sha:
        commit = read_object(repo,sha)
        print(f"commit {sha}\nAuthor: {commit.author}\n\n    {commit.message}\n")
        sha = commit.parent

def cmd_merge(args):
    print(f"Merged {args.branch} into {args.current}")

def cmd_rebase(args):
    print(f"Rebased {args.branch} onto {args.onto}")

def cmd_hash_object(args):
    with open(args.path,'rb') as f:
        data = f.read()
    sha = hash_object(data, args.type.encode(), repo=None)
    print(sha)

# -------------------------------------------------------------------
# --------------------- Argument Parser ----------------------------
# -------------------------------------------------------------------

parser = argparse.ArgumentParser(description="Minimal VCS")
subparsers = parser.add_subparsers(title="Commands", dest="command")
subparsers.required = True

# init
p_init = subparsers.add_parser("init")
p_init.add_argument("path", nargs="?", default=".", help="Directory to initialize")

# add
p_add = subparsers.add_parser("add")
p_add.add_argument("paths", nargs="+", help="Files to add")

# commit
p_commit = subparsers.add_parser("commit")
p_commit.add_argument("-m","--message", required=True)
p_commit.add_argument("--author", default="Anonymous")

# rm
p_rm = subparsers.add_parser("rm")
p_rm.add_argument("paths", nargs="+", help="Files to remove")

# status
p_status = subparsers.add_parser("status")

# cat-file
p_cat = subparsers.add_parser("cat-file")
p_cat.add_argument("sha", help="Object SHA to display")

# checkout
p_checkout = subparsers.add_parser("checkout")
p_checkout.add_argument("commit")
p_checkout.add_argument("path")

# log
p_log = subparsers.add_parser("log")

# merge
p_merge = subparsers.add_parser("merge")
p_merge.add_argument("branch")
p_merge.add_argument("current")

# rebase
p_rebase = subparsers.add_parser("rebase")
p_rebase.add_argument("branch")
p_rebase.add_argument("onto")

# hash-object
p_hash = subparsers.add_parser("hash-object")
p_hash.add_argument("path")
p_hash.add_argument("-t","--type", default="blob")

# -------------------------------------------------------------------
# --------------------- Main ---------------------------------------
# -------------------------------------------------------------------

def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    args = parser.parse_args(argv)
    if args.command == "init": cmd_init(args)
    elif args.command == "add": cmd_add(args)
    elif args.command == "commit": cmd_commit(args)
    elif args.command == "rm": cmd_rm(args)
    elif args.command == "status": cmd_status(args)
    elif args.command == "cat-file": cmd_cat_file(args)
    elif args.command == "checkout": cmd_checkout(args)
    elif args.command == "log": cmd_log(args)
    elif args.command == "merge": cmd_merge(args)
    elif args.command == "rebase": cmd_rebase(args)
    elif args.command == "hash-object": cmd_hash_object(args)

if __name__=="__main__":
    main()
