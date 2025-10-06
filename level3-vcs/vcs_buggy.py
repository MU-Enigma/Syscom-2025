
# vcs_buggy.py
# Intentionally buggy/unfinished version for Level 3 .
# This file contains multiple known issues that contributors will need to fix.
import argparse
import collections
import configparser
import hashlib
import os
import re
import sys
import zlib

argparser = argparse.ArgumentParser(description="The stupid content tracker")
argsubparsers = argparser.add_subparsers(title="Commands", dest="command")
argsubparsers.required = True

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

def repo_path(repo, *path):
    return os.path.join(repo.gitdir, *path)

def repo_file(repo, *path, mkdir=False):
    if repo_dir(repo, *path[:-1], mkdir=mkdir):
        return repo_path(repo, *path)

def repo_dir(repo, *path, mkdir=False):
    path = repo_path(repo, *path)
    if os.path.exists(path):
        if (os.path.isdir(path)):
            return path
        else:
            raise Exception("Not a directory %s" % path)
    if mkdir:
        os.makedirs(path)
        return path
    else:
        return None

class GitObject(object):
    repo = None
    def __init__(self, repo, data=None):
        self.repo = repo
        if data != None:
            self.deserialize(data)
    def serialize(self):
        raise Exception("Unimplemented!")
    def deserialize(self, data):
        raise Exception("Unimplemented!")

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
    if   fmt==b'commit' : c=GitCommit
    elif fmt==b'tree'   : c=GitTree
    elif fmt==b'tag'    : c=GitTag
    elif fmt==b'blob'   : c=GitBlob
    else:
        raise Exception("Unknown type {0} for object {1}".format(fmt.decode("ascii"), sha))
    return c(repo, raw[y+1:])

def object_write(obj, actually_write=True):
    data = obj.serialize()
    result = obj.fmt + b' ' + str(len(data)).encode() + b'\x00' + data
    sha = hashlib.sha1(result).hexdigest()
    if actually_write:
        path=repo_file(obj.repo, "objects", sha[0:2], sha[2:], mkdir=actually_write)
        with open(path, 'wb') as f:
            f.write(zlib.compress(result))
    return sha

class GitBlob(GitObject):
    fmt=b'blob'
    def serialize(self):
        return self.blobdata
    def deserialize(self, data):
        self.blobdata = data

def kvlm_parse(raw, start=0, dct=None):
    # Intentionally fragile: fails on empty commit message
    if not dct:
        dct = collections.OrderedDict()
    spc = raw.find(b' ', start)
    nl = raw.find(b'\n', start)
    # This version asserts when message is empty (bug)
    if (spc < 0) or (nl < spc):
        assert(nl == start)  # <-- bug: will fail on empty or whitespace-only messages
        dct[b''] = raw[nl+1:]
        return dct
    key = raw[start:spc]
    end = start
    while True:
        end = raw.find(b'\n', end+1)
        if end == -1:
            break
        if raw[end+1] != ord(' '): break
    if end == -1:
        value = raw[spc+1:]
        dct[key] = value
        return dct
    value = raw[spc+1:end].replace(b'\n ', b'\n')
    if key in dct:
        if type(dct[key]) == list:
            dct[key].append(value)
        else:
            dct[key] = [ dct[key], value ]
    else:
        dct[key]=value
    return kvlm_parse(raw, start=end+1, dct=dct)

def kvlm_serialize(kvlm):
    ret = b''
    for k in kvlm.keys():
        if k == b'': continue
        val = kvlm[k]
        if type(val) != list:
            val = [ val ]
        for v in val:
            ret += k + b' ' + (v.replace(b'\n', b'\n ')) + b'\n'
    ret += b'\n' + kvlm[b'']
    return ret

class GitCommit(GitObject):
    fmt=b'commit'
    def deserialize(self, data):
        self.kvlm = kvlm_parse(data)
    def serialize(self):
        return kvlm_serialize(self)

def tree_parse_one(raw, start=0):
    x = raw.find(b' ', start)
    assert(x-start == 5 or x-start==6)
    mode = raw[start:x]
    y = raw.find(b'\x00', x)
    path = raw[x+1:y]
    sha = hex(int.from_bytes(raw[y+1:y+21], "big"))[2:]
    return y+21, GitTreeLeaf(mode, path, sha)

def tree_parse(raw):
    pos = 0
    max = len(raw)
    ret = list()
    while pos < max:
        pos, data = tree_parse_one(raw, pos)
        ret.append(data)
    return ret

def tree_serialize(obj):
    # Intentionally incomplete serializer (#@FIXME) - will break nested trees
    # BUG: only writes mode and path, but not SHA bytes
    ret = b''
    for i in obj.items:
        ret += i.mode + b' ' + i.path + b'\x00'  # missing SHA bytes -> broken serialization
    return ret

class GitTree(GitObject):
    fmt=b'tree'
    def deserialize(self, data):
        self.items = tree_parse(data)
    def serialize(self):
        return tree_serialize(self)

class GitTreeLeaf(object):
    def __init__(self, mode, path, sha):
        self.mode = mode
        self.path = path
        self.sha = sha

