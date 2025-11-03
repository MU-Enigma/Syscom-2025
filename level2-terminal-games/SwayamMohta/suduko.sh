#!/bin/bash
# Simple 4x4 Sudoku generator and prompt

grid=(0 0 3 4 3 4 0 0 0 0 4 3 0 0 1 2)

echo "Sudoku Mini (4x4)"
for i in {0..3}; do
  for j in {0..3}; do
    idx=$((i*4+j))
    [[ ${grid[idx]} -eq 0 ]] && echo -n "_ " || echo -n "${grid[idx]} "
  done
  echo
done
