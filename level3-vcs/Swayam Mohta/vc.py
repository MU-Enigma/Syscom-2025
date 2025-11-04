import argparse
import collections
import configparser
import hashlib
import os
import fnmatch
import sys
import time
import zlib

  
# Base Git repository classes
  
class GitRepository:
    def __init__(self, path, force=False):
        self.worktree = path
        self.gitdir = os.path.join(path, ".git")
        if not (force or os.path.isdir(self.gitdir)):
            raise Exception(f"Not a Git repository: {path}")
        self.config = configparser.ConfigParser()
        config_file = repo_file(self, "config")
        if config_file and os.path.exists(config_file):
            self.config.read([config_file])
        elif not force:
            raise Exception("Configuration file missing")
        if not force:
            version = int(self.config.get("core", "repositoryformatversion"))
            if version != 0:
                raise Exception(f"Unsupported repositoryformatversion {version}")


class GitObject:
    def __init__(self, repo, data=None):
        self.repo = repo
        if data is not None:
            self.deserialize(data)

    def serialize(self):
        raise NotImplementedError

    def deserialize(self, data):
        raise NotImplementedError


class GitBlob(GitObject):
    fmt = b"blob"

    def serialize(self):
        return self.blobdata

    def deserialize(self, data):
        self.blobdata = data


class GitCommit(GitObject):
    fmt = b"commit"

    def __init__(self, repo, tree=None, parent=None, author=None, message=None):
        super().__init__(repo)
        self.kvlm = collections.OrderedDict()
        if tree:
            self.kvlm[b"tree"] = tree.encode()
        if parent:
            self.kvlm[b"parent"] = parent.encode()
        self.kvlm[b"author"] = author.encode() if author else b"Anonymous <anon>"
        self.kvlm[b"committer"] = author.encode() if author else b"Anonymous <anon>"
        self.kvlm[b""] = message.encode() if message else b""

    def serialize(self):
        result = b""
        for key, value in self.kvlm.items():
            if key == b"":
                continue
            values = value if isinstance(value, list) else [value]
            for val in values:
                result += key + b" " + val.replace(b"\n", b"\n ") + b"\n"
        result += b"\n" + self.kvlm[b""]
        return result

    def deserialize(self, data):
        self.kvlm = kvlm_parse(data)


class GitTreeLeaf:
    def __init__(self, mode, path, sha):
        self.mode = mode
        self.path = path
        self.sha = sha


class GitTree(GitObject):
    fmt = b"tree"

    def __init__(self, repo, data=None):
        super().__init__(repo, data)
        if data is None:
            self.items = []

    def serialize(self):
        result = b""
        for item in self.items:
            result += item.mode + b" " + item.path + b"\x00"
            sha_bytes = int(item.sha, 16).to_bytes(20, byteorder="big")
            result += sha_bytes
        return result

    def deserialize(self, data):
        self.items = tree_parse(data)


  
# Helper functions
  
def repo_path(repo, *paths):
    return os.path.join(repo.gitdir, *paths)


def repo_file(repo, *paths, mkdir=False):
    if repo_dir(repo, *paths[:-1], mkdir=mkdir):
        return repo_path(repo, *paths)


def repo_dir(repo, *paths, mkdir=False):
    path = repo_path(repo, *paths)
    if os.path.exists(path):
        if os.path.isdir(path):
            return path
        else:
            raise Exception(f"{path} is not a directory")
    if mkdir:
        os.makedirs(path)
        return path
    return None


def repo_create(path):
    repo = GitRepository(path, force=True)
    if os.path.exists(repo.worktree):
        if not os.path.isdir(repo.worktree):
            raise Exception(f"{path} is not a directory!")
        if os.listdir(repo.worktree):
            raise Exception(f"{path} is not empty!")
    else:
        os.makedirs(repo.worktree)
    assert repo_dir(repo, "branches", mkdir=True)
    assert repo_dir(repo, "objects", mkdir=True)
    assert repo_dir(repo, "refs", "tags", mkdir=True)
    assert repo_dir(repo, "refs", "heads", mkdir=True)
    with open(repo_file(repo, "description"), "w") as f:
        f.write("Unnamed repository; edit this file 'description' to name the repository.\n")
    with open(repo_file(repo, "HEAD"), "w") as f:
        f.write("ref: refs/heads/master\n")
    with open(repo_file(repo, "config"), "w") as f:
        config = repo_default_config()
        config.write(f)
    return repo


def repo_default_config():
    config = configparser.ConfigParser()
    config.add_section("core")
    config.set("core", "repositoryformatversion", "0")
    config.set("core", "filemode", "false")
    config.set("core", "bare", "false")
    return config


def repo_find(path=".", required=True):
    path = os.path.realpath(path)
    if os.path.isdir(os.path.join(path, ".git")):
        return GitRepository(path)
    parent = os.path.realpath(os.path.join(path, ".."))
    if parent == path:
        if required:
            raise Exception("No git directory found")
        else:
            return None
    return repo_find(parent, required)


def object_write(obj, actually_write=True):
    data = obj.serialize()
    header = obj.fmt + b" " + str(len(data)).encode() + b"\x00"
    full_data = header + data
    sha = hashlib.sha1(full_data).hexdigest()
    if actually_write:
        path = repo_file(obj.repo, "objects", sha[:2], sha[2:], mkdir=True)
        with open(path, "wb") as f:
            f.write(zlib.compress(full_data))
    return sha


