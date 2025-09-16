printl("Running my custom script in g_MapScript scope " + Time());
MycustomTab <- {
    custom_value = 0 // If this is a round-only script, this value should never be more than 1 every new round.
    OnGameEvent_round_start = function(params)
    {
        custom_value++;
        printl("HELLO, USER! " + custom_value + " | address " + this)
        ClientPrint(null, 3, "HELLO, USER!  SERVER TIME: " + Time() + " | " + custom_value);
    }

    OnGameEvent_dod_round_start = function(params)
    {	// round_start for DOD
        custom_value++;
        printl("HELLO, USER IN DODS! " + custom_value + " | address " + this)
        ClientPrint(null, 3, "HELLO, USER IN DODS! TIME: " + Time() + " | " + custom_value);
    }

    OnGameEvent_teamplay_round_start = function(params)
    {	// round_start for TF2
        custom_value++;
        printl("HELLO, USER IN TF2! " + custom_value + " | address " + this)
        ClientPrint(null, 3, "HELLO, USER IN TF2! TIME: " + Time() + " | " + custom_value);
    }
}
__CollectGameEventCallbacks(MycustomTab);


