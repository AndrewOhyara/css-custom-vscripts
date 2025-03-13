// NOTE: Include this on your "mapspawn.nut" file before blaming.
if ("GiftGrabAchievement" in this)
    GiftGrabAchievement.clear();

::GiftGrabAchievement <- 
{
    IsGiftGrabEventActive = function()
    {   // Returns true if the gift grab event is active.
        return NetProps.GetPropBool(Entities.FindByClassname(null, "cs_gamerules"), "m_bWinterHolidayActive");
    }

    SetForceGiftGrabEvent = function(bool)
    {
        NetProps.SetPropBool(Entities.FindByClassname(null, "cs_gamerules"), "m_bWinterHolidayActive", bool);
    }

    OnGameEvent_round_freeze_end = function(params)
    {
        if (!GiftGrabAchievement.IsGiftGrabEventActive())
        {
            printl("THE GIFT GRAB EVENT IS INACTIVE. ACTIVATING...")
            ClientPrint(null, 3, "\x07FF3F3F" + "THE GIFT GRAB EVENT IS INACTIVE. ACTIVATING...");
            GiftGrabAchievement.SetForceGiftGrabEvent(true);
        }

        if (GiftGrabAchievement.IsGiftGrabEventActive())
            ClientPrint(null, 3, "\x05" + "THE GIFT GRAB EVENT IS ACTIVE");
    }
}
__CollectGameEventCallbacks(GiftGrabAchievement);
