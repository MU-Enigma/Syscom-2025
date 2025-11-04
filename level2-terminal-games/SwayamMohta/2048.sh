#!/bin/bash
# Minimal 2x2 2048 clone

grid=(0 0 0 0)

function print_grid {
  echo "2048 Mini"
  for i in {0..1}; do
    for j in {0..1}; do
      idx=$((i*2+j))
      [[ ${grid[idx]} -eq 0 ]] && echo -n ". " || echo -n "${grid[idx]} "
    done
    echo
  done
}

# Add random 2
idx=$((RANDOM % 4))
grid[$idx]=2
print_grid

