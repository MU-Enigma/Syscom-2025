# vcs_buggy.py
# Intentionally unfinished version for Level 3 .
# This file contains multiple known issues that contributors will need to fix.
import argparse
import collections
import configparser
import hashlib
import os
import re
import sys
import zlib
import stat
import shutil


argparser = argparse.ArgumentParser(description="The stupid content tracker")
argsubparsers = argparser.add_subparsers(title="Commands", dest="command")
argsubparsers.required = True

def main(argv=sys.argv[1:]):
    args = argparser.parse_args(argv)

    if   args.command == "add"         : cmd_add(args)
    elif args.command == "cat-file"    : cmd_cat_file(args)
    elif args.command == "checkout"    : cmd_checkout(args)
    elif args.command == "commit"      : cmd_commit(args)
    elif args.command == "hash-object" : cmd_hash_object(args)
    elif args.command == "init"        : cmd_init(args)
    elif args.command == "log"         : cmd_log(args)
    elif args.command == "ls-tree"     : cmd_ls_tree(args)
    elif args.command == "merge"       : cmd_merge(args)
    elif args.command == "rebase"      : cmd_rebase(args)
    elif args.command == "rev-parse"   : cmd_rev_parse(args)
    elif args.command == "rm"          : cmd_rm(args)
    elif args.command == "show-ref"    : cmd_show_ref(args)
    elif args.command == "status"      : cmd_status(args)
    elif args.command == "tag"         : cmd_tag(args)
    elif args.command == 'move'        : cmd_move(args)
    elif args.command == 'mkdir'       : cmd_mkdir(args)
    elif args.command == 'chmod'       : cmd_chmod(args)
    elif args.command == "version"     : cmd_version(args)

class GitRepository(object):
    """A git repository"""

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

def repo_path(repo, *path):
    """Compute path under repo's gitdir."""
    return os.path.join(repo.gitdir, *path)

def repo_file(repo, *path, mkdir=False):
    """Same as repo_path, but create dirname(*path) if absent.  For
        example, repo_file(r, \"refs\", \"remotes\", \"origin\", \"HEAD\") will create
        .git/refs/remotes/origin."""

    if repo_dir(repo, *path[:-1], mkdir=mkdir):
        return repo_path(repo, *path)

def repo_dir(repo, *path, mkdir=False):
    """Same as repo_path, but mkdir *path if absent if mkdir."""

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

def repo_create(path):
    """Create a new repository at path."""

    repo = GitRepository(path, True)

    # First, we make sure the path either doesn't exist or is an
    # empty dir.

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

    # .git/description
    with open(repo_file(repo, "description"), "w") as f:
        f.write("Unnamed repository; edit this file 'description' to name the repository.\n")

    # .git/HEAD
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

argsp = argsubparsers.add_parser("init", help="Initialize a new, empty repository.")
argsp.add_argument("path", metavar="directory", nargs="?", default=".", help="Where to create the repository.")

def cmd_init(args):
    repo_create(args.path)

def repo_find(path=".", required=True):
    path = os.path.realpath(path)

    if os.path.isdir(os.path.join(path, ".git")):
        return GitRepository(path)

    # If we haven't returned, recurse in parent, if w
    parent = os.path.realpath(os.path.join(path, ".."))

    if parent == path:
        # Bottom case
        # os.path.join("/", "..") == "/":
        # If parent==path, then path is root.
        if required:
            raise Exception("No git directory.")
        else:
            return None

    # Recursive case
    return repo_find(parent, required)

class GitObject (object):

    repo = None

    def __init__(self, repo, data=None):
        self.repo=repo

        if data != None:
            self.deserialize(data)

    def serialize(self):
        """This function MUST be implemented by subclasses. It must read the object's contents from self.data, a byte string, and do whatever it takes to convert it into a meaningful representation.  What exactly that means depend on each subclass."""
        raise Exception("Unimplemented!")

    def deserialize(self, data):
        raise Exception("Unimplemented!")

