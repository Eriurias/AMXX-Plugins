#include <amxmodx>
#include <fakemeta_util>
#include <cstrike>
#include <dhudmessage>
#include <hns_engine/hns_engine>

#pragma semicolon 1

#define PLUGIN "Hide and Seek: Start Freez"
#define VERSION "1.0"
#define AUTHOR "Eriurias"

#define MsgId_ScreenFade 98

public plugin_init() register_plugin(PLUGIN, VERSION, AUTHOR);

public hns_timer_process(Player, iTimer)
{
    if (cs_get_user_team(Player) == CS_TEAM_CT)
    {
        ScreenFade(Player, true);
        set_pev(Player, pev_flags, pev(Player, pev_flags) | FL_FROZEN);
    }
    
    set_dhudmessage(155, 0, 0, -1.0, -1.0, 0, 6.0, 1.0);
    ClearDHUDMessages(Player);
    show_dhudmessage(Player, "Начинаем через: %i", iTimer);
    
    static szTime[32]; num_to_word(iTimer, szTime, charsmax(szTime));
    client_cmd(Player, "spk vox/%s.wav", szTime);
}

public hns_round_start(bool:g_MinPlayers)
{
    static gPlayers[32], iNum;
    get_players(gPlayers, iNum);
    
    for (new i, Player; i < iNum; i++)
    {
        Player = gPlayers[i];
        
        if (cs_get_user_team(Player) == CS_TEAM_CT)
        {
            ScreenFade(Player, false);
            set_pev(Player, pev_flags, pev(Player, pev_flags) & ~FL_FROZEN);
        }
        else if (cs_get_user_team(Player) == CS_TEAM_T)
        {
            fm_give_item(Player, "weapon_smokegrenade");
            fm_give_item(Player, "weapon_flashbang");
            fm_give_item(Player, "weapon_flashbang");
        }
    }
    
    if (hns_get_gamestarted())
    {
        ClearDHUDMessages(0);
        
        set_dhudmessage(155, 0, 0, -1.0, -1.0, 0, 6.0, 1.0);
        show_dhudmessage(0, "Погнали!");
    }
}

stock ScreenFade(const Player, const Status)
{
    message_begin(MSG_ONE, MsgId_ScreenFade, _, Player);
    write_short(1<<0);
    write_short(1<<0);
    write_short(Status ? 1<<2 : 1<<0);
    write_byte(0);
    write_byte(0);
    write_byte(0);
    write_byte(Status ? 255 : 0);
    message_end();
}

stock ClearDHUDMessages(pId, iClear = 8)
        for (new iDHUD = 0; iDHUD < iClear; iDHUD++)
                show_dhudmessage(pId, "");