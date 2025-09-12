# Vscript Loader
A simple loader for vscript files for those game which doesn't have the l4d2's addon script loader system (aka mapspawn_addon, director_base_addon, scriptedmode_addon).

Runs only at map spawn and loads a list of vscripts with error handling. Includes a table for scoped scripts.

# Index
- [Installation](#installation)
- [Files](#files)
- [Global variables](#global-variables)
- [Vscript file list](#vscript-list-file)
- [Notes](#notes)
- [TODO list](#todo-list)

## Installation
1. Download the folder and move it to either the following paths:
- <game_folder>/scripts/vscripts (Only if you want to add the vscript files from the folder itself)
- <game_folder>/custom

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

// Scoped scripts will be referenced here if 'scope' is not null.
// Example: g_VscriptScopedScripts["my_script_file"] will reference its scope
g_VscriptScopedScripts <- {};
```

## Vscript List File
In the list file:
```squirrel
// OPTIONAL: The ID for the list. Can be any value. 
// Use it when you want to detect any overrides from custom or vscript folder.
g_VscriptListId <- "my_default_list_v1";

g_iVscriptFileLoadMax <- 256;   // Max files to be loaded. Can be more but for now it's 256 by default. 

// EXAMPLE - IF "dummy_script_tob_load" doesn't exist, the loader will print an error message
// but still loading the next files of the array.
g_VscriptFileList.push({
    path = "dummy_script_tob_load" 
    scope = null    // setting scope to null will load the file in the root scope.
})

// Add your scripts here. Will load in order.
g_VscriptFileList.push({
    path = "l4d2-like_muzzleflashes"
    scope = null
})
g_VscriptFileList.push({
    path = "gift_grab_achievement"
    scope = null
})
g_VscriptFileList.push({
    path = "dissolver-bullet_tracer"
    // scope = null  // The 'scope' key isn't necessary if you intend to load in the root scope.
})
g_VscriptFileList.push({
    path = "multijump"
    scope = null
})

/*
The console may print something like this:
[VSCRIPT LOADER] Running vscript list file from "vscript_loader_list_all.nut"
[VSCRIPT LOADER] Active list ID: my_default_list_v1
Script not found (scripts/vscripts/dummy_script_tob_load.nut) 
[VSCRIPT LOADER] Couldn't load file <dummy_script_tob_load.nut> (Order: 1)
	Error: Failed to include script "dummy_script_tob_load"
[VSCRIPT LOADER] Loaded file! <l4d2-like_muzzleflashes.nut> (Order: 2)
[VSCRIPT LOADER] Loaded file! <gift_grab_achievement.nut> (Order: 3)
[VSCRIPT LOADER] Loaded file! <dissolver-bullet_tracer.nut> (Order: 4)
[MultiJump Vscript] Initializing script...
[VSCRIPT LOADER] Loaded file! <multijump.nut> (Order: 5)
*/
```

## Notes
- The loader runs ONLY once per map load. Any errors or file missing will ignore the file.
- You can set the limit of maximum loads in the list file.

## TODO list
- Add a temporal scope which resets every round as g_MapScript. (There's no a convenient cleanup event for css/dod/hl2dm) 
