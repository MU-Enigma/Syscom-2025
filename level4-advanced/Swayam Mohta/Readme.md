# FIXES

## Minimal Git-like VCS

A simple Python-based version control system inspired by Git. Features include repository initialization, adding files, committing changes, and checking status.

## Features

- `init`: Initialize a new repository.
- `add`: Add files to the staging area.
- `commit`: Commit changes with a message.
- `rm`: Remove files from the working directory.
- `status`: Show ignored files.

## Changes

1. **Error Handling**: Added a warning for unrecognized object types in `object_read()`.
2. **Commit Handling**: Defaulted author/committer to "Anonymous" if not provided.
3. **Repo Setup**: Improved handling of missing config files during repo initialization.
4. **Gitignore**: Fixed gitignore logic to properly detect ignored files.
