// EVENTS

::Hook.Add("player_spawn", "GetSteamID3Early",  function(params) {
    // Source: https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Fetching_player_name_or_Steam_ID
    local player = GetPlayerFromUserID(params.userid)
    if (player.GetTeam() == 0)
        SendGlobalGameEvent("player_activate", {
            userid = params.userid
        });
    // I think if you want to hook player_activate (let's say a welcome message), you should add a counter per userid to avoid a double call.
});