# vcs.py — Level 4 improved version
# Implements a small Git-like VCS with many Level-3 and Level-4 fixes & features.

import argparse
import collections
import configparser
import hashlib
import os
import re
import sys
import time
import zlib
import fnmatch

# -----------------------------
# Argument Parser
# -----------------------------
argparser = argparse.ArgumentParser(description="The stupid content tracker")
argsubparsers = argparser.add_subparsers(title="Commands", dest="command")
argsubparsers.required = True

# -----------------------------
# Repository Class
# -----------------------------
class GitRepository(object):
    worktree = None
    gitdir = None
    conf = None

    def __init__(self, path, force=False):
        self.worktree = path
        self.gitdir = os.path.join(path, ".git")

        if not (force or os.path.isdir(self.gitdir)):
            raise Exception("Not a Git repository %s" % path)

        # Read configuration file in .git/config
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

# -----------------------------
# Repo helpers
# -----------------------------
def repo_path(repo, *path):
    return os.path.join(repo.gitdir, *path)

def repo_file(repo, *path, mkdir=False):
    # create parent directories as needed
    if repo_dir(repo, *path[:-1], mkdir=mkdir):
        return repo_path(repo, *path)

def repo_dir(repo, *path, mkdir=False):
    p = repo_path(repo, *path)
    if os.path.exists(p):
        if os.path.isdir(p):
            return p
        else:
            raise Exception("Not a directory %s" % p)
    if mkdir:
        os.makedirs(p, exist_ok=True)
        return p
    else:
        return None

def repo_create(path):
    repo = GitRepository(path, True)

    # validate working tree
    if os.path.exists(repo.worktree):
        if not os.path.isdir(repo.worktree):
            raise Exception("%s is not a directory!" % path)
        if os.listdir(repo.worktree):
            raise Exception("%s is not empty!" % path)
    else:
        os.makedirs(repo.worktree)

    # create git hierarchy
    assert(repo_dir(repo, "branches", mkdir=True))
    assert(repo_dir(repo, "objects", mkdir=True))
    assert(repo_dir(repo, "refs", "tags", mkdir=True))
    assert(repo_dir(repo, "refs", "heads", mkdir=True))

    # description
    with open(repo_file(repo, "description"), "w") as f:
        f.write("Unnamed repository; edit this file 'description' to name the repository.\n")

    # HEAD
    with open(repo_file(repo, "HEAD"), "w") as f:
        f.write("ref: refs/heads/master\n")

    # config
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

# -----------------------------
# Git Object Classes
# -----------------------------
class GitObject(object):
    repo = None
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

class GitTreeLeaf(object):
    def __init__(self, mode, path, sha):
        self.mode = mode    # bytes
        self.path = path    # bytes
        self.sha  = sha     # hex str

class GitTree(GitObject):
    fmt = b'tree'
    def deserialize(self, data):
        self.items = tree_parse(data)
    def serialize(self):
        return tree_serialize(self)

class GitCommit(GitObject):
    fmt = b'commit'
    def deserialize(self, data):
        self.kvlm = kvlm_parse(data)
    def serialize(self):
        return kvlm_serialize(self.kvlm)

class GitTag(GitCommit):
    fmt = b'tag'

# -----------------------------
# Object IO
# -----------------------------
def object_write(obj, actually_write=True):
    data = obj.serialize()
    header = obj.fmt + b' ' + str(len(data)).encode() + b'\x00'
    full = header + data
    sha = hashlib.sha1(full).hexdigest()
    if actually_write:
        path = repo_file(obj.repo, "objects", sha[0:2], sha[2:], mkdir=True)
        with open(path, "wb") as f:
            f.write(zlib.compress(full))
    return sha

def object_read(repo, sha):
    path = repo_file(repo, "objects", sha[0:2], sha[2:])
    if not path or not os.path.exists(path):
        raise Exception("Object %s not found" % sha)
    with open(path, "rb") as f:
        raw = zlib.decompress(f.read())
    x = raw.find(b' ')
    fmt = raw[0:x]
    y = raw.find(b'\x00', x)
    size = int(raw[x+1:y].decode("ascii"))
    body = raw[y+1:]
    if size != len(body):
        raise Exception("Malformed object %s: bad length" % sha)
    if fmt == b'blob':
        return GitBlob(repo, body)
    elif fmt == b'tree':
        return GitTree(repo, body)
    elif fmt == b'commit':
        return GitCommit(repo, body)
    elif fmt == b'tag':
        return GitTag(repo, body)
    else:
        raise Exception("Unknown type %s for object %s" % (fmt.decode("ascii"), sha))

