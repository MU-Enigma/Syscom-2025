#!/bin/bash
echo "=== Reaction Timer ==="
echo "Press ENTER when you see 'GO!'"
sleep $((RANDOM % 3 + 2))
echo "GO!"
start=$(date +%s%3N)
read
end=$(date +%s%3N)
diff=$((end - start))
echo "⏱ Reaction time: ${diff} ms"
