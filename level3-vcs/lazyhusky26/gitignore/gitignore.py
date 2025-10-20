import fnmatch

def read_gitignore(repo):
    ignore_path = os.path.join(repo.worktree, ".gitignore")
    patterns = []

    if not os.path.exists(ignore_path):
        return patterns

    with open(ignore_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            patterns.append(line)

    return patterns

def is_ignored(path, ignore_patterns):
    ignored = False
    for pattern in ignore_patterns:
        if pattern.startswith("!"):
            if matches_pattern(path, pattern[1:]):
                return False
        else:
            if matches_pattern(path, pattern):
                ignored = True
    return ignored

def matches_pattern(path, pattern):
    if pattern.endswith("/"):
        return path.startswith(pattern)
    else:
        return fnmatch.fnmatch(path, pattern)
