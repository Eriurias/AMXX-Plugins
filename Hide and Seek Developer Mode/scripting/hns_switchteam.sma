#include <amxmodx>
#include <dhudmessage>
#include <hns_engine/hns_engine>

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN "Hide and Seek: Switch Teams"
#define VERSION "1.0"
#define AUTHOR "Eriurias"

public plugin_init() register_plugin(PLUGIN, VERSION, AUTHOR);

public hns_round_end(HnsTeams:hTeam, bool: bGameStarted)
{
    set_dhudmessage(155, 0, 0, -1.0, -1.0, 0, 6.0, 4.0);
    
    switch (hTeam)
    {
        case HNS_TEAM_CT:
        {
            hns_switch_teams();
            
            show_dhudmessage(0, "Победа за охотниками!\nСмена команд..");
        }
    
        case HNS_TEAM_T: show_dhudmessage(0, "Победа за прячущимися!\nНет смены команд.");
        
        default: show_dhudmessage(0, "Ничья!\nНет смены команд.");
    }
}