#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Strings
NAME="${1:-}"                       # from arg or empty
NAME="${NAME:-Guest}"               # default if empty
printf "Name: %s\n" "$NAME"

# Numbers
A=7
B=3
SUM=$((A + B))
MUL=$((A * B))
printf "A=%d B=%d SUM=%d MUL=%d\n" "$A" "$B" "$SUM" "$MUL"

# Exported env var example
export APP_MODE="dev"
printf "APP_MODE=%s (exported)\n" "$APP_MODE"
