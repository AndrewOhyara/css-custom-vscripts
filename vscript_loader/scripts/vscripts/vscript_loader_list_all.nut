// ========================================================================
// vscript_loader_list_all.nut - Script list for the loader.
// ------------------------------------------------------------------------
// The vscript loader reads this file to know which scripts it will load.
// You can edit this file to add any scripts.
// ========================================================================
Msg("[VSCRIPT LOADER] Loading vscript file list from " + __FILE__ + "\n");

// The ID for the list. Can be any value. Use it when you want to detect any overrides from custom or vscript folder.
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
    path = "multijump"  // If not 'scope', the scope will be set to the root scope.
})

VscriptLoader.AddScript({
    path = "dummy_temp"
    scope = this    // if round_only is true, the scope is ignored and set to g_MapScript
    round_only = true
})