def object_hash(fd, fmt, repo=None):
    data = fd.read()
    if fmt == b'blob':
        obj = GitBlob(repo, data)
    elif fmt == b'commit':
        obj = GitCommit(repo, data)
    elif fmt == b'tree':
        obj = GitTree(repo, data)
    elif fmt == b'tag':
        obj = GitTag(repo, data)
    else:
        raise Exception("Unknown type %s!" % fmt)
    return object_write(obj, actually_write=(repo is not None))

# -----------------------------
# KVLM (key-value with message) parsing
# -----------------------------
def kvlm_parse(raw, start=0, dct=None):
    if dct is None:
        dct = collections.OrderedDict()

    spc = raw.find(b' ', start)
    nl = raw.find(b'\n', start)

    if (spc < 0) or (nl < spc):
        # base case: message follows a blank line
        assert (nl == start)
        dct[b''] = raw[start+1:]
        return dct

    key = raw[start:spc]
    end = start
    while True:
        end = raw.find(b'\n', end + 1)
        if end + 1 >= len(raw) or raw[end+1] != ord(' '):
            break

    value = raw[spc+1:end].replace(b'\n ', b'\n')

    if key in dct:
        if isinstance(dct[key], list):
            dct[key].append(value)
        else:
            dct[key] = [dct[key], value]
    else:
        dct[key] = value

    return kvlm_parse(raw, start=end+1, dct=dct)

def kvlm_serialize(kvlm):
    ret = b''
    for k in kvlm.keys():
        if k == b'':
            continue
        val = kvlm[k]
        if not isinstance(val, list):
            val = [val]
        for v in val:
            # continuation lines start with a space
            ret += k + b' ' + (v.replace(b'\n', b'\n ')) + b'\n'
    ret += b'\n' + kvlm[b'']
    return ret

# -----------------------------
# Tree parse/serialize
# -----------------------------
def tree_parse_one(raw, start=0):
    x = raw.find(b' ', start)
    # mode field length can be 5 (100644 etc) or 6 (100755 vs 100644 - edge), assert loosely
    assert (x - start == 5 or x - start == 6)
    mode = raw[start:x]
    y = raw.find(b'\x00', x)
    path = raw[x+1:y]
    sha = raw[y+1:y+21]
    # convert to hex string
    sha_hex = sha.hex()
    return y+21, GitTreeLeaf(mode, path, sha_hex)

def tree_parse(raw):
    pos = 0
    maxlen = len(raw)
    ret = []
    while pos < maxlen:
        pos, leaf = tree_parse_one(raw, pos)
        ret.append(leaf)
    return ret

def tree_serialize(obj):
    parts = []
    # more efficient: build list of bytes then join
    for item in obj.items:
        parts.append(item.mode + b' ' + item.path + b'\x00' + int(item.sha, 16).to_bytes(20, byteorder='big'))
    return b''.join(parts)

# -----------------------------
# Index (.git/index) handling
# -----------------------------
# Simple line-based index: "<mode> <sha> <path>\n"
INDEX = "index"
def read_index(repo):
    idx_file = repo_file(repo, INDEX)
    entries = collections.OrderedDict()
    if idx_file and os.path.exists(idx_file):
        with open(idx_file, "r") as f:
            for line in f:
                line = line.rstrip("\n")
                if not line:
                    continue
                try:
                    mode, sha, path = line.split(" ", 2)
                    entries[path] = (mode, sha)
                except ValueError:
                    # ignore malformed lines
                    continue
    return entries

def write_index(repo, entries):
    idx_file = repo_file(repo, INDEX, mkdir=True)
    with open(idx_file, "w") as f:
        for path, (mode, sha) in entries.items():
            f.write(f"{mode} {sha} {path}\n")

# -----------------------------
# .gitignore support (simple)
# -----------------------------
def read_gitignore(repo):
    gitignore = []
    p = os.path.join(repo.worktree, ".gitignore")
    if os.path.exists(p):
        with open(p, "r") as f:
            for raw in f:
                s = raw.strip()
                if not s or s.startswith("#"):
                    continue
                gitignore.append(s)
    return gitignore

