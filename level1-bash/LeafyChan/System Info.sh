#!/bin/bash
echo "System Information:"
echo "--------------------"
uname -a
echo
echo "Disk Usage:"
df -h | head -n 10
echo
echo "Uptime:"
uptime