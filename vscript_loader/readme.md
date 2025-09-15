# Vscript Loader
A simple loader for vscript files for those game which doesn't have the l4d2's addon script loader system (aka mapspawn_addon, director_base_addon, scriptedmode_addon).

Runs at map spawn and between round. Loads a list of vscripts with error handling. Includes a table for scoped scripts.

Supported games: TF2, CSS, DODS, HL2DM

# Index
- [Installation](#installation)
- [Files](#files)
- [Global variables](#global-variables)
- [Vscript file list](#vscript-list-file)
- [Notes](#notes)
- [TODO list](#todo-list)

## Installation
1. Download the folder and move it to: <game_folder>/custom

## Files
- mapsapwn.nut -> The loader script. Runs at every map load.
- vscript_file_list_all.nut -> The vscript list you can edit.

## Global Variables
```squirrel
g_VscriptFileOrder <- 1;                        // File counter
g_iVscriptMaxLoad <- 256;                       // Maximum allowed vscript files to be loaded
g_VscriptLoadedCount <- 0;                      // Successful loaded files counter
g_VscriptListFile <- "vscript_loader_list_all"; // list file path
g_VscriptFileList <- [];                        // List of vscript files
g_MapScript <- {}                               // Scope for round-only scripts (like l4d2's director_base_addon).

// Scoped scripts will be referenced here if 'scope' is not null or root.
// Example: g_VscriptScopedScripts["my_script_file.nut"] will reference its scope
g_VscriptScopedScripts <- {};
```

## Vscript List File
In the list file:
```squirrel
// OPTIONAL: The ID for the list. Can be any value. 
// Use it when you want to detect any overrides from custom or vscripts folder.
g_VscriptListId <- "my_default_list_v1";

 // Max files to be loaded. Can be set to more but for now it's 256 by default. 
g_iVscriptFileLoadMax <- 256; 

/*
// EXAMPLE - If "dummy_script_tob_load" doesn't exist, it will return an exception and continue with the list.
VscriptLoader.AddScript({
    path = "dummy_script_tob_load" 
    scope = null    // setting scope to null or this will load the file in the root scope.
})
*/

// Add your scripts here
VscriptLoader.AddScript({
    path = "l4d2-like_muzzleflashes.nut"
    scope = null    // if round_only is true, the scope is ignored and set to g_MapScript
    round_only = true	// This will make the loader execute the script every round
})

VscriptLoader.AddScript({
    path = "gift_grab_achievement"
    scope = null
})

VscriptLoader.AddScript({
    path = "dissolver-bullet_tracer"
    scope = this
})

VscriptLoader.AddScript({
    path = "multijump"	// If not 'scope', the scope will be set to the root scope.
})

VscriptLoader.AddScript({
    path = "dummy_temp"
    scope = this    // if round_only is true, the scope is ignored and set to g_MapScript
    round_only = true
})

/*
The console may print something like this:
[VSCRIPT LOADER] Loading vscript file list from vscript_loader_list_all.nut
[VSCRIPT LOADER] Active list ID: my_default_list_v1
Script not found (scripts/vscripts/dummy_script_tob_load.nut) 
[VSCRIPT LOADER] Couldn't load file dummy_script_tob_load.nut (Order in list: 1)
	Error: Failed to include script "dummy_script_tob_load"
>>> Loaded addon script l4d2-like_muzzleflashes.nut (Order in list: 2)
>>> Loaded addon script gift_grab_achievement.nut (Order in list: 3)
>>> Loaded addon script dissolver-bullet_tracer.nut (Order in list: 4)
[MultiJump Vscript] Initializing script...
>>> Loaded addon script multijump.nut (Order in list: 5)
Running my custom script in g_MapScript 1.005
>>> Loaded addon script dummy_temp.nut (Order in list: 6)
[VSCRIPT LOADER] Done. 5/6 scripts loaded.
THE GIFT GRAB EVENT IS INACTIVE. ACTIVATING...

[VSCRIPT LOADER] Loading round-only scripts...
>>> Loaded addon script l4d2-like_muzzleflashes.nut (Order in list: 2)
Running my custom script in g_MapScript 1.005
>>> Loaded addon script dummy_temp.nut (Order in list: 6)
[VSCRIPT LOADER] Done. 2/2 round-only scripts loaded.
*/
```

## Notes
- If you have another mapspawn.nut file, to avoid conflicts, copy/paste the contents to that file from the mapspawn of this repository
- "round-only" scripts are loaded in g_MapScript scope. Use g_MapScript.<your_variable>
- You can set the limit of maximum loads in the list file.
- The list file is ONLY read once per map load.

## TODO list
- Waiting for feedback