def object_hash(fd, fmt, repo=None):
    # BUG: when repo is None and write=False, still tries to write -> crashes
    data = fd.read()
    if   fmt==b'commit' : obj=GitCommit(repo, data)
    elif fmt==b'tree'   : obj=GitTree(repo, data)
    elif fmt==b'tag'    : obj=GitTag(repo, data)
    elif fmt==b'blob'   : obj=GitBlob(repo, data)
    else:
        raise Exception("Unknown type %s!" % fmt)
    # Always attempts to write (bug) even if repo is None
    return object_write(obj, actually_write=True)

def object_resolve(repo, name):
    # BUG: ambiguous short SHA handling missing - returns all candidates without checking ambiguity
    candidates = list()
    hashRE = re.compile(r"^[0-9A-Fa-f]{4,40}$")
    if not name or not name.strip():
        return None
    if name == "HEAD":
        return [ ref_resolve(repo, "HEAD") ]
    if hashRE.match(name):
        name = name.lower()
        if len(name) == 40:
            return [ name ]
        rem = name[2:] if len(name) > 2 else name[0:]
        objects_dir = repo_dir(repo, "objects", mkdir=False)
        if objects_dir and os.path.isdir(objects_dir):
            for prefix in os.listdir(objects_dir):
                prefix_path = os.path.join(objects_dir, prefix)
                if not os.path.isdir(prefix_path):
                    continue
                for f in os.listdir(prefix_path):
                    if f.startswith(rem):
                        candidates.append(prefix + f)
    return candidates

def object_find(repo, name, fmt=None, follow=True):
    sha = object_resolve(repo, name)
    if not sha:
        raise Exception("No such reference {0}.".format(name))
    # BUG: if multiple candidates exist it proceeds and later may error unpredictably
    if len(sha) > 1:
        # instead of raising ambiguity, it picks the first silently (bug)
        sha = sha[0]
    else:
        sha = sha[0]
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

def ref_resolve(repo, ref):
    # BUG: no protection against circular refs -> infinite recursion possible
    path = repo_file(repo, ref)
    with open(path, 'r') as fp:
        data = fp.read().strip()
    if data.startswith("ref: "):
        return ref_resolve(repo, data[5:])
    else:
        return data

def ref_list(repo, path=None):
    if not path:
        path = repo_dir(repo, "refs")
    ret = collections.OrderedDict()
    for f in sorted(os.listdir(path)):
        can = os.path.join(path, f)
        if os.path.isdir(can):
            ret[f] = ref_list(repo, can)
        else:
            ret[f] = ref_resolve(repo, can)
    return ret

def cmd_checkout(args):
    repo = repo_find()
    # BUG: requires target directory to be empty - refuses to checkout if any files exist
    if os.path.exists(args.path) and os.listdir(args.path):
        raise Exception("Target directory must be empty for checkout (intentionally restrictive).")
    obj = object_read(repo, object_find(repo, args.commit))
    if obj.fmt == b'commit':
        obj = object_read(repo, obj.kvlm[b'tree'].decode("ascii"))
    tree_checkout(repo, obj, os.path.realpath(args.path))

def tree_checkout(repo, tree, path):
    for item in tree.items:
        obj = object_read(repo, item.sha)
        dest = os.path.join(path, item.path.decode("utf-8"))
        if obj.fmt == b'tree':
            # BUG: blindly mkdir without checking existence -> may raise if parent exists
            os.mkdir(dest)
            tree_checkout(repo, obj, dest)
        elif obj.fmt == b'blob':
            with open(dest, 'wb') as f:
                f.write(obj.blobdata)

# Unused index entry class (fields defined but never used)
class GitIndexEntry(object):
    def __init__(self):
        self.ctime = 0
        self.mtime = 0
        self.obj = None
        self.mode = 0
        self.path = ""

class GitTag(GitCommit):
    fmt = b'tag'

def cmd_tag(args):
    repo = repo_find()
    if args.name:
        # BUG: tag_create not implemented -> NameError when creating tags
        tag_create(repo, args.name, args.object, type="object" if args.create_tag_object else "ref")
    else:
        refs = ref_list(repo)
        show_ref(repo, refs.get("tags", {}), with_hash=False)

def log_graphviz(repo, sha, seen=set()):
    # BUG: crashes on malformed/initial commit because it expects parent key always present
    if sha in seen:
        return
    seen.add(sha)
    commit = object_read(repo, sha)
    parents = commit.kvlm[b'parent']  # will KeyError if 'parent' not present
    if type(parents) != list:
        parents = [ parents ]
    for p in parents:
        print ("c_{0} -> c_{1};".format(sha, p.decode("ascii") if isinstance(p, bytes) else str(p)))
        log_graphviz(repo, p, seen)

# Minimal stubs to allow parsing CLI but many commands are incomplete for Level 3 tasks
def repo_find(path=".", required=True):
    return GitRepository(path)
def cmd_init(args): pass
def cmd_add(args): pass
def cmd_commit(args): pass
def cmd_hash_object(args): pass
def cmd_cat_file(args): pass
def cmd_ls_tree(args): pass
def cmd_log(args): pass
def cmd_rev_parse(args): pass
def cmd_show_ref(args): pass

if __name__ == '__main__':
    print("This is the intentionally buggy vcs for Level 3.")
