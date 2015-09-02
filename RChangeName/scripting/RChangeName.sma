#include <amxmodx>
#include <fakemeta>

#if AMXX_VERSION_NUM < 183
    #include <colorchat>
#endif
 
#pragma semicolon 1
#pragma ctrlchar '\'
 
#define PLUGIN "Restriction on Change Name"
#define VERSION "2.0"
#define DATE "3.07.2015"
#define URL "http://eriurias.ru"
#define AUTHOR "Eriurias"

new const szDictionary[] = "rcn_lang.txt";

#define MINUTE 60
#define MAX_NAMESIZE 32
#define MAX_PLAYERS 32
 
new Float: fUserTime[MAX_PLAYERS + 1], iCvarTime;
 
public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_forward(FM_ClientUserInfoChanged, "UserInfoChanged");
    
    iCvarTime = register_cvar("rcn_change_time", "60");
    
    register_dictionary_colored(szDictionary);
}

public plugin_cfg() iCvarTime = get_pcvar_num( iCvarTime );

public client_putinserver(nClientIndex) fUserTime[nClientIndex] = 0.0;

public UserInfoChanged(nClientIndex, Buffer)
{
    static szUserName[MAX_NAMESIZE]; pev(nClientIndex, pev_netname, szUserName, charsmax(szUserName));
    
    if (!szUserName[0])
        return FMRES_IGNORED;
    
    static szUserInfo[MAX_NAMESIZE]; engfunc(EngFunc_InfoKeyValue, Buffer, "name", szUserInfo, charsmax(szUserInfo));
    
    if (equal(szUserInfo, szUserName))
        return FMRES_IGNORED;
    
    static Float: fCurrentTime; fCurrentTime = get_gametime();
    
    if (fCurrentTime < fUserTime[nClientIndex])
    {
        engfunc(EngFunc_SetClientKeyValue, nClientIndex, Buffer, "name", szUserName);
        
        if (iCvarTime > MINUTE)
            client_print_color(nClientIndex, print_team_default, "\4[RCN]\1 %L", nClientIndex, "MINUTES_AND_SECONDS", floatround(fUserTime[nClientIndex] - fCurrentTime) / MINUTE, floatround(fUserTime[nClientIndex] - fCurrentTime) % MINUTE);
        else
            client_print_color(nClientIndex, print_team_default, "\4[RCN]\1 %L", nClientIndex, "SECONDS", floatround(fUserTime[nClientIndex] - fCurrentTime));
        
        return FMRES_IGNORED;
    }

    fUserTime[nClientIndex] = fCurrentTime + float(iCvarTime);
    
    return FMRES_IGNORED;
}
