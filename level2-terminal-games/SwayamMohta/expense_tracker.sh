#!/bin/bash


FILE="expenses.txt"

while true; do
    clear
    echo "=============================="
    echo "      MINI EXPENSE TRACKER"
    echo "=============================="
    echo "1) Add Expense"
    echo "2) View Expenses"
    echo "3) View Total by Category"
    echo "4) Exit"
    echo "=============================="
    read -p "Enter choice [1-4]: " choice

    case $choice in
        1)
            read -p "Enter amount: " amount
            read -p "Enter category: " category
            read -p "Enter description: " desc
            echo "$amount,$category,$desc" >> "$FILE"
            echo "Expense added!"
            ;;
        2)
            if [ -s "$FILE" ]; then
                echo ""
                echo "Amount | Category | Description"
                echo "-------------------------------"
                column -t -s"," "$FILE"
            else
                echo "No expenses yet!"
            fi
            ;;
        3)
            if [ -s "$FILE" ]; then
                echo ""
                echo "Total Expenses by Category:"
                awk -F, '{sum[$2]+=$1} END {for (cat in sum) print cat ": $" sum[cat]}' "$FILE"
            else
                echo "No expenses yet!"
            fi
            ;;
        4)
            echo "Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done
