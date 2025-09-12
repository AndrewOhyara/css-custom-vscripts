### NOTHING HERE BELONGS TO ME. MOST OF THESE FILES ARE HELPERS, EXAMPLES AND EXPERIMENTS TO TAKE AS A REFERENCE

To run any of those files, you can use script_execute <name_of_the_file> (in-game commmand) OR include them in your mapspawn.nut to run them automatically per map load.
### The "mapspawn.nut" file must be created on the cstrike/script/vscripts folder (Create the "vscripts" folder if there's no folder).
## Your "mapspawn.nut" file:
```Squirrel
// This will include your script in the root scope. It's the scope "mapspawn.nut" runs.
IncludeScript("name_of_the_file", getrootable());

// Including it in a specific scope (ex. a table or an entity scope)
// The scope must exists before including any script file.
// The scope parameter can be null if you don't want to define a scope.
IncludeScript("name_of_the_file", your_scope)

// EXAMPLE
// Include "gift_grab_achievement.nut" in the root scope.
IncludeScript("gift_grab_achievement", getroottable());
```
# NOTES
- You can install the scripts in the 'custom' folder if they are wihtin this path: custom/<my_mod_folder>/scripts/vscripts
- Most of these files are independent and don't require anything. Not even "cs_custom_functions.nut".
- You may need notepad++ to open ".nut" files.
