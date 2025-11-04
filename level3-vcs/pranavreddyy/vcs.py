#!/usr/bin/env python3
# vcs.py - The Stupid Content Tracker (Level 3 Implemented)
import argparse
import collections
import configparser
import hashlib
import os
import re
import sys
import zlib
import time
import struct
import fnmatch

argparser = argparse.ArgumentParser(description="The stupid content tracker")
argsubparsers = argparser.add_subparsers(title="Commands", dest="command")
argsubparsers.required = True

# --- Helper Functions ---

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

# --- GitRepository Class ---

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
        
        # Load .gitignore patterns
        self.ignore = GitIgnore(self)


def repo_path(repo, *path):
    """Compute path under repo's gitdir."""
    return os.path.join(repo.gitdir, *path)

def repo_file(repo, *path, mkdir=False):
    """Same as repo_path, but create dirname(*path) if absent."""
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

    # Create empty .gitignore
    with open(repo_file(repo, "..", ".gitignore"), "w") as f:
        f.write("# Add files and directories to ignore here\n*.log\nbuild/\n")
        
    # Create empty index
    repo.index = GitIndex(repo)
    repo.index.write()

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
    print(f"Initialized empty Git repository in {os.path.realpath(args.path)}/.git/")

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

# --- .gitignore Implementation (Task 1) ---

