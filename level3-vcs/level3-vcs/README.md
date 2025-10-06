
# Level 3 - Fix Issues in the Included VCS Codebase

This folder contains a deliberately-buggy version of a simple Version Control System (libuwuvc.py).
Contributors should pick any of the listed issues and submit fixes by creating a branch and PR inside this repo.

## Known issues intentionally included in this file
1. tree_serialize incomplete → checkout / ls-tree fail
   - The function does not write SHA bytes for tree entries, breaking nested trees.
2. object_hash crashes if repo is None → hash-object -w False fails
   - object_hash always attempts to write objects even when no repo is provided.
3. kvlm_parse fails on empty commit message → commit creation broken
   - The parser asserts that message exists; whitespace-only messages break it.
4. Ambiguous short SHA hashes → rev-parse / checkout errors
   - object_resolve returns multiple candidates but the resolver silently picks the first one.
5. Infinite recursion in ref_resolve → show-ref / rev-parse hang
   - Circular refs not detected -> infinite recursion possible.
6. cmd_checkout fails on non-empty directories → checkout blocked
   - Checkout refuses to proceed if target directory is non-empty.
7. GitIndexEntry unused → add / commit functionality incomplete
   - Index fields are present but never populated or used.
8. cmd_tag missing tag_create implementation → tag creation broken
   - tag_create is referenced but not implemented; creating tags raises NameError.
9. tree_checkout assumes directories don’t exist → checkout fails on nested dirs
   - Uses os.mkdir without existence checks, raising errors if parents already exist.
10. log_graphviz crashes on malformed/initial commit → log visualization broken
   - Assumes 'parent' key exists in commit kvlm and crashes otherwise.

## How to contribute
- Create a branch: `git checkout -b fix-<your-issue>`
- Make changes and tests
- Commit and push, then open a PR with a clear description of your fix and why it works.

Happy hacking!
