### NOTHING HERE BELONGS TO ME. MOST OF THESE FILES ARE HELPERS, EXAMPLES AND EXPERIMENTS TO TAKE AS A REFERENCE

To run any of those files, you can use script_execute <name_of_the_file> (in-game commmand) OR include them in your mapspawn.nut to run them automatically per map load.
### The "mapspawn.nut" file must be created on the cstrike/script/vscripts folder (Create the "vscripts" folder if there's no folder).
## Your "mapspawn.nut" file:
```Squirrel
// This will include your script in the root scope. It's the scope "mapspawn.nut" runs.
IncludeScript("name_of_the_file", getrootable());

// Including it in a specific scope (ex. a table or an entity scope)
// Your scope must exists before including any script file
IncludeScript("name_of_the_file", your_scope)

// EXAMPLE
// Include "gift_grab_achievement.nut" in the root scope.
IncludeScript("gift_grab_achievement", getroottable());
```
# NOTES
- Most of these files are independent and don't require anything. Not even "cs_custom_functions.nut".
- You may need notepad++ to open ".nut" files.
