#include <amxmodx>
#include <fun>
#include <hns_engine/hns_engine>

#define PLUGIN "Hide and Seek: Add Frag"
#define VERSION "1.0"
#define AUTHOR "Eriurias"

public plugin_init() register_plugin(PLUGIN, VERSION, AUTHOR);

public hns_round_end(HnsTeams:hTeam, bool: bGameStarted)
{
    if (hTeam == HNS_TEAM_T && bGameStarted)
    {
        static gPlayers[32], iNum, i, Player;
        get_players(gPlayers, iNum, "ae", "TERRORIST");
 
        for (i = 0; i < iNum; i++)
        {
            Player = gPlayers[i];
 
            set_user_frags(Player, get_user_frags(Player) + 1);
        }
    }
}