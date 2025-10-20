#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

NAME="${1:-}"; NUM="${2:-}"

# Prompt only if missing
if [ -z "${NAME}" ]; then
  read -r -p "Enter your name: " NAME
fi
if [ -z "${NUM}" ]; then
  read -r -p "Enter a favorite integer: " NUM
fi

# Validate integer
if ! [[ "$NUM" =~ ^-?[0-9]+$ ]]; then
  printf "Error: '%s' is not an integer.\n" "$NUM" >&2
  exit 1
fi

printf "Hi %s! Your number is %d.\n" "$NAME" "$NUM"
