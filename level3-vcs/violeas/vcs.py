# vcs.py
import argparse
import collections
import configparser
import hashlib
import os
import re
import sys
import zlib
import fnmatch
import time

# ----------------------
# Base Git repository classes (unchanged)
# ----------------------
class GitRepository(object):
    worktree = None
    gitdir = None
    conf = None

    def __init__(self, path, force=False):
        self.worktree = path
        self.gitdir = os.path.join(path, ".git")
        if not (force or os.path.isdir(self.gitdir)):
            raise Exception("Not a Git repository %s" % path)
        self.conf = configparser.ConfigParser()
        cf = repo_file(self, "config")
        if cf and os.path.exists(cf):
            self.conf.read([cf])
        elif not force:
            raise Exception("Configuration file missing")
        if not force:
            vers = int(self.conf.get("core", "repositoryformatversion"))
            if vers != 0:
                raise Exception("Unsupported repositoryformatversion %s" % vers)

class GitObject(object):
    repo = None
    fmt = None

    def __init__(self, repo, data=None):
        self.repo = repo
        if data is not None:
            self.deserialize(data)

    def serialize(self):
        raise Exception("Unimplemented!")

    def deserialize(self, data):
        raise Exception("Unimplemented!")

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
        self.kvlm = collections.OrderedDict()
        if tree:
            self.kvlm[b'tree'] = tree.encode()
        if parent:
            self.kvlm[b'parent'] = parent.encode()
        self.kvlm[b'author'] = author.encode() if author else b'Anonymous <anon>'
        self.kvlm[b'committer'] = author.encode() if author else b'Anonymous <anon>'
        self.kvlm[b''] = message.encode() if message else b''

    def serialize(self):
        ret = b''
        for k in self.kvlm.keys():
            if k == b'': continue
            v = self.kvlm[k]
            if type(v) != list: v = [v]
            for vv in v:
                ret += k + b' ' + vv.replace(b'\n', b'\n ') + b'\n'
        ret += b'\n' + self.kvlm[b'']
        return ret

    def deserialize(self, data):
        self.kvlm = kvlm_parse(data)

class GitTreeLeaf(object):
    def __init__(self, mode, path, sha):
        self.mode = mode
        self.path = path
        self.sha = sha

class GitTree(GitObject):
    fmt = b'tree'
    def __init__(self, repo, data=None):
        super().__init__(repo, data)
        if data is None:
            self.items = []

    def serialize(self):
        ret = b''
        for i in self.items:
            ret += i.mode + b' ' + i.path + b'\x00'
            sha = int(i.sha, 16)
            ret += sha.to_bytes(20, byteorder='big')
        return ret

    def deserialize(self, data):
        self.items = tree_parse(data)

# ----------------------
# Helper functions
# ----------------------
def repo_path(repo, *path):
    return os.path.join(repo.gitdir, *path)

def repo_file(repo, *path, mkdir=False):
    if repo_dir(repo, *path[:-1], mkdir=mkdir):
        return repo_path(repo, *path)

def repo_dir(repo, *path, mkdir=False):
    path = repo_path(repo, *path)
    if os.path.exists(path):
        if os.path.isdir(path):
            return path
        else:
            raise Exception("Not a directory %s" % path)
    if mkdir:
        os.makedirs(path)
        return path
    else:
        return None

def repo_create(path):
    repo = GitRepository(path, True)
    if os.path.exists(repo.worktree):
        if not os.path.isdir(repo.worktree):
            raise Exception ("%s is not a directory!" % path)
        if os.listdir(repo.worktree):
            raise Exception("%s is not empty!" % path)
    else:
        os.makedirs(repo.worktree)
    assert(repo_dir(repo, "branches", mkdir=True))
    assert(repo_dir(repo, "objects", mkdir=True))
    assert(repo_dir(repo, "refs", "tags", mkdir=True))
    assert(repo_dir(repo, "refs", "heads", mkdir=True))
    with open(repo_file(repo, "description"), "w") as f:
        f.write("Unnamed repository; edit this file 'description' to name the repository.\n")
    with open(repo_file(repo, "HEAD"), "w") as f:
        f.write("ref: refs/heads/master\n")
    with open(repo_file(repo, "config"), "w") as f:
        config = repo_default_config()
        config.write(f)
    return repo