def match_gitignore(relpath, patterns):
    # process patterns in order: negations (!) override previous matches
    matched = False
    for pat in patterns:
        if pat.startswith("!"):
            try:
                if fnmatch.fnmatch(relpath, pat[1:]):
                    matched = False
            except:
                continue
        else:
            try:
                if fnmatch.fnmatch(relpath, pat):
                    matched = True
            except:
                continue
    return matched

# -----------------------------
# References helpers
# -----------------------------
def ref_resolve(repo, ref):
    # ref can be a path or a ref file
    refpath = repo_file(repo, ref)
    if not refpath or not os.path.exists(refpath):
        # if ref is a file-like path already:
        if os.path.exists(ref):
            with open(ref, "r") as f:
                return f.read().strip()
        raise Exception("Reference %s not found" % ref)
    with open(refpath, "r") as fp:
        data = fp.read().strip()
    if data.startswith("ref: "):
        return ref_resolve(repo, data[5:])
    else:
        return data

def ref_list(repo, path=None):
    if path is None:
        path = repo_dir(repo, "refs")
    ret = collections.OrderedDict()
    if not path:
        return ret
    for f in sorted(os.listdir(path)):
        can = os.path.join(path, f)
        if os.path.isdir(can):
            ret[f] = ref_list(repo, can)
        else:
            # store the resolved hash
            try:
                ret[f] = ref_resolve(repo, os.path.join(path, f))
            except:
                ret[f] = None
    return ret

def show_ref(repo, refs, with_hash=True, prefix=""):
    for k, v in refs.items():
        if isinstance(v, dict):
            show_ref(repo, v, with_hash=with_hash, prefix=prefix + ("/" if prefix else "") + k)
        else:
            if with_hash:
                print(f"{v} {prefix + ('/' if prefix else '') + k}")
            else:
                print(prefix + ("/" if prefix else "") + k)

# -----------------------------
# Object name resolution
# -----------------------------
def object_resolve(repo, name):
    candidates = []
    name = name.strip()
    if not name:
        return []
    if name == "HEAD":
        try:
            return [ref_resolve(repo, "HEAD")]
        except:
            return []
    hashRE = re.compile(r"^[0-9A-Fa-f]{4,40}$")
    if hashRE.match(name):
        if len(name) == 40:
            return [name.lower()]
        # short hash
        prefix = name[:2].lower()
        rem = name[2:].lower()
        path = repo_dir(repo, "objects", prefix)
        if path:
            for f in os.listdir(path):
                if f.startswith(rem):
                    candidates.append(prefix + f)
    # branches & tags
    # Try refs/heads and refs/tags
    for ref_dir in ["refs/heads", "refs/tags", "refs"]:
        refpath = repo_dir(repo, ref_dir)
        if not refpath:
            continue
        for root, _, files in os.walk(refpath):
            for fn in files:
                full = os.path.join(root, fn)
                rel = os.path.relpath(full, repo.gitdir)
                if rel.endswith(name):
                    try:
                        candidates.append(ref_resolve(repo, rel))
                    except:
                        pass
    return list(dict.fromkeys(candidates))

def object_find(repo, name, fmt=None, follow=True):
    shas = object_resolve(repo, name)
    if not shas:
        raise Exception("No such reference %s." % name)
    if len(shas) > 1:
        raise Exception("Ambiguous reference %s: Candidates are:\n - %s." % (name, "\n - ".join(shas)))
    sha = shas[0]
    if not fmt:
        return sha
    while True:
        obj = object_read(repo, sha)
        if obj.fmt == fmt:
            return sha
        if not follow:
            return None
        if obj.fmt == b'tag':
            sha = obj.kvlm[b'object'].decode("ascii")
        elif obj.fmt == b'commit' and fmt == b'tree':
            sha = obj.kvlm[b'tree'].decode("ascii")
        else:
            return None

# -----------------------------
# Commands implementations
# -----------------------------
# init
argsp = argsubparsers.add_parser("init", help="Initialize a new, empty repository.")
argsp.add_argument("path", metavar="directory", nargs="?", default=".", help="Where to create the repository.")
def cmd_init(args):
    repo_create(args.path)
    print("Initialized empty repository at %s" % os.path.abspath(args.path))