class GitIgnore(object):
    """Represents .gitignore patterns."""
    def __init__(self, repo):
        self.patterns = []
        self.repo = repo
        gitignore_path = os.path.join(repo.worktree, ".gitignore")
        
        # Always ignore .git directory
        self.add_pattern(".git/", gitignore_path)

        if os.path.exists(gitignore_path):
            with open(gitignore_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#"):
                        self.add_pattern(line, gitignore_path)

    def add_pattern(self, pattern, source_path):
        """Adds a pattern to the list."""
        # '!' means negative pattern
        negative = pattern.startswith('!')
        if negative:
            pattern = pattern[1:]

        # 'build/' should match 'build' directory and everything inside
        if pattern.endswith('/'):
            pattern = pattern[:-1] # fnmatch doesn't need the trailing slash
            
        self.patterns.append({'pattern': pattern, 'negative': negative, 'source': source_path})

    def matches(self, path):
        """
        Check if a given path matches any .gitignore pattern.
        Paths should be relative to the repo worktree.
        """
        path = path.replace(os.path.sep, '/') # Normalize to forward slashes
        
        # Check against patterns
        is_ignored = False
        for p in self.patterns:
            # Check if pattern matches path or a parent directory of path
            match = False
            if fnmatch.fnmatch(path, p['pattern']):
                match = True
            elif fnmatch.fnmatch(os.path.dirname(path), p['pattern']):
                 match = True
            elif path.startswith(p['pattern'] + '/'):
                 match = True

            if match:
                if p['negative']:
                    is_ignored = False # Exception rule
                else:
                    is_ignored = True # Ignore rule
        
        return is_ignored

# --- GitObject Classes (Blob, Commit, Tree) ---

class GitObject (object):
    repo = None
    def __init__(self, repo, data=None):
        self.repo=repo
        if data != None:
            self.deserialize(data)

    def serialize(self):
        raise Exception("Unimplemented!")

    def deserialize(self, data):
        raise Exception("Unimplemented!")

def object_read(repo, sha):
    """Read object object_id from Git repository repo."""
    path = repo_file(repo, "objects", sha[0:2], sha[2:])
    
    if not os.path.exists(path):
        return None

    with open (path, "rb") as f:
        raw = zlib.decompress(f.read())

        x = raw.find(b' ')
        fmt = raw[0:x]

        y = raw.find(b'\x00', x)
        size = int(raw[x+1:y].decode("ascii"))
        if size != len(raw)-y-1:
            raise Exception("Malformed object {0}: bad length".format(sha))

        if   fmt==b'commit' : c=GitCommit
        elif fmt==b'tree'   : c=GitTree
        elif fmt==b'tag'    : c=GitTag
        elif fmt==b'blob'   : c.name = GitBlob
        else:
            raise Exception("Unknown type {0} for object {1}".format(fmt.decode("ascii"), sha))
        return c(repo, raw[y+1:])

def object_write(obj, actually_write=True):
    data = obj.serialize()
    result = obj.fmt + b' ' + str(len(data)).encode() + b'\x00' + data
    sha = hashlib.sha1(result).hexdigest()

    if actually_write:
        path=repo_file(obj.repo, "objects", sha[0:2], sha[2:], mkdir=True)
        if not os.path.exists(path):
            with open(path, 'wb') as f:
                f.write(zlib.compress(result))
    return sha

class GitBlob(GitObject):
    fmt=b'blob'
    def serialize(self):
        return self.blobdata
    def deserialize(self, data):
        self.blobdata = data

# --- Git Index (Staging Area) Implementation ---
# This is the new, critical component for add, commit, status, rm

class GitIndexEntry(object):
    """An entry in the Git Index."""
    def __init__(self, ctime, mtime, dev, ino, mode, uid, gid, size, sha, flags, path):
        self.ctime_s = int(ctime[0])
        self.ctime_n = int(ctime[1])
        self.mtime_s = int(mtime[0])
        self.mtime_n = int(mtime[1])
        self.dev = int(dev)
        self.ino = int(ino)
        self.mode = int(mode)
        self.uid = int(uid)
        self.gid = int(gid)
        self.size = int(size)
        self.sha = sha # 20-byte binary SHA-1
        self.flags = int(flags)
        self.path = path # UTF-8 encoded path
    
    def __repr__(self):
        return f"GitIndexEntry(path={self.path.decode('utf-8')}, sha={self.sha.hex()})"

    @classmethod
    def from_stat(cls, stat, sha, path, flags=None):
        """Create a GitIndexEntry from an os.stat result and blob SHA."""
        ctime = (stat.st_ctime, 0) # Coarse time
        mtime = (stat.st_mtime, 0) # Coarse time
        
        # Default flags: assume-valid=0, extended=0, stage=0
        # Path length is encoded in flags if less than 0xFFF
        path_bytes = path.encode('utf-8')
        if flags is None:
            flags = len(path_bytes)
            if flags >= 0xFFF:
                flags = 0xFFF # Set to max if path is too long

        return cls(ctime, mtime, stat.st_dev, stat.st_ino, stat.st_mode,
                   stat.st_uid, stat.st_gid, stat.st_size, sha, flags, path_bytes)

    def pack(self):
        """Pack entry into its binary format."""
        # 62 bytes for fixed-width fields
        # Note: SHA is 20 bytes binary, not 40 bytes hex
        entry_data = struct.pack(
            '!IIIIIIIIII20sH',
            self.ctime_s, self.ctime_n,
            self.mtime_s, self.mtime_n,
            self.dev, self.ino, self.mode,
            self.uid, self.gid, self.size,
            self.sha, self.flags
        )
        
        # Append path and padding
        packed = entry_data + self.path + b'\x00'
        
        # Add padding to align to 8 bytes
        padded_len = (len(packed) + 7) // 8 * 8
        return packed.ljust(padded_len, b'\x00')

    @classmethod
    def unpack(cls, data):
        """Unpack binary data into a GitIndexEntry."""
        header = struct.unpack('!IIIIIIIIII20sH', data[:62])
        (ctime_s, ctime_n, mtime_s, mtime_n, dev, ino, mode, uid, gid, size, sha, flags) = header
        
        # Find the null byte that terminates the path
        path_end = data.find(b'\x00', 62)
        if path_end == -1:
            raise Exception("Malformed index entry: no null terminator for path")
            
        path = data[62:path_end]
        
        # Total length including padding
        total_len = (62 + len(path) + 1 + 7) // 8 * 8
        
        return cls((ctime_s, ctime_n), (mtime_s, mtime_n), dev, ino, mode, uid, gid, size, sha, flags, path), total_len

class GitIndex(object):
    """Represents the .git/index file."""
    def __init__(self, repo):
        self.repo = repo
        self.index_file = repo_file(repo, "index")
        self.entries = {} # Dictionary mapping paths to GitIndexEntry objects
        self.read()

    def read(self):
        """Read the index file from disk."""
        self.entries = {}
        if not os.path.exists(self.index_file):
            return

        try:
            with open(self.index_file, 'rb') as f:
                data = f.read()
            
            # Verify signature and version
            signature, version, num_entries = struct.unpack('!4sII', data[:12])
            if signature != b'DIRC': # "directory cache"
                raise Exception("Malformed index: invalid signature")
            if version != 2:
                raise Exception(f"Unsupported index version: {version}")

            # Read entries
            content = data[12:]
            idx = 0
            for i in range(num_entries):
                if idx >= len(content):
                    raise Exception("Malformed index: not enough data for entries")
                entry, length = GitIndexEntry.unpack(content[idx:])
                self.entries[entry.path.decode('utf-8')] = entry
                idx += length
            
            # @TODO: Read extensions and verify checksum (omitted for simplicity)

        except Exception as e:
            print(f"Warning: Could not read index file. Creating new one. Error: {e}", file=sys.stderr)
            self.entries = {}

    def write(self):
        """Write the index back to disk."""
        
        # Sort entries by path (required by Git)
        sorted_entries = sorted(self.entries.values(), key=lambda e: e.path)
        
        # Header
        header = struct.pack('!4sII', b'DIRC', 2, len(sorted_entries))
        
        # Entry data
        entry_data = b''
        for entry in sorted_entries:
            entry_data += entry.pack()
            
        # Write file
        try:
            full_content = header + entry_data
            
            # Add checksum
            checksum = hashlib.sha1(full_content).digest()
            full_content += checksum
            
            with open(self.index_file, 'wb') as f:
                f.write(full_content)
        except Exception as e:
            raise Exception(f"Failed to write index file: {e}")

    def add(self, path, sha_bin, stat):
        """Add or update an entry in the index."""
        entry = GitIndexEntry.from_stat(stat, sha_bin, path)
        self.entries[path] = entry

    def remove(self, path):
        """Remove an entry from the index."""
        if path in self.entries:
            del self.entries[path]

    def get_entry(self, path):
        """Get an entry by path, returns None if not found."""
        return self.entries.get(path)

# --- Task 2: cmd_add ---
argsp = argsubparsers.add_parser("add", help="Add file contents to the index")
argsp.add_argument("paths", nargs="+", help="Files to add")

def cmd_add(args):
    repo = repo_find()
    repo.index.read() # Load current index
    
    added_files = []
    
    # Expand directories
    paths_to_add = []
    for path_arg in args.paths:
        path = os.path.relpath(path_arg, repo.worktree)
        if os.path.isdir(path):
            for dirpath, dirnames, filenames in os.walk(path):
                # Filter out ignored directories
                ignored_dirs = []
                for d in dirnames:
                    dir_full_path = os.path.join(dirpath, d)
                    if repo.ignore.matches(dir_full_path):
                        ignored_dirs.append(d)
                for d in ignored_dirs:
                    dirnames.remove(d)

                for f in filenames:
                    file_full_path = os.path.join(dirpath, f)
                    if not repo.ignore.matches(file_full_path):
                        paths_to_add.append(file_full_path)
        elif os.path.isfile(path):
             paths_to_add.append(path)
        else:
            print(f"fatal: pathspec '{path_arg}' did not match any files", file=sys.stderr)

    for path in paths_to_add:
        # Normalize path
        path = path.replace(os.path.sep, '/')
        
        # Check .gitignore (Task 1)
        if repo.ignore.matches(path):
            continue
        
        full_path = os.path.join(repo.worktree, path)
        
        if not os.path.exists(full_path):
            print(f"fatal: {path} does not exist", file=sys.stderr)
            continue

        try:
            # 1. Read file from working directory
            with open(full_path, "rb") as fd:
                data = fd.read()
            
            # 2. Create blob object and store it
            blob = GitBlob(repo, data)
            sha_hex = object_write(blob, actually_write=True)
            sha_bin = bytes.fromhex(sha_hex) # Index uses binary SHA

            # 3. Get file metadata
            stat = os.stat(full_path)
            
            # 4. Update the index
            repo.index.add(path, sha_bin, stat)
            added_files.append(path)
            
        except Exception as e:
            print(f"Error adding {path}: {e}", file=sys.stderr)

    if added_files:
        repo.index.write() # Save changes to .git/index
        # print(f"Added: {', '.join(added_files)}") # Optional: print added files
    else:
        print("No files added.")

# --- Task 3: cmd_commit ---
argsp = argsubparsers.add_parser("commit", help="Record changes to the repository")
argsp.add_argument("-m", metavar="message", dest="message", required=True, help="Commit message")

def tree_from_index(repo, index):
    """Builds a tree object from the current index."""
    
    # Group entries by directory
    tree_data = {} # {dirname: {basename: entry}}
    
    # Root tree
    if '' not in tree_data:
        tree_data[''] = {}

    for entry in index.entries.values():
        path = entry.path.decode('utf-8')
        parts = path.split('/')
        
        current_level = tree_data['']
        current_path = ''
        
        for i, part in enumerate(parts):
            if i == len(parts) - 1:
                # This is the file
                current_level[part] = entry
            else:
                # This is a directory
                current_path = f"{current_path}{part}/" if current_path else f"{part}/"
                
                if part not in current_level:
                    # Create a placeholder for the sub-tree
                    current_level[part] = {} 
                    
                if current_path not in tree_data:
                    tree_data[current_path] = {}
                
                current_level = current_level[part] if isinstance(current_level.get(part), dict) else tree_data[current_path]


    def build_tree_recursive(tree_level_entries):
        """Recursively writes tree objects."""
        items = []
        for name, item in tree_level_entries.items():
            if isinstance(item, dict):
                # This is a sub-tree, recurse
                sub_tree_sha_hex = build_tree_recursive(item)
                mode = b'40000' # Directory mode
                sha = bytes.fromhex(sub_tree_sha_hex)
            else:
                # This is a GitIndexEntry (a blob)
                mode = (f"{item.mode:o}").encode('ascii') # Use file's mode
                sha = item.sha
            
            items.append(GitTreeLeaf(mode, name.encode('utf-8'), sha.hex()))

        # Sort items by path (required by Git)
        items.sort(key=lambda x: x.path) 

        tree = GitTree(repo)
        tree.items = items
        return object_write(tree)
    
    # Start building from the root
    root_entries = tree_data['']
    root_tree_sha = build_tree_recursive(root_entries)
    return root_tree_sha


def cmd_commit(args):
    repo = repo_find()
    repo.index.read()

    if not repo.index.entries:
        print("Nothing to commit, staging area is empty.")
        return
        
    # 1. Build a tree object from the index
    tree_sha = tree_from_index(repo, repo.index)
    
    # 2. Get parent commit
    parent_sha = None
    head_ref = ref_resolve(repo, "HEAD")
    if head_ref:
        parent_sha = head_ref

    # 3. Create the commit object
    kvlm = collections.OrderedDict()
    kvlm[b'tree'] = tree_sha.encode('ascii')
    
    if parent_sha:
        kvlm[b'parent'] = parent_sha.encode('ascii')

    # @TODO: Get author/committer from config (hardcoded for now)
    author_name = "User"
    author_email = "user@example.com"
    timestamp = int(time.time())
    timezone = "+0000" # @FIXME: Should get local timezone
    
    author_line = f"{author_name} <{author_email}> {timestamp} {timezone}"
    
    kvlm[b'author'] = author_line.encode('ascii')
    kvlm[b'committer'] = author_line.encode('ascii')
    kvlm[b''] = args.message.encode('ascii') # Commit message

    commit = GitCommit(repo)
    commit.kvlm = kvlm
    
    # 4. Write the commit to .git/objects/
    commit_sha = object_write(commit)

    # 5. Update HEAD
    # @FIXME: This should update the *branch* HEAD points to, not HEAD itself if it's symbolic
    head_path = repo_file(repo, "HEAD")
    with open(head_path, 'r') as f:
        head_content = f.read().strip()
    
    if head_content.startswith("ref: "):
        ref_path = head_content[5:]
        ref_update(repo, ref_path, commit_sha)
    else: # Detached HEAD
        ref_update(repo, "HEAD", commit_sha)

    print(f"[{ref_path.split('/')[-1]} {commit_sha[:7]}] {args.message.splitlines()[0]}")

# --- Task 4: cmd_rm ---
argsp = argsubparsers.add_parser("rm", help="Remove files from the working tree and from the index")
argsp.add_argument("--cached", action="store_true", help="Only remove from the index")
argsp.add_argument("paths", nargs="+", help="Files to remove")

def cmd_rm(args):
    repo = repo_find()
    repo.index.read()
    
    removed = False
    for path_arg in args.paths:
        path = os.path.relpath(path_arg, repo.worktree).replace(os.path.sep, '/')
        
        entry = repo.index.get_entry(path)
        
        if not entry:
            print(f"fatal: pathspec '{path_arg}' did not match any files", file=sys.stderr)
            continue
            
        # 1. Remove from index
        repo.index.remove(path)
        removed = True
        
        # 2. Optionally remove from working directory
        if not args.cached:
            full_path = os.path.join(repo.worktree, path)
            if os.path.exists(full_path):
                try:
                    os.remove(full_path)
                except Exception as e:
                    print(f"Error removing {full_path}: {e}", file=sys.stderr)
        
        print(f"rm '{path}'")

    if removed:
        repo.index.write()

# --- Task 5: cmd_status ---
argsp = argsubparsers.add_parser("status", help="Show the working tree status")

def get_head_tree(repo):
    """Returns a dict {path: sha} for all files in HEAD commit."""
    head_sha = ref_resolve(repo, "HEAD")
    if not head_sha:
        return {} # No commits yet
        
    commit = object_read(repo, head_sha)
    if not commit or commit.fmt != b'commit':
        return {}
        
    tree_sha = commit.kvlm[b'tree'].decode('ascii')
    
    tree_files = {}
    
    def walk_tree(tree_sha, current_path):
        tree = object_read(repo, tree_sha)
        if not tree or tree.fmt != b'tree':
            return
            
        for leaf in tree.items:
            path = os.path.join(current_path, leaf.path.decode('utf-8'))
            obj = object_read(repo, leaf.sha)
            if obj.fmt == b'tree':
                walk_tree(leaf.sha, path)
            elif obj.fmt == b'blob':
                tree_files[path] = leaf.sha
                
    walk_tree(tree_sha, "")
    return tree_files


def cmd_status(args):
    repo = repo_find()
    repo.index.read()
    
    # --- Get 3 states ---
    # 1. HEAD commit
    head_files = get_head_tree(repo)
    
    # 2. Index (staging area)
    index_files = {e.path.decode('utf-8'): e.sha.hex() for e in repo.index.entries.values()}
    
    # 3. Working Directory
    workdir_files = {} # {path: sha}
    untracked_files = []
    
    for dirpath, dirnames, filenames in os.walk(repo.worktree):
        # Prune ignored directories
        ignored_dirs = []
        for d in dirnames:
            full_path = os.path.join(dirpath, d)
            rel_path = os.path.relpath(full_path, repo.worktree).replace(os.path.sep, '/')
            if repo.ignore.matches(rel_path):
                ignored_dirs.append(d)
        for d in ignored_dirs:
            dirnames.remove(d) # Stops os.walk from descending
            
        for f in filenames:
            full_path = os.path.join(dirpath, f)
            rel_path = os.path.relpath(full_path, repo.worktree).replace(os.path.sep, '/')

            if repo.ignore.matches(rel_path):
                continue

            if rel_path in index_files:
                # File is tracked, check for modification
                try:
                    with open(full_path, 'rb') as fd:
                        data = fd.read()
                    blob = GitBlob(repo, data)
                    workdir_sha = object_write(blob, actually_write=False)
                    workdir_files[rel_path] = workdir_sha
                except Exception:
                    pass # Ignore unreadable files
            else:
                untracked_files.append(rel_path)

    # --- Compare states ---
    staged_new = []
    staged_modified = []
    staged_deleted = []
    
    modified_not_staged = []
    deleted_not_staged = []

    all_paths = set(head_files.keys()) | set(index_files.keys()) | set(workdir_files.keys())

    for path in sorted(list(all_paths)):
        head_sha = head_files.get(path)
        index_sha = index_files.get(path)
        workdir_sha = workdir_files.get(path)

        # Staged changes (Index vs HEAD)
        if index_sha != head_sha:
            if not head_sha and index_sha:
                staged_new.append(path)
            elif head_sha and index_sha:
                staged_modified.append(path)
            elif head_sha and not index_sha:
                staged_deleted.append(path)

        # Unstaged changes (Workdir vs Index)
        if index_sha: # Only check if tracked
            if index_sha != workdir_sha:
                if workdir_sha:
                    modified_not_staged.append(path)
                else:
                    # File is in index but not in workdir
                    # We need to check if it's *supposed* to be there
                    full_path = os.path.join(repo.worktree, path)
                    if not os.path.exists(full_path):
                         deleted_not_staged.append(path)


    # --- Print Status ---
    # @TODO: Get current branch
    print("On branch master") # Hardcoded
    
    if not (staged_new or staged_modified or staged_deleted):
        print("No changes to be committed (use \"git add\" and/or \"git commit -a\")")
    else:
        print("Changes to be committed:")
        print("  (use \"git rm --cached <file>...\" to unstage)")
        for path in staged_new:
            print(f"\t{Fore.GREEN}new file:   {path}{Style.RESET_ALL}")
        for path in staged_modified:
            print(f"\t{Fore.GREEN}modified:   {path}{Style.RESET_ALL}")
        for path in staged_deleted:
            print(f"\t{Fore.GREEN}deleted:    {path}{Style.RESET_ALL}")
        print()

    if modified_not_staged or deleted_not_staged:
        print("Changes not staged for commit:")
        print("  (use \"git add <file>...\" to update what will be committed)")
        print("  (use \"git checkout -- <file>...\" to discard changes in working directory)")
        for path in modified_not_staged:
            print(f"\t{Fore.RED}modified:   {path}{Style.RESET_ALL}")
        for path in deleted_not_staged:
            print(f"\t{Fore.RED}deleted:    {path}{Style.RESET_ALL}")
        print()

    if untracked_files:
        print("Untracked files:")
        print("  (use \"git add <file>...\" to include in what will be committed)")
        for path in sorted(untracked_files):
            print(f"\t{Fore.RED}{path}{Style.RESET_ALL}")
        print()

    if not (staged_new or staged_modified or staged_deleted or 
            modified_not_staged or deleted_not_staged or untracked_files):
        print("nothing to commit, working tree clean")


# --- Task 6: cmd_cat-file ---
argsp = argsubparsers.add_parser("cat-file", help="Provide content of repository objects")
argsp.add_argument("-t", "--type", dest="type", help="Specify the type")
argsp.add_argument("-p", "--pretty", action="store_true", help="Pretty-print the object's content")
argsp.add_argument("object", metavar="object", help="The object to display")

def cmd_cat_file(args):
    repo = repo_find()
    
    # Find the object by name (hash, tag, branch, etc.)
    fmt = args.type.encode('ascii') if args.type else None
    sha = object_find(repo, args.object, fmt=fmt)
    
    if not sha:
        print(f"fatal: Not a valid object name {args.object}", file=sys.stderr)
        return

    obj = object_read(repo, sha)
    
    if not obj:
        print(f"fatal: object {sha} not found", file=sys.stderr)
        return
        
    if args.type:
        # User requested a specific type. Check if it matches.
        if obj.fmt.decode('ascii') != args.type:
            print(f"fatal: object {sha} is a {obj.fmt.decode('ascii')}, not a {args.type}", file=sys.stderr)
            return
            
    if args.pretty:
        # Pretty-print
        if obj.fmt == b'blob':
            sys.stdout.buffer.write(obj.blobdata)
        elif obj.fmt == b'tree':
            for item in obj.items:
                print("{0} {1} {2}\t{3}".format(
                    "0" * (6 - len(item.mode)) + item.mode.decode("ascii"),
                    object_read(repo, item.sha).fmt.decode("ascii"),
                    item.sha,
                    item.path.decode("ascii")))
        elif obj.fmt == b'commit':
            print(f"tree {obj.kvlm[b'tree'].decode('ascii')}")
            if b'parent' in obj.kvlm:
                parents = obj.kvlm[b'parent']
                if not isinstance(parents, list): parents = [parents]
                for p in parents:
                    print(f"parent {p.decode('ascii')}")
            print(f"author {obj.kvlm[b'author'].decode('ascii')}")
            print(f"committer {obj.kvlm[b'committer'].decode('ascii')}")
            print()
            print(obj.kvlm[b''].decode('ascii'))
        elif obj.fmt == b'tag':
            print(f"object {obj.kvlm[b'object'].decode('ascii')}")
            print(f"type {obj.kvlm[b'type'].decode('ascii')}")
            print(f"tag {obj.kvlm[b'tag'].decode('ascii')}")
            print(f"tagger {obj.kvlm[b'tagger'].decode('ascii')}")
            print()
            print(obj.kvlm[b''].decode('ascii'))
    else:
        # Just dump raw serialized data (original behavior)
        sys.stdout.buffer.write(obj.serialize())

# --- Task 7: cmd_merge (Simplified Stub) ---
argsp = argsubparsers.add_parser("merge", help="Merge two branches")
argsp.add_argument("branch", help="The branch to merge in")
argsp.add_argument("-m", metavar="message", dest="message", help="Commit message")

def cmd_merge(args):
    repo = repo_find()
    
    # 1. Get current HEAD commit
    head_sha = ref_resolve(repo, "HEAD")
    if not head_sha:
        print("fatal: Not on any branch", file=sys.stderr)
        return
        
    # 2. Get the commit to merge
    merge_sha = object_find(repo, args.branch, fmt=b'commit')
    if not merge_sha:
        print(f"fatal: '{args.branch}' does not point to a commit", file=sys.stderr)
        return
        
    if head_sha == merge_sha:
        print("Already up to date.")
        return

    # @TODO: Find common ancestor
    # @TODO: Implement 3-way merge of trees
    # @TODO: Handle fast-forward merges
    
    print(f"Merging branch '{args.branch}' (commit {merge_sha[:7]}) into HEAD (commit {head_sha[:7]}).")
    print("WARNING: This is a simplified merge. A real 3-way merge is not implemented.")
    print("A merge commit will be created, but the tree will be identical to HEAD.")
    print("This is NOT real Git behavior and is just a placeholder for the task.")

    # 3. Create a merge commit
    
    # Use HEAD's tree as a placeholder
    head_commit = object_read(repo, head_sha)
    tree_sha = head_commit.kvlm[b'tree']
    
    kvlm = collections.OrderedDict()
    kvlm[b'tree'] = tree_sha
    kvlm[b'parent'] = [head_sha.encode('ascii'), merge_sha.encode('ascii')] # Two parents
    
    author_name = "User"
    author_email = "user@example.com"
    timestamp = int(time.time())
    timezone = "+0000"
    author_line = f"{author_name} <{author_email}> {timestamp} {timezone}"
    
    kvlm[b'author'] = author_line.encode('ascii')
    kvlm[b'committer'] = author_line.encode('ascii')
    
    if args.message:
        message = args.message
    else:
        message = f"Merge branch '{args.branch}'"
        
    kvlm[b''] = message.encode('ascii')

    commit = GitCommit(repo)
    commit.kvlm = kvlm
    commit_sha = object_write(commit)

    # 4. Update HEAD
    head_path = repo_file(repo, "HEAD")
    with open(head_path, 'r') as f:
        head_content = f.read().strip()
    
    if head_content.startswith("ref: "):
        ref_path = head_content[5:]
        ref_update(repo, ref_path, commit_sha)
    else:
        ref_update(repo, "HEAD", commit_sha)

    print(f"Merge commit created: {commit_sha[:7]}")
    print("Note: Working directory and index were NOT updated.")


# --- Task 8: cmd_rebase (Stub) ---
argsp = argsubparsers.add_parser("rebase", help="Reapply commits on top of another base tip")
argsp.add_argument("onto", help="The new base to rebase onto")

def cmd_rebase(args):
    repo = repo_find()
    print(f"Rebasing current branch onto '{args.onto}'...")
    print("ERROR: 'rebase' is not implemented.")
    print("A full rebase requires finding a common ancestor,")
    print("cherry-picking a range of commits, and handling potential conflicts.")
    print("This is a very complex operation and is beyond the scope of this exercise.")


# --- Task 9: cmd_checkout ---
argsp = argsubparsers.add_parser("checkout", help="Switch branches or restore working tree files")
argsp.add_argument("commit", help="The commit or branch to checkout")
argsp.add_argument("path", nargs="?", help="The EMPTY directory to checkout on (old behavior)")

def tree_checkout(repo, tree, path):
    """Recursively check out a tree object to a given path."""
    for item in tree.items:
        obj = object_read(repo, item.sha)
        dest = os.path.join(path, item.path.decode('utf-8'))

        if obj.fmt == b'tree':
            os.makedirs(dest, exist_ok=True)
            tree_checkout(repo, obj, dest)
        elif obj.fmt == b'blob':
            # Make sure parent directory exists
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            with open(dest, 'wb') as f:
                f.write(obj.blobdata)

def clean_worktree(repo):
    """Remove all tracked files and directories from the worktree."""
    repo.index.read()
    
    # Get all paths from index, sorted by length DESC to remove files before dirs
    paths = sorted(repo.index.entries.keys(), key=len, reverse=True)
    
    for path_str in paths:
        full_path = os.path.join(repo.worktree, path_str)
        if os.path.exists(full_path):
            try:
                if os.path.isfile(full_path) or os.path.islink(full_path):
                    os.remove(full_path)
            except Exception as e:
                print(f"Warning: could not remove {full_path}: {e}", file=sys.stderr)

    # @TODO: Remove empty directories
    

def cmd_checkout(args):
    repo = repo_find()

    if args.path:
        # This is the *old* behavior: checkout to a NEW directory
        # We keep it for compatibility with the original prompt
        print(f"WARNING: Checking out to new directory '{args.path}'. This is deprecated.")
        obj = object_read(repo, object_find(repo, args.commit))
        if obj.fmt == b'commit':
            obj = object_read(repo, obj.kvlm[b'tree'].decode("ascii"))
        
        if os.path.exists(args.path):
            if not os.path.isdir(args.path):
                raise Exception(f"Not a directory {args.path}!")
            if os.listdir(args.path):
                raise Exception(f"Not empty {args.path}!")
        else:
            os.makedirs(args.path)
            
        tree_checkout(repo, obj, os.path.realpath(args.path))
        return

    # --- This is the *new*, correct 'git checkout' behavior ---
    
    # 1. Check for uncommitted changes
    # (Simplified check: just see if index and workdir are dirty)
    # A full check would use the 'cmd_status' logic
    repo.index.read()
    if repo.index.entries: # This is a weak check, but good enough for here
        # @TODO: Implement a proper dirty check using 'status' logic
        pass 
        # print("Warning: uncommitted changes may be overwritten.", file=sys.stderr)

    # 2. Find the target commit
    sha = object_find(repo, args.commit, fmt=b'commit')
    if not sha:
        print(f"fatal: pathspec '{args.commit}' did not match any file(s) known to git", file=sys.stderr)
        return
        
    commit = object_read(repo, sha)
    tree = object_read(repo, commit.kvlm[b'tree'].decode('ascii'))
    
    # 3. Clear the working directory and index
    # (A real git checkout would be smarter, but this is simple)
    clean_worktree(repo)
    repo.index.entries = {}
    
    # 4. Populate workdir from the new tree
    tree_checkout(repo, tree, repo.worktree)
    
    # 5. Populate index from the new tree
    def populate_index(tree_sha, current_path):
        tree = object_read(repo, tree_sha)
        for leaf in tree.items:
            path = os.path.join(current_path, leaf.path.decode('utf-8')).replace(os.path.sep, '/')
            obj = object_read(repo, leaf.sha)
            
            if obj.fmt == b'tree':
                populate_index(leaf.sha, path)
            elif obj.fmt == b'blob':
                full_path = os.path.join(repo.worktree, path)
                try:
                    stat = os.stat(full_path)
                    repo.index.add(path, bytes.fromhex(leaf.sha), stat)
                except Exception as e:
                    print(f"Warning: could not stat {full_path} for index: {e}", file=sys.stderr)

    populate_index(commit.kvlm[b'tree'].decode('ascii'), "")
    repo.index.write()

    # 6. Update HEAD
    # Check if we're checking out a branch or a specific commit (detached HEAD)
    is_branch = False
    ref_path = None
    
    # Check branches
    branch_ref_path = os.path.join(repo.gitdir, "refs", "heads", args.commit)
    if os.path.exists(branch_ref_path):
        is_branch = True
        ref_path = os.path.join("refs", "heads", args.commit)
        
    # @TODO: Check tags
        
    if is_branch:
        # Update HEAD to point to the branch
        with open(repo_file(repo, "HEAD"), "w") as f:
            f.write(f"ref: {ref_path}\n")
        print(f"Switched to branch '{args.commit}'")
    else:
        # Detached HEAD
        with open(repo_file(repo, "HEAD"), "w") as f:
            f.write(f"{sha}\n")
        print(f"Note: checking out '{args.commit}'.")
        print("You are in 'detached HEAD' state.")


# --- Task 10: cmd_log ---
argsp = argsubparsers.add_parser("log", help="Display history of a given commit.")
argsp.add_argument("commit", default="HEAD", nargs="?", help="Commit to start at.")

def cmd_log(args):
    repo = repo_find()
    
    print() # Initial newline for spacing
    
    sha = object_find(repo, args.commit, fmt=b'commit')
    if not sha:
        print(f"fatal: ambiguous argument '{args.commit}': unknown revision", file=sys.stderr)
        return
        
    seen = set()

    while sha and sha not in seen:
        seen.add(sha)
        commit = object_read(repo, sha)
        
        if not commit:
            print(f"fatal: could not read commit {sha}", file=sys.stderr)
            break
            
        # Print log entry
        print(f"{Fore.YELLOW}commit {sha}{Style.RESET_ALL}")
        
        # Author
        if b'author' in commit.kvlm:
            print(f"Author: {commit.kvlm[b'author'].decode('ascii')}")
            
        # Date (from committer)
        if b'committer' in commit.kvlm:
            committer_line = commit.kvlm[b'committer'].decode('ascii')
            # Extract timestamp
            match = re.search(r'(\d{10})', committer_line)
            if match:
                timestamp = int(match.group(1))
                print(f"Date:   {time.strftime('%a %b %d %H:%M:%S %Y %z', time.localtime(timestamp))}")

        # Message
        print()
        message = commit.kvlm[b''].decode('ascii')
        for line in message.splitlines():
            print(f"    {line}")
        print()
        
        # Get parent
        if b'parent' not in commit.kvlm:
            break # Initial commit
            
        parents = commit.kvlm[b'parent']
        if isinstance(parents, list):
            # Merge commit, follow first parent
            sha = parents[0].decode('ascii')
        else:
            sha = parents.decode('ascii')

# --- Git Object (cont.) ---
def kvlm_parse(raw, start=0, dct=None):
    if not dct:
        dct = collections.OrderedDict()
    spc = raw.find(b' ', start)
    nl = raw.find(b'\n', start)

    if (spc < 0) or (nl < spc):
        assert(nl == start or nl == -1) # Handle no newline at end of file
        if nl == -1: nl = len(raw)
        dct[b''] = raw[start+1 if nl==start else start:]
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
        return kvlm_serialize(self.kvlm)

# --- Git Tree (cont.) ---
class GitTreeLeaf(object):
    def __init__(self, mode, path, sha):
        self.mode = mode
        self.path = path
        self.sha = sha # This should be the hex SHA

def tree_parse_one(raw, start=0):
    x = raw.find(b' ', start)
    assert(x-start == 5 or x-start==6)
    mode = raw[start:x]
    y = raw.find(b'\x00', x)
    path = raw[x+1:y]
    # Read the 20-byte *binary* SHA
    sha_bin = raw[y+1:y+21]
    sha_hex = sha_bin.hex()
    return y+21, GitTreeLeaf(mode, path, sha_hex)

def tree_parse(raw):
    pos = 0
    max_len = len(raw)
    ret = list()
    while pos < max_len:
        pos, data = tree_parse_one(raw, pos)
        ret.append(data)
    return ret

def tree_serialize(obj):
    ret = b''
    for i in obj.items:
        ret += i.mode
        ret += b' '
        ret += i.path
        ret += b'\x00'
        # Convert hex sha string back to 20-byte binary
        ret += bytes.fromhex(i.sha)
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
            item.mode.decode("ascii").zfill(6),
            object_read(repo, item.sha).fmt.decode("ascii"),
            item.sha,
            item.path.decode("ascii")))