def object_read(repo, sha):
    """Read object object_id from Git repository repo.  Return a GitObject whose exact type depends on the object."""

    path = repo_file(repo, "objects", sha[0:2], sha[2:])

    with open (path, "rb") as f:
        raw = zlib.decompress(f.read())

        # Read object type
        x = raw.find(b' ')
        fmt = raw[0:x]

        # Read and validate object size
        y = raw.find(b'\x00', x)
        size = int(raw[x:y].decode("ascii"))
        if size != len(raw)-y-1:
            raise Exception("Malformed object {0}: bad length".format(sha))

        # Pick constructor
        if   fmt==b'commit' : c=GitCommit
        elif fmt==b'tree'   : c=GitTree
        elif fmt==b'tag'    : c=GitTag
        elif fmt==b'blob'   : c=GitBlob
        else:
            raise Exception("Unknown type {0} for object {1}".format(fmt.decode("ascii"), sha))

        # Call constructor and return object
        return c(repo, raw[y+1:])

def object_write(obj, actually_write=True):
    # Serialize object data
    data = obj.serialize()
    # Add header
    result = obj.fmt + b' ' + str(len(data)).encode() + b'\x00' + data
    # Compute hash
    sha = hashlib.sha1(result).hexdigest()

    if actually_write:
        # Compute path
        path=repo_file(obj.repo, "objects", sha[0:2], sha[2:], mkdir=actually_write)

        with open(path, 'wb') as f:
            # Compress and write
            f.write(zlib.compress(result))

    return sha

class GitBlob(GitObject):
    fmt=b'blob'

    def serialize(self):
        return self.blobdata

    def deserialize(self, data):
        self.blobdata = data

argsp = argsubparsers.add_parser("cat-file", help="Provide content of repository objects")
argsp.add_argument("type", metavar="type", choices=["blob", "commit", "tag", "tree"], help="Specify the type")
argsp.add_argument("object", metavar="object",help="The object to display")

def cmd_cat_file(args):
    repo = repo_find()
    cat_file(repo, args.object, fmt=args.type.encode())

def cat_file(repo, obj, fmt=None):
    obj = object_read(repo, object_find(repo, obj, fmt=fmt))
    sys.stdout.buffer.write(obj.serialize())

argsp = argsubparsers.add_parser("hash-object", help="Compute object ID and optionally creates a blob from a file")
argsp.add_argument("-t", metavar="type", dest="type", choices=["blob", "commit", "tag", "tree"], default="blob", help="Specify the type")
argsp.add_argument("-w", dest="write", action="store_true", help="Actually write the object into the database")
argsp.add_argument("path", help="Read object from <file>")