# hash-object
argsp = argsubparsers.add_parser("hash-object", help="Compute object ID and optionally creates a blob from a file")
argsp.add_argument("-t", metavar="type", dest="type", choices=["blob", "commit", "tag", "tree"], default="blob", help="Specify the type")
argsp.add_argument("-w", dest="write", action="store_true", help="Actually write the object into the database")
argsp.add_argument("path", help="Read object from <file>")
def cmd_hash_object(args):
    repo = GitRepository(".", False) if args.write else None
    with open(args.path, "rb") as fd:
        sha = object_hash(fd, args.type.encode(), repo)
        print(sha)

# cat-file
argsp = argsubparsers.add_parser("cat-file", help="Provide content of repository objects")
argsp.add_argument("type", metavar="type", choices=["blob", "commit", "tag", "tree"], help="Specify the type")
argsp.add_argument("object", metavar="object",help="The object to display")
def cmd_cat_file(args):
    repo = repo_find()
    sha = object_find(repo, args.object, fmt=args.type.encode())
    obj = object_read(repo, sha)
    if args.type == "blob":
        sys.stdout.buffer.write(obj.serialize())
    elif args.type == "tree":
        for item in obj.items:
            print(f"{item.mode.decode('ascii')} {object_read(repo, item.sha).fmt.decode('ascii')} {item.sha}\t{item.path.decode('utf-8')}")
    elif args.type == "commit":
        kvlm = obj.kvlm
        for k, v in kvlm.items():
            if k == b'':
                print()
                print(v.decode('utf-8'))
            else:
                if isinstance(v, list):
                    for vv in v:
                        print(k.decode('ascii'), vv.decode('utf-8'))
                else:
                    print(k.decode('ascii'), v.decode('utf-8'))
    else:
        # tag: reuse commit pretty printing
        kvlm = obj.kvlm
        for k, v in kvlm.items():
            if k == b'':
                print()
                print(v.decode('utf-8'))
            else:
                if isinstance(v, list):
                    for vv in v:
                        print(k.decode('ascii'), vv.decode('utf-8'))
                else:
                    print(k.decode('ascii'), v.decode('utf-8'))

# rev-parse
argsp = argsubparsers.add_parser("rev-parse", help="Parse revision (or other objects )identifiers")
argsp.add_argument("--wyag-type", metavar="type", dest="type", choices=["blob", "commit", "tag", "tree"], default=None, help="Specify the expected type")
argsp.add_argument("name", help="The name to parse")
def cmd_rev_parse(args):
    repo = repo_find()
    fmt = args.type.encode() if args.type else None
    print(object_find(repo, args.name, fmt, follow=True))

# add
argsp = argsubparsers.add_parser("add", help="Add file(s) to the index")
argsp.add_argument("paths", nargs="+", help="File(s) or directories to add")
def cmd_add(args):
    repo = repo_find()
    gitignore = read_gitignore(repo)
    index = read_index(repo)

    def add_file(abs_path):
        if not os.path.exists(abs_path):
            print(f"warning: {abs_path} does not exist; skipped")
            return
        if os.path.isdir(abs_path):
            # recurse
            for root, dirs, files in os.walk(abs_path):
                # skip ignored dirs
                relroot = os.path.relpath(root, repo.worktree)
                if match_gitignore(relroot, gitignore):
                    dirs[:] = []
                    continue
                for fn in files:
                    add_file(os.path.join(root, fn))
            return
        rel = os.path.relpath(abs_path, repo.worktree)
        if match_gitignore(rel, gitignore):
            # ignored
            return
        with open(abs_path, "rb") as fd:
            sha = object_hash(fd, b'blob', repo)
        # file mode (simple)
        mode = "100644"
        index[rel.replace(os.sep, "/")] = (mode, sha)

    for p in args.paths:
        abs_p = os.path.join(repo.worktree, p)
        if not os.path.exists(abs_p):
            print(f"warning: {p} does not exist; skipped")
            continue
        add_file(abs_p)

    write_index(repo, index)
    print("Added to index.")