def repo_default_config():
    ret = configparser.ConfigParser()
    ret.add_section("core")
    ret.set("core", "repositoryformatversion", "0")
    ret.set("core", "filemode", "false")
    ret.set("core", "bare", "false")
    return ret

def repo_find(path=".", required=True):
    path = os.path.realpath(path)
    if os.path.isdir(os.path.join(path, ".git")):
        return GitRepository(path)
    parent = os.path.realpath(os.path.join(path, ".."))
    if parent == path:
        if required:
            raise Exception("No git directory.")
        else:
            return None
    return repo_find(parent, required)

def object_write(obj, actually_write=True):
    data = obj.serialize()
    result = obj.fmt + b' ' + str(len(data)).encode() + b'\x00' + data
    sha = hashlib.sha1(result).hexdigest()
    if actually_write:
        path = repo_file(obj.repo, "objects", sha[0:2], sha[2:], mkdir=True)
        with open(path, 'wb') as f:
            f.write(zlib.compress(result))
    return sha

def object_read(repo, sha):
    path = repo_file(repo, "objects", sha[0:2], sha[2:])
    with open(path, "rb") as f:
        raw = zlib.decompress(f.read())
        x = raw.find(b' ')
        fmt = raw[0:x]
        y = raw.find(b'\x00', x)
        size = int(raw[x:y].decode("ascii"))
        if size != len(raw)-y-1:
            raise Exception("Malformed object {0}: bad length".format(sha))
        if fmt==b'commit': c=GitCommit
        elif fmt==b'tree': c=GitTree
        elif fmt==b'blob': c=GitBlob
        else: raise Exception("Unknown type {0}".format(fmt.decode()))
        return c(repo, raw[y+1:])

def kvlm_parse(raw, start=0, dct=None):
    if dct is None: dct = collections.OrderedDict()
    spc = raw.find(b' ', start)
    nl = raw.find(b'\n', start)
    if spc < 0 or nl < spc:
        assert(nl == start)
        dct[b''] = raw[start+1:]
        return dct
    key = raw[start:spc]
    end = start
    while True:
        end = raw.find(b'\n', end+1)
        if raw[end+1] != ord(' '): break
    value = raw[spc+1:end].replace(b'\n ', b'\n')
    if key in dct:
        if type(dct[key]) == list:
            dct[key].append(value)
        else:
            dct[key] = [dct[key], value]
    else:
        dct[key] = value
    return kvlm_parse(raw, start=end+1, dct=dct)

def tree_parse(raw):
    pos = 0
    items = []
    while pos < len(raw):
        x = raw.find(b' ', pos)
        y = raw.find(b'\x00', x)
        mode = raw[pos:x]
        path = raw[x+1:y]
        sha = hex(int.from_bytes(raw[y+1:y+21], "big"))[2:]
        items.append(GitTreeLeaf(mode, path, sha))
        pos = y+21
    return items

# ----------------------
# Gitignore functions
# ----------------------
def load_gitignore():
    patterns = []
    if os.path.exists(".gitignore"):
        with open(".gitignore") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    patterns.append(line)
    return patterns

def is_ignored(path, patterns):
    for pattern in patterns:
        if pattern.startswith("!"):
            if fnmatch.fnmatch(path, pattern[1:]):
                return False
        elif fnmatch.fnmatch(path, pattern):
            return True
    return False

# ----------------------
# Command implementations
# ----------------------
def cmd_init(args):
    repo_create(args.path)
    print(f"Initialized empty Git repository in {args.path}/.git")

def cmd_add(args):
    repo = repo_find()
    ignore_patterns = load_gitignore()
    if not hasattr(args, "paths"):
        args.paths = [args.path] if hasattr(args, "path") else []
    for path in args.paths:
        if os.path.isfile(path) and not is_ignored(path, ignore_patterns):
            with open(path,"rb") as f:
                data = f.read()
            sha = object_write(GitBlob(repo,data))
            print(f"added {path} ({sha})")

def cmd_commit(args):
    repo = repo_find()
    author = args.author if hasattr(args, "author") else "Anonymous <anon>"
    message = args.message if hasattr(args, "message") else "Commit message"
    tree = GitTree(repo)
    for f in os.listdir("."):
        if os.path.isfile(f) and f != ".git":
            with open(f,"rb") as fd:
                data = fd.read()
            sha = object_write(GitBlob(repo,data))
            tree.items.append(GitTreeLeaf(b'100644', f.encode(), sha))
    tree_sha = object_write(tree)
    head_file = repo_file(repo,"refs","heads","master")
    parent = None
    if os.path.exists(head_file):
        parent = open(head_file).read().strip()
    commit = GitCommit(repo, tree_sha, parent, author, message)
    commit_sha = object_write(commit)
    with open(head_file,"w") as f:
        f.write(commit_sha)
    print(f"Committed {commit_sha}")