# --- Refs and Tagging ---
def ref_resolve(repo, ref):
    """Find the SHA a ref points to."""
    path = repo_file(repo, ref)
    if not os.path.exists(path):
        # Try common prefixes
        if ref == "HEAD" and not os.path.exists(repo_file(repo, "HEAD")):
            return None # No HEAD yet
        common_refs = [
            f"{ref}",
            f"refs/{ref}",
            f"refs/tags/{ref}",
            f"refs/heads/{ref}"
        ]
        for r in common_refs:
            if os.path.exists(repo_file(repo, r)):
                path = repo_file(repo, r)
                break
        else:
            return None # No ref found

    with open(path, 'r') as fp:
        data = fp.read().strip()
    if data.startswith("ref: "):
        return ref_resolve(repo, data[5:])
    else:
        return data

def ref_update(repo, ref_name, sha):
    """Update a ref to point to a new SHA."""
    path = repo_file(repo, ref_name, mkdir=True)
    with open(path, 'w') as f:
        f.write(f"{sha}\n")

def ref_list(repo, path=None):
    if not path:
        path = repo_dir(repo, "refs")
    ret = collections.OrderedDict()
    for f in sorted(os.listdir(path)):
        can = os.path.join(path, f)
        if os.path.isdir(can):
            ret[f] = ref_list(repo, can)
        else:
            # We need to resolve the ref relative to the gitdir
            rel_path = os.path.relpath(can, repo.gitdir)
            ret[f] = ref_resolve(repo, rel_path)
    return ret