# commit
argsp = argsubparsers.add_parser("commit", help="Commit staged changes")
argsp.add_argument("-m", "--message", required=True, help="Commit message")
argsp.add_argument("-a", "--author", default="anonymous <anon@example.com>", help="Author")
def cmd_commit(args):
    repo = repo_find()
    index = read_index(repo)
    if not index:
        print("Nothing to commit.")
        return

    # Build tree structure from index entries
    # nested dicts: { 'dir': { ... }, 'file': (mode, sha) }
    tree_dict = {}
    for path, (mode, sha) in index.items():
        parts = path.split("/")
        cur = tree_dict
        for p in parts[:-1]:
            cur = cur.setdefault(p, {})
        cur[parts[-1]] = (mode, sha)

    # recursive function to create tree objects
    def build_tree(obj_dict):
        items = []
        for name, value in sorted(obj_dict.items()):
            if isinstance(value, tuple):
                mode, sha = value
                items.append(GitTreeLeaf(mode.encode(), name.encode(), sha))
            else:
                # subtree
                subtree = build_tree(value)
                sha_sub = object_write(subtree, actually_write=True)
                items.append(GitTreeLeaf(b'40000', name.encode(), sha_sub))
        tree = GitTree(repo)
        tree.items = items
        return tree

    root_tree = build_tree(tree_dict)
    tree_sha = object_write(root_tree, actually_write=True)

    # build commit
    commit = GitCommit(repo)
    commit.kvlm = collections.OrderedDict()
    commit.kvlm[b'tree'] = tree_sha.encode('ascii')
    # parent
    try:
        parent = ref_resolve(repo, "HEAD")
        if parent:
            commit.kvlm[b'parent'] = parent.encode('ascii')
    except Exception:
        # no parent found, initial commit
        pass
    timestamp = int(time.time())
    commit.kvlm[b'author'] = (args.author + " " + str(timestamp) + " +0000").encode('utf-8')
    commit.kvlm[b''] = args.message.encode('utf-8')
    commit_sha = object_write(commit, actually_write=True)

    # update HEAD ref (it contains "ref: refs/heads/..." => resolve file path)
    head_ref_path = repo_file(repo, "HEAD")
    with open(head_ref_path, "r") as f:
        data = f.read().strip()
    if data.startswith("ref: "):
        refname = data[5:]
        with open(repo_file(repo, refname), "w") as rf:
            rf.write(commit_sha + "\n")
    else:
        # HEAD directly contains sha (detached HEAD). Overwrite.
        with open(head_ref_path, "w") as hf:
            hf.write(commit_sha + "\n")

    # Clear index after commit (simulate git behavior)
    write_index(repo, collections.OrderedDict())
    print(f"[{commit_sha}] {args.message}")

# status
argsp = argsubparsers.add_parser("status", help="Show repository status")
def cmd_status(args):
    repo = repo_find()
    index = read_index(repo)
    staged = set(index.keys())
    # find tracked files from HEAD tree
    tracked = set()
    try:
        head_sha = ref_resolve(repo, "HEAD")
        if head_sha:
            commit = object_read(repo, head_sha)
            if isinstance(commit, GitCommit) and b'tree' in commit.kvlm:
                tree_sha = commit.kvlm[b'tree'].decode('ascii')
                tracked = set(list_files_in_tree(repo, tree_sha))
    except Exception:
        tracked = set()

    # scan working directory
    untracked = []
    modified = []
    gitignore = read_gitignore(repo)
    for root, _, files in os.walk(repo.worktree):
        # skip .git
        if os.path.abspath(root).startswith(os.path.abspath(repo.gitdir)):
            continue
        for fname in files:
            absf = os.path.join(root, fname)
            rel = os.path.relpath(absf, repo.worktree).replace(os.sep, "/")
            if match_gitignore(rel, gitignore):
                continue
            if rel in staged:
                # compare blob hash
                try:
                    with open(absf, "rb") as fd:
                        sha = object_hash(fd, b'blob', repo=None)  # don't write
                    if index[rel][1] != sha:
                        modified.append(rel)
                except:
                    continue
            elif rel in tracked:
                # compare working tree vs tree object
                try:
                    with open(absf, "rb") as fd:
                        sha = object_hash(fd, b'blob', repo=None)
                    if rel not in index and rel not in staged:
                        # not staged but tracked => modified
                        modified.append(rel)
                except:
                    continue
            else:
                untracked.append(rel)

    print("Changes to be committed:")
    for s in sorted(staged):
        print("\t" + s)
    print("\nModified but not staged:")
    for m in sorted(set(modified)):
        print("\t" + m)
    print("\nUntracked files:")
    for u in sorted(set(untracked)):
        print("\t" + u)

