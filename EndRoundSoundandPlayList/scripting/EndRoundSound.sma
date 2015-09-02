#include <amxmisc>

#if AMXX_VERSION_NUM < 183
    #include <colorchat>
#endif

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN "End Round Sound and PlayList"
#define VERSION "1.0"
#define DATE "06.07.2015"
#define URL "http://eriurias.ru"
#define AUTHOR "Eriurias"

#define ArrayCharsmax(%1) ArraySize(%1) - 1

#define MAX_ARRAYSIZE 128
#define MAX_STRSIZE 64
#define MAX_PLAYERS 32

#define NAME_PLAYLIST "playlist.ini"
#define NAME_DICTIONARY "playlist.txt"
#define NAME_PREFIX "[ERS]\3"

enum Type
{
    NEW_SOUND = 0,
    OLD_SOUND
};

new Array: tPlayList, g_nCvarType, g_nCvarShowNull, iArraySize;
new bool:gPlayerValue[MAX_PLAYERS + 1] = {true, ...};

public plugin_precache()
{
    tPlayList = ArrayCreate(MAX_ARRAYSIZE);
    
    new szCfgDir[MAX_STRSIZE], iFile;
    get_configsdir(szCfgDir, charsmax(szCfgDir));
    
    formatex(szCfgDir, charsmax(szCfgDir), "%s/%s", szCfgDir, NAME_PLAYLIST);
    
    iFile = fopen(szCfgDir, "rt");
    
    if (!iFile)
    {
        log_to_error("File (%s) not exists! Plugin stopped!", NAME_PLAYLIST);
        pause("d");
    }
    
    new szBuffer[MAX_ARRAYSIZE], szSound[MAX_STRSIZE];
    
    while (!feof(iFile))
    {
        fgets(iFile, szBuffer, charsmax(szBuffer));
        
        trim(szBuffer);
        
        if(szBuffer[0] == ';' || szBuffer[0] == '\0')
            continue;
        
        parse(szBuffer, szSound, charsmax(szSound));
        
        if (contain(szSound, ".mp3") != -1)
            precache_generic(szSound);
        else if (contain(szSound, ".wav") != -1)
            precache_sound(szSound);
        
        ArrayPushString(tPlayList, szBuffer);
    }
    
    if ((iArraySize = ArrayCharsmax(tPlayList)) == -1)
    {
        log_to_error("An empty playlist. Plugin stopped!");
        pause("d");
    }
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR/*, DATE, URL*/);
    
    register_logevent("fwdEndRound", 2, "1=Round_End");
    
    register_clcmd("say /music", "MusicSwitch");
    
    g_nCvarType = register_cvar("ers_sound_mode", "0");
    g_nCvarShowNull = register_cvar("ers_show_info_null", "1");
    
    register_dictionary(NAME_DICTIONARY);
}

public plugin_cfg()
{
    g_nCvarType = get_pcvar_num(g_nCvarType);
    g_nCvarShowNull = get_pcvar_num(g_nCvarShowNull);
}

public MusicSwitch(Player)
    gPlayerValue[Player] = !gPlayerValue[Player],
    client_print_color(Player, print_team_default, "%s %L", NAME_PREFIX, Player, gPlayerValue[Player] ? "PLAY_SWITCH_ON" : "PLAY_SWITCH_OFF");

public fwdEndRound()
{
    static szBuffer[MAX_ARRAYSIZE], szSound[MAX_STRSIZE], szDescription[MAX_STRSIZE], 
    iRandomSound[Type], gPlayers[MAX_PLAYERS], iNum, i, Player;
    
    get_players(gPlayers, iNum, "ch");

    if (!iNum)
        return;

    if (g_nCvarType)
    {
        while (iRandomSound[NEW_SOUND] == iRandomSound[OLD_SOUND])
            iRandomSound[NEW_SOUND] = random(iArraySize);

        iRandomSound[OLD_SOUND] = iRandomSound[NEW_SOUND];
        
        ArrayGetString(tPlayList, iRandomSound[NEW_SOUND], szBuffer, charsmax(szBuffer));
        parse(szBuffer, szSound, charsmax(szSound), szDescription, charsmax(szDescription));
        
        for (i = 0; i < iNum; i++)
        {
            Player = gPlayers[i];
            
            if (!gPlayerValue[Player]) continue;
            
            if (contain(szSound, ".mp3") != -1)
                client_cmd(Player, "MP3Volume 5;mp3 play %s", szSound);
            else if (contain(szSound, ".wav") != -1)
                client_cmd(Player, "volume 5;spk %s", szSound);
        
            if (szDescription[0] != '\0')
                client_print_color(Player, print_team_default, "%s %L \1%s", NAME_PREFIX, Player, "PLAY_INFO", szDescription);
            else if ((szDescription[0] == '\0') && g_nCvarShowNull)                
                client_print_color(Player, print_team_default, "%s %L \1%L", NAME_PREFIX, Player, "PLAY_INFO", LANG_PLAYER, "PLAY_INFO_NULL");
        }
    }
    else
    {
        static iSound;
        
        ArrayGetString(tPlayList, iSound, szBuffer, charsmax(szBuffer));
        parse(szBuffer, szSound, charsmax(szSound), szDescription, charsmax(szDescription));
        
        for (i = 0; i < iNum; i++)
        {
            Player = gPlayers[i];
            
            if (!gPlayerValue[Player]) continue;
            
            if (contain(szSound, ".mp3") != -1)
                client_cmd(Player, "MP3Volume 5;mp3 play %s", szSound);
            else if (contain(szSound, ".wav") != -1)
                client_cmd(Player, "volume 5;spk %s", szSound);
        
            if (szDescription[0] != '\0')
                client_print_color(Player, print_team_default, "%s %L \1%s", NAME_PREFIX, Player, "PLAY_INFO", szDescription);
            else if ((szDescription[0] == '\0') && g_nCvarShowNull)
                client_print_color(Player, print_team_default, "%s %L \1%L", NAME_PREFIX, Player, "PLAY_INFO", Player, "PLAY_INFO_NULL");
        }
        
        if (iSound == iArraySize)
            iSound = 0;
        else
            iSound++;
    }
    
    if (szDescription[0] != '\0')
        szDescription[0] = '\0';
}

stock log_to_error(const szMessage[], ...)
{
    new szLog[192], szDate[32];
    vformat(szLog, charsmax(szLog), szMessage, 2);
    get_time("error_%Y%m%d.log", szDate, charsmax(szDate));

    log_to_file(szDate, "[%s] Displaying debug trace (plugin \"%s\", version \"%s\")", PLUGIN, PLUGIN, VERSION);
    log_to_file(szDate, "[%s] %s", PLUGIN, szLog);
}