argsp = argsubparsers.add_parser("show-ref", help="List references.")

def cmd_show_ref(args):
    repo = repo_find()
    refs = ref_list(repo)
    show_ref(repo, refs, prefix="refs")

def show_ref(repo, refs, with_hash=True, prefix=""):
    for k, v in refs.items():
        if type(v) == str:
            print ("{0}{1}{2}".format(
                v + " " if with_hash else "", 
                prefix + "/" if prefix else "", 
                k))
        else:
            show_ref(repo, v, with_hash=with_hash, prefix="{0}{1}{2}".format(prefix, "/" if prefix else "", k))

class GitTag(GitCommit):
    fmt = b'tag'
    # Note: GitTag inherits from GitCommit for kvlm parsing,
    # but it's a distinct object type.

argsp = argsubparsers.add_parser( "tag", help="List and create tags")
argsp.add_argument("-a", action="store_true", dest="create_tag_object", help="Whether to create a tag object")
argsp.add_argument("name", nargs="?", help="The new tag's name")
argsp.add_argument("object", default="HEAD", nargs="?", help="The object the new tag will point to")

def cmd_tag(args):
    repo = repo_find()
    if args.name:
        # Create a tag
        sha = object_find(repo, args.object, fmt=b'commit')
        if not sha:
            print(f"fatal: object {args.object} not found", file=sys.stderr)
            return
            
        if args.create_tag_object:
            # Create an annotated tag object
            kvlm = collections.OrderedDict()
            kvlm[b'object'] = sha.encode('ascii')
            kvlm[b'type'] = b'commit'
            kvlm[b'tag'] = args.name.encode('ascii')
            # @TODO: Get tagger from config
            kvlm[b'tagger'] = b'User <user@example.com> ' + str(int(time.time())).encode('ascii') + b' +0000'
            # @TODO: Get tag message
            kvlm[b''] = b"Tag message"
            
            tag = GitTag(repo)
            tag.kvlm = kvlm
            tag_sha = object_write(tag)
            ref_update(repo, f"refs/tags/{args.name}", tag_sha)
        else:
            # Create a lightweight tag (just a ref)
            ref_update(repo, f"refs/tags/{args.name}", sha)
    else:
        # List tags
        refs = ref_list(repo)
        if "tags" in refs:
            show_ref(repo, refs["tags"], with_hash=False, prefix="tags")

