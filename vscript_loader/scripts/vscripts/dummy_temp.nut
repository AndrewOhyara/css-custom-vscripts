printl("Running my custom script in g_MapScript " + Time());
my_custom <- {
    QUALITY = 0
    OnGameEvent_round_start = function(params)
    {
        QUALITY++;
        printl("HELLO, USER!")
        ClientPrint(null, 3, "HELLO, USER!  SERVER TIME: " + Time());
    }
}
__CollectGameEventCallbacks(my_custom);