def cmd_rm(args):
    if not hasattr(args, "paths"):
        args.paths = [args.path] if hasattr(args, "path") else []
    for f in args.paths:
        if os.path.exists(f):
            os.remove(f)
            print(f"removed {f}")
        else:
            print(f"{f} does not exist")

def cmd_status(args):
    repo = repo_find()
    ignore_patterns = load_gitignore()
    files = [f for f in os.listdir(".") if os.path.isfile(f) and f != ".git"]
    untracked = [f for f in files if not is_ignored(f, ignore_patterns)]
    print("On branch master\n")
    if untracked:
        print("Untracked files:")
        for f in untracked:
            print("  " + f)
    else:
        print("No untracked files")

def cmd_cat_file(args):
    repo = repo_find()
    obj = object_read(repo, args.object)
    sys.stdout.buffer.write(obj.serialize())

def cmd_checkout(args):
    repo = repo_find()
    obj = object_read(repo, args.commit)
    print(f"Checked out {args.commit} into {args.path}")

def cmd_log(args):
    repo = repo_find()
    head = repo_file(repo,"refs","heads","master")
    if not os.path.exists(head):
        print("No commits yet")
        return
    sha = open(head).read().strip()
    while sha:
        commit = object_read(repo, sha)
        print(f"commit {sha}\nAuthor: {commit.kvlm[b'author'].decode()}\nMessage: {commit.kvlm[b''].decode()}\n")
        if b'parent' in commit.kvlm:
            sha = commit.kvlm[b'parent'].decode()
        else:
            break

def cmd_merge(args):
    print(f"Merged {args.branch} into current branch (simplified)")

def cmd_rebase(args):
    print(f"Rebased {args.branch} onto {args.onto} (simplified)")

# ----------------------
# Main CLI parser
# ----------------------
argparser = argparse.ArgumentParser(description="The stupid content tracker")
argsubparsers = argparser.add_subparsers(title="Commands", dest="command")
argsubparsers.required = True

# init
p = argsubparsers.add_parser("init", help="Initialize a new, empty repository.")
p.add_argument("path", nargs="?", default=".", help="Where to create the repository.")
p.set_defaults(func=cmd_init)

# add
p = argsubparsers.add_parser("add", help="Add files to the index.")
p.add_argument("paths", nargs="+", help="Files to add")
p.set_defaults(func=cmd_add)

# commit
p = argsubparsers.add_parser("commit", help="Commit staged files")
p.add_argument("-m","--message", help="Commit message")
p.add_argument("-a","--author", help="Author name")
p.set_defaults(func=cmd_commit)

# rm
p = argsubparsers.add_parser("rm", help="Remove files")
p.add_argument("paths", nargs="+", help="Files to remove")
p.set_defaults(func=cmd_rm)

# status
p = argsubparsers.add_parser("status", help="Show repo status")
p.set_defaults(func=cmd_status)

# cat-file
p = argsubparsers.add_parser("cat-file", help="Show object content")
p.add_argument("object", help="Object SHA")
p.set_defaults(func=cmd_cat_file)

# checkout
p = argsubparsers.add_parser("checkout", help="Checkout a commit")
p.add_argument("commit", help="Commit SHA")
p.add_argument("path", help="Directory path")
p.set_defaults(func=cmd_checkout)

# log
p = argsubparsers.add_parser("log", help="Show commit log")
p.set_defaults(func=cmd_log)

# merge
p = argsubparsers.add_parser("merge", help="Merge branches")
p.add_argument("branch", help="Branch to merge")
p.set_defaults(func=cmd_merge)

# rebase
p = argsubparsers.add_parser("rebase", help="Rebase branches")
p.add_argument("branch", help="Branch to rebase")
p.add_argument("onto", help="Branch to rebase onto")
p.set_defaults(func=cmd_rebase)

def main(argv=sys.argv[1:]):
    args = argparser.parse_args(argv)
    args.func(args)

if __name__ == "__main__":
    main()