# --- Object Finding ---
def object_resolve(repo, name):
    """Resolve name to an object hash in repo."""
    candidates = list()
    hashRE = re.compile(r"^[0-9A-Fa-f]{4,40}$")

    if not name.strip():
        return None

    # 1. Check for refs
    sha = ref_resolve(repo, name)
    if sha:
        return [sha]

    # 2. Check for hash
    if hashRE.match(name):
        if len(name) == 40:
            return [ name.lower() ]
        
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
    sha_list = object_resolve(repo, name)

    if not sha_list:
        raise Exception("No such reference {0}.".format(name))
    if len(sha_list) > 1:
        raise Exception("Ambiguous reference {0}: Candidates are:\n - {1}.".format(name,  "\n - ".join(sha_list)))
    
    sha = sha_list[0]

    if not fmt:
        return sha

    # Follow tags and commits if needed
    while True:
        obj = object_read(repo, sha)
        if not obj:
            return None # Object not found

        if obj.fmt == fmt:
            return sha

        if not follow:
            return None

        if obj.fmt == b'tag':
            sha = obj.kvlm[b'object'].decode("ascii")
        elif obj.fmt == b'commit' and fmt == b'tree':
            sha = obj.kvlm[b'tree'].decode("ascii")
        else:
            return None # Can't follow further

