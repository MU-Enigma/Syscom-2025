
The Hunt for the Golden KeyThis is a text-based terminal adventure game written entirely in Bash. The objective is to find the "Golden Key" hidden somewhere in a 5x5 grid.Rules of the GameObjective: Find the Golden Key hidden at a random coordinate (X, Y) within a 5x5 grid (coordinates 0,0 to 4,4).Starting Position: Your starting position is also randomized, but guaranteed to be different from the Key's location.Movement: You navigate the room by entering single-letter commands:N or n: Move North (Increase Y coordinate).S or s: Move South (Decrease Y coordinate).E or e: Move East (Increase X coordinate).W or w: Move West (Decrease X coordinate).Feedback: After every successful move, you receive two types of feedback:Directional Hint: Tells you if you are "Getting closer..." or "Moving away..." based on the distance to the Key.Thermal Hint: Provides a general location estimate:HOT! (1 or 2 steps away)Warm (3 or 4 steps away)Cold (more than 4 steps away)Win Condition: The game ends instantly when your player lands on the Key's coordinates.How to RunSave the Script: Ensure the file golden_key_hunt.sh is saved in your desired directory (e.g., level2-terminal-games/your-username/).Make Executable: In your terminal, navigate to the directory and give the script execute permissions:chmod +x golden_key_hunt.sh
Execute: Run the script from the terminal:./golden_key_hunt.sh
Example Input/OutputThe output colors (RED, YELLOW, GREEN) will be displayed in the terminal.======================================================
THE HUNT FOR THE GOLDEN KEY (5x5 GRID)
======================================================
You are in a dark, empty room. Find the hidden key.
Use thermal feedback to guide your movement.

Initial Location: X=1 Y=3 | Moves: 0
Starting Thermal: Cold (more than 4 steps away)

------------------------------------------------------
Current Location: X=1 Y=3 | Moves: 0
Enter direction (N/S/E/W) or Q to quit: 
n

Getting closer...
New Thermal Hint: Warm (3 or 4 steps away)

------------------------------------------------------
Current Location: X=1 Y=4 | Moves: 1
Enter direction (N/S/E/W) or Q to quit: 
e

Getting closer...
New Thermal Hint: HOT! (1 or 2 steps away)

------------------------------------------------------
Current Location: X=2 Y=4 | Moves: 2
Enter direction (N/S/E/W) or Q to quit: 
w

Moving away...
New Thermal Hint: Warm (3 or 4 steps away)

------------------------------------------------------
Current Location: X=1 Y=4 | Moves: 3
Enter direction (N/S/E/W) or Q to quit: 
e

Getting closer...
New Thermal Hint: HOT! (1 or 2 steps away)

------------------------------------------------------
Current Location: X=2 Y=4 | Moves: 4
Enter direction (N/S/E/W) or Q to quit: 
s

Getting closer...
New Thermal Hint: You've found the Golden Key!

======================================================
SUCCESS! You found the Golden Key!
Total Moves: 5
======================================================
