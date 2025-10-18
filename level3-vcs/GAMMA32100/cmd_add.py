import os, sys, hashlib, json
"""This is GAMMA ignore the comments if u wanna i have made the comments for my own understanding, i have written parameters and returns."""

def sha1(data):
    """
    Parameters:
    raw bytes to hash.

    Returns:
    hex SHA-1 digest.
    """
    return hashlib.sha1(data).hexdigest()

def write_object(data):
    """
    Parameters:
    file contents to store.

    Returns:
    hex SHA-1 of the header+data.
    """
    h = sha1(b'blob %d\0' % len(data) + data)
    path = os.path.join('.git', 'objects', h[:2], h[2:])
   
    os.makedirs(os.path.dirname(path), exist_ok=True)
    
    if not os.path.exists(path):
        with open(path, 'wb') as f:
            f.write(data)  
    return h

def load_index():
    """
    Returns an empty dict when no index file exists.
    when an index file exists it Returns: 
     mapping of path -> metadata (see `save_index`).
    """
    if not os.path.exists('.git/index'):
        return {}
    with open('.git/index') as f:
        return json.load(f)

def save_index(idx):
    with open('.git/index', 'w') as f:
        json.dump(idx, f, indent=2)

def ignored(name):
    """parameters:
    file path to check.
    returns:
    True if the file is ignored based on .gitignore, False otherwise."""
    if not os.path.exists('.gitignore'):
        return False
    with open('.gitignore') as f:
        for line in f:
            if line.strip() and not line.startswith('#'):
                if name.startswith(line.strip().rstrip('/')):
                    return True
    return False

def add_file(path, idx):
    """paraemeters: path - file path to add
    idx - index dictionary to update

    returns: None 
    """
    
    if os.path.isdir(path) or ignored(path):
        return
    with open(path, 'rb') as f:
        data = f.read()
    h = write_object(data)
    st = os.stat(path)
  
    idx[path] = {'hash': h, 'size': st.st_size, 'mtime': st.st_mtime}

def main():
    if len(sys.argv) < 2:
        print("usage: cmd_add <files>")
        sys.exit(1)
    idx = load_index()
    for p in sys.argv[1:]:
        if os.path.exists(p):
            add_file(p, idx)
    save_index(idx)

if __name__ == '__main__':
    main()