# --- Other Commands ---
argsp = argsubparsers.add_parser("rev-parse", help="Parse revision (or other objects )identifiers")
argsp.add_argument("--type", dest="type", choices=["blob", "commit", "tag", "tree"], default=None, help="Specify the expected type")
argsp.add_argument("name", help="The name to parse")

def cmd_rev_parse(args):
    if args.type:
        fmt = args.type.encode()
    else:
        fmt = None
    repo = repo_find()
    print (object_find(repo, args.name, fmt, follow=True))

argsp = argsubparsers.add_parser("hash-object", help="Compute object ID and optionally creates a blob from a file")
argsp.add_argument("-t", metavar="type", dest="type", choices=["blob", "commit", "tag", "tree"], default="blob", help="Specify the type")
argsp.add_argument("-w", dest="write", action="store_true", help="Actually write the object into the database")
argsp.add_argument("path", help="Read object from <file>")

def cmd_hash_object(args):
    if args.write:
        repo = GitRepository(".")
    else:
        repo = None
    
    with open(args.path, "rb") as fd:
        data = fd.read()
    
    # Choose constructor
    if   args.type == 'commit': obj=GitCommit(repo, data)
    elif args.type == 'tree'  : obj=GitTree(repo, data)
    elif args.type == 'tag'   : obj=GitTag(repo, data)
    elif args.type == 'blob'  : obj=GitBlob(repo, data)
    else:
        raise Exception("Unknown type %s!" % args.type)

    print(object_write(obj, repo))


# --- Main Execution ---

# Add color support for status
try:
    import colorama
    from colorama import Fore, Style
    colorama.init()
except ImportError:
    # Create dummy color classes if colorama is not installed
    class DummyColor:
        def __getattr__(self, name):
            return ""
    Fore = DummyColor()
    Style = DummyColor()
    Fore.GREEN = ""
    Fore.RED = ""
    Fore.YELLOW = ""
    Style.RESET_ALL = ""


if __name__ == "__main__":
    main()