def cmd_hash_object(args):
    try:
        if args.write:
            repo = GitRepository(".")
        else:
            repo = None

        with open(args.path, "rb") as fd:
            sha = object_hash(fd, args.type.encode(), repo)
            print(sha)
    except Exception as e:
        print(f"Error during hash-object: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"File {args.path} not found.", file=sys.stderr)
        sys.exit(1)

def object_hash(fd, fmt, repo=None):
    data = fd.read()

    # Choose constructor depending on
    # object type found in header.
    if   fmt==b'commit' : obj=GitCommit(repo, data)
    elif fmt==b'tree'   : obj=GitTree(repo, data)
    elif fmt==b'tag'    : obj=GitTag(repo, data)
    elif fmt==b'blob'   : obj=GitBlob(repo, data)
    else:
        raise Exception("Unknown type %s!" % fmt)

    return object_write(obj, repo is not None)

def kvlm_parse(raw, start=0, dct=None):
    if not dct:
        dct = collections.OrderedDict()
        # You CANNOT declare the argument as dct=OrderedDict() or all
        # call to the functions will endlessly grow the same dict.

    # We search for the next space and the next newline.
    spc = raw.find(b' ', start)
    nl = raw.find(b'\n', start)

    # If space appears before newline, we have a keyword.

    # Base case
    # =========
    # If newline appears first (or there's no space at all, in which
    # case find returns -1), we assume a blank line.  A blank line
    # means the remainder of the data is the message.
    if (spc < 0) or (nl < spc):
        assert(nl == start)
        dct[b''] = raw[start+1:]
        return dct

    # Recursive case
    # ==============
    # we read a key-value pair and recurse for the next.
    key = raw[start:spc]

    # Find the end of the value.  Continuation lines begin with a
    # space, so we loop until we find a "\n" not followed by a space.
    end = start
    while True:
        end = raw.find(b'\n', end+1)
        if raw[end+1] != ord(' '): break

    # Grab the value
    # Also, drop the leading space on continuation lines
    value = raw[spc+1:end].replace(b'\n ', b'\n')

    # Don't overwrite existing data contents
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

    # Output fields
    for k in kvlm.keys():
        # Skip the message itself
        if k == b'': continue
        val = kvlm[k]
        # Normalize to a list
        if type(val) != list:
            val = [ val ]

        for v in val:
            ret += k + b' ' + (v.replace(b'\n', b'\n ')) + b'\n'

    # Append message
    ret += b'\n' + kvlm[b'']

    return ret

class GitCommit(GitObject):
    fmt=b'commit'

    def deserialize(self, data):
        self.kvlm = kvlm_parse(data)

    def serialize(self):
        return kvlm_serialize(self.kvlm)

argsp = argsubparsers.add_parser("log", help="Display history of a given commit.")
argsp.add_argument("commit", default="HEAD", nargs="?", help="Commit to start at.")

def cmd_log(args):
    repo = repo_find()

    print("digraph wyaglog{")
    log_graphviz(repo, object_find(repo, args.commit), set())
    print("}")

def log_graphviz(repo, sha, seen):

    if sha in seen:
        return
    seen.add(sha)

    commit = object_read(repo, sha)
    assert (commit.fmt==b'commit')

    if not b'parent' in commit.kvlm.keys():
        # Base case: the initial commit.
        return

    parents = commit.kvlm[b'parent']

    if type(parents) != list:
        parents = [ parents ]

    for p in parents:
        p = p.decode("ascii")
        print ("c_{0} -> c_{1};".format(sha, p))
        log_graphviz(repo, p, seen)

class GitTreeLeaf(object):
    def __init__(self, mode, path, sha):
        self.mode = mode
        self.path = path
        self.sha = sha

def tree_parse_one(raw, start=0):
    # Find the space terminator of the mode
    x = raw.find(b' ', start)
    assert(x-start == 5 or x-start==6)

    # Read the mode
    mode = raw[start:x]

    # Find the NULL terminator of the path
    y = raw.find(b'\x00', x)
    # and read the path
    path = raw[x+1:y]

    # Read the SHA and convert to an hex string
    sha = hex(
        int.from_bytes(
            raw[y+1:y+21], "big"))[2:] # hex() adds 0x in front,
                                           # we don't want that.
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
    #@FIXME Add serializer!
    ret = b''
    for i in obj.items:
        ret += i.mode
        ret += b' '
        ret += i.path
        ret += b'\x00'
        sha = int(i.sha, 16)
        # @FIXME Does
        ret += sha.to_bytes(20, byteorder="big")
    return ret

class GitTree(GitObject):
    fmt=b'tree'

    def deserialize(self, data):
        self.items = tree_parse(data)

    def serialize(self):
        return tree_serialize(self)

argsp = argsubparsers.add_parser("ls-tree", help="Pretty-print a tree object.")
argsp.add_argument("object", help="The object to show.")

def cmd_ls_tree(args):
    repo = repo_find()
    obj = object_read(repo, object_find(repo, args.object, fmt=b'tree'))

    for item in obj.items:
        print("{0} {1} {2}\t{3}".format(
            "0" * (6 - len(item.mode)) + item.mode.decode("ascii"),
            # Git's ls-tree displays the type
            # of the object pointed to.  We can do that too :)
            object_read(repo, item.sha).fmt.decode("ascii"),
            item.sha,
            item.path.decode("ascii")))

argsp = argsubparsers.add_parser("checkout", help="Checkout a commit inside of a directory.")
argsp.add_argument("commit", help="The commit or tree to checkout.")
argsp.add_argument("path", help="The EMPTY directory to checkout on.")

def cmd_checkout(args):
   try:
     repo = repo_find()

     obj = object_read(repo, object_find(repo, args.commit))

     # If the object is a commit, we grab its tree
     if obj.fmt == b'commit':
        obj = object_read(repo, obj.kvlm[b'tree'].decode("ascii"))

     # Verify that path is an empty directory
     if os.path.exists(args.path):
        if not os.path.isdir(args.path):
            raise Exception("Not a directory {0}!".format(args.path))
        if os.listdir(args.path):
            raise Exception("Not empty {0}!".format(args.path))
     else:
        os.makedirs(args.path)
     tree_checkout(repo, obj, os.path.realpath(args.path).encode())
   
   except Exception as e:
       print(f"Error during checkout: {e}", file=sys.stderr)
       sys.exit(1)

def tree_checkout(repo, tree, path):
    for item in tree.items:
        obj = object_read(repo, item.sha)
        dest = os.path.join(path, item.path)

        if obj.fmt == b'tree':
            os.mkdir(dest)
            tree_checkout(repo, obj, dest)
        elif obj.fmt == b'blob':
            with open(dest, 'wb') as f:
                f.write(obj.blobdata)

def ref_resolve(repo, ref):
    with open(repo_file(repo, ref), 'r') as fp:
        data = fp.read()[:-1]
        # Drop final \n ^^^^^
    if data.startswith("ref: "):
        return ref_resolve(repo, data[5:])
    else:
        return data

def ref_list(repo, path=None):
    if not path:
        path = repo_dir(repo, "refs")
    ret = collections.OrderedDict()
    # Git shows refs sorted.  To do the same, we use
    # an OrderedDict and sort the output of listdir
    for f in sorted(os.listdir(path)):
        can = os.path.join(path, f)
        if os.path.isdir(can):
            ret[f] = ref_list(repo, can)
        else:
            ret[f] = ref_resolve(repo, can)

    return ret

argsp = argsubparsers.add_parser("show-ref", help="List references.")

def cmd_show_ref(args):
    repo = repo_find()
    refs = ref_list(repo)
    show_ref(repo, refs, prefix="refs")

def show_ref(repo, refs, with_hash=True, prefix=""):
    for k, v in refs.items():
        if type(v) == str:
            print ("{0}{1}{2}".format(v + " " if with_hash else "", prefix + "/" if prefix else "", k))
        else:
            show_ref(repo, v, with_hash=with_hash, prefix="{0}{1}{2}".format(prefix, "/" if prefix else "", k))

class GitTag(GitCommit):
    fmt = b'tag'

argsp = argsubparsers.add_parser( "tag", help="List and create tags")
argsp.add_argument("-a", action="store_true", dest="create_tag_object", help="Whether to create a tag object")
argsp.add_argument("name", nargs="?", help="The new tag's name")
argsp.add_argument("object", default="HEAD", nargs="?", help="The object the new tag will point to")

# FIX: Implement missing tag_create function
def tag_create(name, obj, type="ref"):
    repo = repo_find()
    if type == "object":
        # Create tag object
        tag = GitTag(repo)
        tag.kvlm = collections.OrderedDict()
        tag.kvlm[b'object'] = object_find(repo, obj).encode()
        tag.kvlm[b'type'] = b'commit'
        tag.kvlm[b'tag'] = name.encode()
        tag.kvlm[b'tagger'] = b'User <user@example.com>'
        tag.kvlm[b''] = f'Tag {name}'.encode()
        tag_sha = object_write(tag)
        
        # Create tag reference
        with open(repo_file(repo, "refs", "tags", name), "w") as f:
            f.write(tag_sha + "\n")
    else:
        # Simple ref tag
        with open(repo_file(repo, "refs", "tags", name), "w") as f:
            f.write(object_find(repo, obj) + "\n")

def cmd_tag(args):
    repo = repo_find()

    if args.name:
        tag_create(args.name,
                   args.object,
                   type="object" if args.create_tag_object else "ref")
    else:
        refs = ref_list(repo)
        show_ref(repo, refs["tags"], with_hash=False)

def object_resolve(repo, name):
    """Resolve name to an object hash in repo.
        This function is aware of:
        - the HEAD literal
        - short and long hashes
        - tags
        - branches
        - remote branches"""
    candidates = list()
    hashRE = re.compile(r"^[0-9A-Fa-f]{4,40}$")

    # Empty string?  Abort.
    if not name.strip():
        return None

    # Head is nonambiguous
    if name == "HEAD":
        return [ ref_resolve(repo, "HEAD") ]

    if hashRE.match(name):
        if len(name) == 40:
            # This is a complete hash
            return [ name.lower() ]

        # This is a small hash 4 seems to be the minimal length
        # for git to consider something a short hash.
        # This limit is documented in man git-rev-parse
        name = name.lower()
        prefix = name[0:2]
        path = repo_dir(repo, "objects", prefix, mkdir=False)
        if path:
            rem = name[2:]
            for f in os.listdir(path):
                if f.startswith(rem):
                    candidates.append(prefix + f)

    return candidates

def object_find(repo, name, fmt=None, follow=True):
    sha = object_resolve(repo, name)

    if not sha:
        raise Exception("No such reference {0}.".format(name))

    if len(sha) > 1:
        raise Exception("Ambiguous reference {0}: Candidates are:\n - {1}.".format(name,  "\n - ".join(sha)))

    sha = sha[0]

    if not fmt:
        return sha

    while True:
        obj = object_read(repo, sha)

        if obj.fmt == fmt:
            return sha

        if not follow:
            return None

        # Follow tags
        if obj.fmt == b'tag':
            sha = obj.kvlm[b'object'].decode("ascii")
        elif obj.fmt == b'commit' and fmt == b'tree':
            sha = obj.kvlm[b'tree'].decode("ascii")
        else:
            return None

argsp = argsubparsers.add_parser("rev-parse", help="Parse revision (or other objects )identifiers")
argsp.add_argument("--wyag-type", metavar="type", dest="type", choices=["blob", "commit", "tag", "tree"], default=None, help="Specify the expected type")
argsp.add_argument("name", help="The name to parse")

def cmd_rev_parse(args):
    if args.type:
        fmt = args.type.encode()
    else:
        fmt = None

    repo = repo_find()

    print (object_find(repo, args.name, fmt, follow=True))

class GitIndexEntry(object):
    ctime = None
    """The last time a file's metadata changed.  This is a tuple (seconds, nanoseconds)"""

    mtime = None
    """The last time a file's data changed.  This is a tuple (seconds, nanoseconds)"""

    dev = None
    """The ID of device containing this file"""
    ino = None
    """The file's inode number"""
    mode_type = None
    """The object type, either b1000 (regular), b1010 (symlink), b1110 (gitlink). """
    mode_perms = None
    """The object permissions, an integer."""
    uid = None
    """User ID of owner"""
    gid = None
    """Group ID of ownner (according to stat 2.  Isn'th)"""
    size = None
    """Size of this object, in bytes"""
    obj = None
    """The object's hash as a hex string"""
    flag_assume_valid = None
    flag_extended = None
    flag_stage = None
    flag_name_length = None
    """Length of the name if < 0xFFF (yes, three Fs), -1 otherwise"""

    name = None

# Simple status command
argsp = argsubparsers.add_parser("status", help="Show the working tree status")

def cmd_status(args):
    repo = repo_find()
    
    files = []
    for item in os.listdir("."):
        if os.path.isfile(item) and item != ".git":
            files.append(item)
    
    print("On branch master")
    print()
    
    if files:
        print("Untracked files:")
        for file in files:
            print("        " + file)
    else:
        print("nothing to commit, working tree clean")

# 'rm' command to remove files from index and working directory (Made by Apollo)
argsp = argsubparsers.add_parser("rm", help="Remove files from index and working directory")
argsp.add_argument("--cached", action="store_true", help="Remove from index only")
argsp.add_argument("paths", nargs="+", help="Files to remove")

def cmd_rm(args):
    repo = repo_find()
    for path in args.paths:
        if not os.path.exists(path):
            print(f"Error: File {path} not found", file=sys.stderr)
            continue

        if args.cached:
            # Simulate removing from index only
            print(f"Removed {path} from index (kept in working directory)")
        else:
            try:
                os.remove(path)
                print(f"Removed {path} from working directory and index")
            except OSError as e:
                print(f"Error removing {path}: {e}", file=sys.stderr)

argsp = argsubparsers.add_parser("merge", help="Merge files into the repository")
argsp.add_argument("branch", help="Branch to merge into the current one")

def cmd_merge(args):
    repo = repo_find()

    head_ref = os.path.join(repo.gitdir, "HEAD")
    with open(head_ref, 'r') as f:
        current_commit = f.read().strip()

    print(f"Merging branch {args.branch} into current branch {current_commit}")
    print("Merge completed successfully (no conflicts).")

    kvlm = collections.OrderedDict()
    kvlm[b'tree'] = b'tree_hash_placeholder'
    kvlm[b'parent'] = [current_commit.encode(), args.branch.encode()]
    kvlm[b'author'] = b'User <user@example.com>' + str(int(os.time())).encode() + b' +0000'
    kvlm[b''] = f'Merged branch {args.branch}'.encode()

    commit = GitCommit(repo)
    commit.kvlm = kvlm
    commit_hash = object_write(commit)

    with open(head_ref, 'w') as f:
        f.write(commit_hash + '\n')

    print(f"Created merge commit {commit_hash}")

argsp = argsubparsers.add_parser("move", help="Move or rename a file in the repository")
argsp.add_argument("source", help="Source file path")
argsp.add_argument("dest", help="Destination path")

def cmd_move(args):  
    repo = repo_find()

    if not os.path.exists(args.source):
        print(f"Error: Source file {args.source} not found", file=sys.stderr)
        sys.exit(1)
    
    if os.path.exists(args.dest):
        print(f"Error: Destination {args.dest} already exists", file=sys.stderr)
        sys.exit(1)
        
    os.rename(args.source, args.dest)
    print(f"Moved {args.source} to {args.dest}")

argsp = argsubparsers.add_parser("mkdir", help="Create a new directory in the repository")
argsp.add_argument("directory", help="Directory to create")

def cmd_mkdir(args):
    repo = repo_find()

    if not os.path.exists(args.directory):
        path = os.path.join(repo.worktree, args.directory)
        os.makedirs(path, exist_ok=True)
        print(f"Created directory {args.directory} at {path}")
    else:
        print(f"Directory {args.directory} already exists")

argsp = argsubparsers.add_parser("chmod", help="Changes the permisions of the directory")
argsp.add_argument("directory", help="Directory to change permissions")
argsp.add_argument("permissions", help="New permissions in octal format")

def cmd_chmod(args):
    try:
        permission_map = {
        'readonly': stat.S_IREAD,
        'readwrite': stat.S_IREAD | stat.S_IWRITE,
        'readwriteexecute': stat.S_IREAD | stat.S_IWRITE | stat.S_IEXEC
        }
    
        if args.permissions in permission_map:
            os.chmod(args.directory, permission_map[args.permissions])
        else:
            # Try to parse as octal
            try:
                perm = int(args.permissions, 8)
                os.chmod(args.directory, perm)
            except ValueError:
                print("Invalid permissions format. Use 'readonly', 'readwrite', 'readwriteexecute' or octal format like '755'.", file=sys.stderr)
    except PermissionError:
        print("Error: Permission denied!", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"Directory {args.directory} not found.", file=sys.stderr)
        sys.exit(1)

argsp = argsubparsers.add_parser("version", help="Access versions of the file")
argsp.add_argument("mode", choices=["create", "open", "remove"], help="Version operation mode")
argsp.add_argument("file", help="File to check versions for")

def cmd_version(args):
    repo = repo_find()
    
    # Create version directory path in repo worktree
    version_dir_name = f"{args.file} Versions"
    version_dir_path = os.path.join(repo.worktree, version_dir_name)
    
    if args.mode == "create":
        try:
            # Create versions directory if it doesn't exist
            os.makedirs(version_dir_path, exist_ok=True)
            
            # Get current version count
            existing_versions = [f for f in os.listdir(version_dir_path) 
                               if f.startswith(os.path.basename(args.file))]
            
            # Calculate next version number
            next_version = len(existing_versions) + 1
            
            # Create versioned filename
            file_name, file_extension = os.path.splitext(os.path.basename(args.file))
            versioned_file = f"{file_name}_v{next_version}{file_extension}"
            versioned_file_path = os.path.join(version_dir_path, versioned_file)
            
            # Copy original file to version directory
            if os.path.exists(args.file):
                shutil.copy2(args.file, versioned_file_path)
                print(f"Created version {next_version}: {versioned_file}")
            else:
                print(f"Error: Source file {args.file} not found", file=sys.stderr)
                sys.exit(1)
                
        except Exception as e:
            print(f"Error creating version: {e}", file=sys.stderr)
            sys.exit(1)
    
    elif args.mode == "open":
        try:
            if not os.path.exists(version_dir_path):
                print(f"No versions found for {args.file}", file=sys.stderr)
                sys.exit(1)
            
            # List available versions
            version_files = [f for f in os.listdir(version_dir_path) 
                           if not f.startswith('.')]  # Skip hidden files
            
            if not version_files:
                print(f"No versions found for {args.file}", file=sys.stderr)
                sys.exit(1)
            
            print(f"Available versions for {args.file}:")
            for i, vf in enumerate(sorted(version_files), 1):
                print(f"  {i}. {vf}")
            
            # Let user select a version to open
            try:
                selection = int(input("Enter version number to open: ")) - 1
                if 0 <= selection < len(version_files):
                    selected_file = os.path.join(version_dir_path, sorted(version_files)[selection])
                    
                    # Copy to current directory for editing
                    temp_file = f"EDITING_{os.path.basename(selected_file)}"
                    shutil.copy2(selected_file, temp_file)
                    
                    print(f"Opened {sorted(version_files)[selection]} as {temp_file}")
                    print("Edit the file, then use 'create' mode to save as new version")
                else:
                    print("Invalid selection", file=sys.stderr)
                    sys.exit(1)
                    
            except (ValueError, EOFError):
                print("Invalid input", file=sys.stderr)
                sys.exit(1)
                
        except Exception as e:
            print(f"Error opening version: {e}", file=sys.stderr)
            sys.exit(1)
    
    elif args.mode == "remove":
        try:
            if not os.path.exists(version_dir_path):
                print(f"No versioning directory found for {args.file}", file=sys.stderr)
                sys.exit(1)
            
            # List versions for removal selection
            version_files = [f for f in os.listdir(version_dir_path) 
                           if not f.startswith('.')]
            
            if not version_files:
                print(f"No versions found to remove", file=sys.stderr)
                sys.exit(1)
            
            print("Available versions to remove:")
            for i, vf in enumerate(sorted(version_files), 1):
                print(f"  {i}. {vf}")
            print("  a. Remove ALL versions and directory")
            
            try:
                selection = input("Enter version number to remove or 'a' for all: ")
                
                if selection.lower() == 'a':
                    shutil.rmtree(version_dir_path)
                    print(f"Removed all versions and directory for {args.file}")
                else:
                    selection = int(selection) - 1
                    if 0 <= selection < len(version_files):
                        file_to_remove = os.path.join(version_dir_path, sorted(version_files)[selection])
                        os.remove(file_to_remove)
                        print(f"Removed version: {sorted(version_files)[selection]}")
                        
                        # Remove directory if empty
                        if not os.listdir(version_dir_path):
                            os.rmdir(version_dir_path)
                    else:
                        print("Invalid selection", file=sys.stderr)
                        sys.exit(1)
                        
            except (ValueError, EOFError):
                print("Invalid input", file=sys.stderr)
                sys.exit(1)
                
        except Exception as e:
            print(f"Error removing version: {e}", file=sys.stderr)
            sys.exit(1)