def object_read(repo, sha):
    path = repo_file(repo, "objects", sha[:2], sha[2:])
    with open(path, "rb") as f:
        raw = zlib.decompress(f.read())
        fmt_end = raw.find(b" ")
        fmt = raw[:fmt_end]
        size_end = raw.find(b"\x00", fmt_end)
        size = int(raw[fmt_end + 1:size_end].decode("ascii"))
        if size != len(raw) - size_end - 1:
            raise Exception(f"Malformed object {sha}: bad length")
        if fmt == b"commit":
            cls = GitCommit
        elif fmt == b"tree":
            cls = GitTree
        elif fmt == b"blob":
            cls = GitBlob
        else:
            raise Exception(f"Unknown type {fmt.decode()}")
        return cls(repo, raw[size_end + 1:])


def kvlm_parse(raw, start=0, dct=None):
    if dct is None:
        dct = collections.OrderedDict()
    spc = raw.find(b" ", start)
    nl = raw.find(b"\n", start)
    if spc < 0 or nl < spc:
        assert nl == start
        dct[b""] = raw[start + 1:]
        return dct
    key = raw[start:spc]
    end = start
    while True:
        end = raw.find(b"\n", end + 1)
        if raw[end + 1] != ord(" "):
            break
    value = raw[spc + 1:end].replace(b"\n ", b"\n")
    if key in dct:
        if isinstance(dct[key], list):
            dct[key].append(value)
        else:
            dct[key] = [dct[key], value]
    else:
        dct[key] = value
    return kvlm_parse(raw, start=end + 1, dct=dct)


def tree_parse(raw):
    pos = 0
    items = []
    while pos < len(raw):
        x = raw.find(b" ", pos)
        y = raw.find(b"\x00", x)
        mode = raw[pos:x]
        path = raw[x + 1:y]
        sha = hex(int.from_bytes(raw[y + 1:y + 21], "big"))[2:]
        items.append(GitTreeLeaf(mode, path, sha))
        pos = y + 21
    return items


  
# Gitignore functions
  
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


  
# Command implementations
  
def cmd_init(args):
    repo_create(args.path)
    print(f"Initialized empty Git repository in {args.path}/.git")


def cmd_add(args):
    repo = repo_find()
    ignore_patterns = load_gitignore()
    paths = args.paths if hasattr(args, "paths") else [args.path]
    for path in paths:
        if os.path.isfile(path) and not is_ignored(path, ignore_patterns):
            with open(path, "rb") as f:
                data = f.read()
            sha = object_write(GitBlob(repo, data))
            print(f"added {path} ({sha})")


def cmd_commit(args):
    repo = repo_find()
    author = args.author if hasattr(args, "author") else "Anonymous <anon>"
    message = args.message if hasattr(args, "message") else "Commit message"
    tree = GitTree(repo)
    for f in os.listdir("."):
        if os.path.isfile(f) and f != ".git":
            with open(f, "rb") as fd:
                data = fd.read()
            sha = object_write(GitBlob(repo, data))
            tree.items.append(GitTreeLeaf(b"100644", f.encode(), sha))
    tree_sha = object_write(tree)
    head_file = repo_file(repo, "refs", "heads", "master")
    parent = open(head_file).read().strip() if os.path.exists(head_file) else None
    commit = GitCommit(repo, tree_sha, parent, author, message)
    commit_sha = object_write(commit)
    with open(head_file, "w") as f:
        f.write(commit_sha)
    print(f"Committed {commit_sha}")


def cmd_rm(args):
    paths = args.paths if hasattr(args, "paths") else [args.path]
    for f in paths:
        if os.path.exists(f):
            os.remove(f)
            print(f"removed {f}")
        else:
            print(f"{f} does not exist")


def cmd_status(args):
    repo = repo_find()
    ignore_patterns = load_gitignore()
    print("Ignored files:")
    for f in os.listdir("."):
        if is_ignored(f, ignore_patterns):
            print(f"  {f}")


  
# CLI argument parser
  
def main():
    parser = argparse.ArgumentParser(description="Minimal Git-like version control")
    subparsers = parser.add_subparsers(title="Commands", dest="command")

    parser_init = subparsers.add_parser("init")
    parser_init.add_argument("path", nargs="?", default=".")
    parser_init.set_defaults(func=cmd_init)

    parser_add = subparsers.add_parser("add")
    parser_add.add_argument("paths", nargs="+")
    parser_add.set_defaults(func=cmd_add)

    parser_commit = subparsers.add_parser("commit")
    parser_commit.add_argument("-m", "--message", required=True)
    parser_commit.add_argument("--author", default="Anonymous <anon>")
    parser_commit.set_defaults(func=cmd_commit)

    parser_rm = subparsers.add_parser("rm")
    parser_rm.add_argument("paths", nargs="+")
    parser_rm.set_defaults(func=cmd_rm)

    parser_status = subparsers.add_parser("status")
    parser_status.set_defaults(func=cmd_status)

    args = parser.parse_args()
    if hasattr(args, "func"):
        args.func(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