# helper: list files from a tree recursively (return rel paths)
def list_files_in_tree(repo, tree_sha, prefix=""):
    files = []
    tree = object_read(repo, tree_sha)
    assert isinstance(tree, GitTree)
    for item in tree.items:
        name = item.path.decode('utf-8')
        if item.mode == b'40000':  # directory
            files.extend(list_files_in_tree(repo, item.sha, prefix + name + "/"))
        else:
            files.append(prefix + name)
    return files

# rm
argsp = argsubparsers.add_parser("rm", help="Remove files from index and optionally working tree")
argsp.add_argument("-f", "--force", action="store_true", help="Remove files even if modified")
argsp.add_argument("-r", "--recursive", action="store_true", help="Recurse into directories")
argsp.add_argument("paths", nargs="+")
def cmd_rm(args):
    repo = repo_find()
    index = read_index(repo)
    removed = []
    for p in args.paths:
        rel = p.replace(os.sep, "/")
        # remove directories if recursive
        if os.path.isdir(os.path.join(repo.worktree, rel)):
            if not args.recursive:
                print(f"error: {p} is a directory (use -r).")
                continue
            # gather files
            for root, _, files in os.walk(os.path.join(repo.worktree, rel)):
                for fn in files:
                    r = os.path.relpath(os.path.join(root, fn), repo.worktree).replace(os.sep, "/")
                    if r in index:
                        del index[r]
                        removed.append(r)
                    if args.force:
                        try:
                            os.remove(os.path.join(repo.worktree, r))
                        except:
                            pass
        else:
            if rel in index:
                del index[rel]
                removed.append(rel)
            else:
                print(f"warning: {rel} not staged")
            if args.force:
                try:
                    os.remove(os.path.join(repo.worktree, rel))
                except:
                    pass
    write_index(repo, index)
    for r in removed:
        print("removed", r)

# checkout
argsp = argsubparsers.add_parser("checkout", help="Checkout a commit or branch into a directory")
argsp.add_argument("commit", help="The commit or tree to checkout")
argsp.add_argument("path", help="The EMPTY directory to checkout on.")
def cmd_checkout(args):
    repo = repo_find()
    sha = object_find(repo, args.commit)
    obj = object_read(repo, sha)
    # if commit, get tree
    if obj.fmt == b'commit':
        tree_sha = obj.kvlm[b'tree'].decode("ascii")
    elif obj.fmt == b'tree':
        tree_sha = sha
    else:
        raise Exception("Can only checkout commit or tree")
    # verify path
    if os.path.exists(args.path):
        if not os.path.isdir(args.path):
            raise Exception("Not a directory %s!" % args.path)
        if os.listdir(args.path):
            raise Exception("Not empty %s!" % args.path)
    else:
        os.makedirs(args.path)
    # recursively write files
    def tree_checkout(tree_sha, dest):
        tree_obj = object_read(repo, tree_sha)
        for item in tree_obj.items:
            destpath = os.path.join(dest, item.path.decode('utf-8'))
            if item.mode == b'40000':
                os.makedirs(destpath, exist_ok=True)
                tree_checkout(item.sha, destpath)
            else:
                blob = object_read(repo, item.sha)
                with open(destpath, "wb") as f:
                    f.write(blob.blobdata)
    tree_checkout(tree_sha, os.path.realpath(args.path))
    print("Checked out to", args.path)

# log
argsp = argsubparsers.add_parser("log", help="Display history of a given commit.")
argsp.add_argument("commit", default="HEAD", nargs="?", help="Commit to start at.")
def cmd_log(args):
    repo = repo_find()
    try:
        start = object_find(repo, args.commit)
    except Exception as e:
        print("Error:", e)
        return
    seen = set()
    def walk(sha):
        if sha in seen:
            return
        seen.add(sha)
        try:
            commit = object_read(repo, sha)
        except Exception:
            return
        if not isinstance(commit, GitCommit):
            return
        msg = commit.kvlm.get(b'', b'').decode('utf-8', errors='replace')
        author = commit.kvlm.get(b'author', b'').decode('utf-8', errors='replace')
        print(f"commit {sha}")
        print(f"Author: {author}")
        print()
        print(f"    {msg}")
        print()
        parents = commit.kvlm.get(b'parent', None)
        if parents:
            if isinstance(parents, list):
                for p in parents:
                    walk(p.decode('ascii'))
            else:
                walk(parents.decode('ascii'))
    walk(start)

# branch (create/list)
argsp = argsubparsers.add_parser("branch", help="Create or list branches")
argsp.add_argument("name", nargs="?", help="Name of new branch (if given)")
argsp.add_argument("-d", "--delete", action="store_true", help="Delete branch")
def cmd_branch(args):
    repo = repo_find()
    if args.name:
        refpath = repo_file(repo, "refs", "heads", args.name, mkdir=True)
        # point branch to current HEAD
        try:
            cur = ref_resolve(repo, "HEAD")
            with open(refpath, "w") as f:
                f.write(cur + "\n")
            print("Created branch", args.name)
        except Exception:
            # no HEAD -> empty branch
            with open(refpath, "w") as f:
                f.write("\n")
            print("Created empty branch", args.name)
    else:
        refs = ref_list(repo)
        heads = refs.get('heads', {})
        for k, v in (heads.items() if isinstance(heads, dict) else []):
            print(k)

# show-ref
argsp = argsubparsers.add_parser("show-ref", help="List references.")
def cmd_show_ref(args):
    repo = repo_find()
    refs = ref_list(repo)
    show_ref(repo, refs, prefix="refs")

# tag (list/create)
argsp = argsubparsers.add_parser("tag", help="List and create tags")
argsp.add_argument("-a", action="store_true", dest="create_tag_object", help="Whether to create a tag object")
argsp.add_argument("name", nargs="?", help="The new tag's name")
argsp.add_argument("object", default="HEAD", nargs="?", help="The object the new tag will point to")
def cmd_tag(args):
    repo = repo_find()
    if args.name:
        sha = object_find(repo, args.object)
        refpath = repo_file(repo, "refs", "tags", args.name, mkdir=True)
        with open(refpath, "w") as f:
            f.write(sha + "\n")
        print("Tagged", args.name)
    else:
        refs = ref_list(repo)
        tags = refs.get('tags', {})
        for k, v in (tags.items() if isinstance(tags, dict) else []):
            print(k)

# -----------------------------
# Unimplemented placeholders (merge/rebase) — basic messages
# -----------------------------
argsp = argsubparsers.add_parser("merge", help="Merge commits/branches (basic implementation)")
argsp.add_argument("branch")
def cmd_merge(args):
    print("Merge is not fully implemented in this simplified VCS. Use Git for complex merges.")
argsubparsers.choices['merge'].set_defaults(func=cmd_merge)

argsp = argsubparsers.add_parser("rebase", help="Rebase branch (not fully implemented)")
argsp.add_argument("branch")
def cmd_rebase(args):
    print("Rebase is not fully implemented in this simplified VCS.")
argsubparsers.choices['rebase'].set_defaults(func=cmd_rebase)

# -----------------------------
# Main
# -----------------------------
def main(argv=sys.argv[1:]):
    args = argparser.parse_args(argv)
    cmd = args.command
    try:
        if cmd == "init":
            cmd_init(args)
        elif cmd == "hash-object":
            cmd_hash_object(args)
        elif cmd == "cat-file":
            cmd_cat_file(args)
        elif cmd == "rev-parse":
            cmd_rev_parse(args)
        elif cmd == "add":
            cmd_add(args)
        elif cmd == "commit":
            cmd_commit(args)
        elif cmd == "status":
            cmd_status(args)
        elif cmd == "rm":
            cmd_rm(args)
        elif cmd == "checkout":
            cmd_checkout(args)
        elif cmd == "log":
            cmd_log(args)
        elif cmd == "branch":
            cmd_branch(args)
        elif cmd == "show-ref":
            cmd_show_ref(args)
        elif cmd == "tag":
            cmd_tag(args)
        elif cmd == "merge":
            cmd_merge(args)
        elif cmd == "rebase":
            cmd_rebase(args)
        else:
            print(f"{cmd} not implemented.")
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()
