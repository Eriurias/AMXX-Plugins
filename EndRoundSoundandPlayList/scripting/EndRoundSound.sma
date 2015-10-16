#include <amxmisc>

#if AMXX_VERSION_NUM < 183
    #include <colorchat>
#endif

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN "End Round Sound and PlayList"
#define VERSION "2.1"
#define DATE "16.10.2015"
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
    NEW_SOUND,
    OLD_SOUND
};

enum Cvar_Type
{
    PLAYBACK_MODE,
    VISIBLE_INFO_NULL,
    PLAYBACK_CONNECT,
    CHANGE_VOLUME
};

new Array: g_aPlayList, g_nArraySize;
new bool: g_bPlayerPlayback[MAX_PLAYERS + 1] = {true, ...};
new g_nCvarData[Cvar_Type];

public plugin_precache()
{
    g_aPlayList = ArrayCreate(MAX_ARRAYSIZE);
    
    new szCfgDir[MAX_STRSIZE], nFile;
    get_configsdir(szCfgDir, charsmax(szCfgDir));
    
    formatex(szCfgDir, charsmax(szCfgDir), "%s/%s", szCfgDir, NAME_PLAYLIST);
    
    nFile = fopen(szCfgDir, "rt");
    
    if (!nFile)
    {
        log_to_error("File (%s) not exists! Plugin stopped!", NAME_PLAYLIST);
        pause("d");
    }
    
    new szBuffer[MAX_ARRAYSIZE], szSound[MAX_STRSIZE];
    
    while (!feof(nFile))
    {
        fgets(nFile, szBuffer, charsmax(szBuffer));
        
        trim(szBuffer);
        
        if(szBuffer[0] == ';' || szBuffer[0] == '\0')
            continue;
        
        parse(szBuffer, szSound, charsmax(szSound));
        
        if (contain(szSound, ".mp3") != -1)
            precache_generic(szSound);
        else if (contain(szSound, ".wav") != -1)
            precache_sound(szSound);
        
        ArrayPushString(g_aPlayList, szBuffer);
    }
    
    if ((g_nArraySize = ArrayCharsmax(g_aPlayList)) == -1)
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
    
    g_nCvarData[PLAYBACK_MODE] = register_cvar("ers_sound_mode", "0");
    g_nCvarData[VISIBLE_INFO_NULL] = register_cvar("ers_show_info_null", "1");
    g_nCvarData[PLAYBACK_CONNECT] = register_cvar("ers_playback_connect", "1");
    g_nCvarData[CHANGE_VOLUME] = register_cvar("ers_change_volume", "1");
    
    register_dictionary(NAME_DICTIONARY);
}

public plugin_cfg()
{
    g_nCvarData[PLAYBACK_MODE] = get_pcvar_num(g_nCvarData[PLAYBACK_MODE]);
    g_nCvarData[VISIBLE_INFO_NULL] = get_pcvar_num(g_nCvarData[VISIBLE_INFO_NULL]);
    g_nCvarData[PLAYBACK_CONNECT] = get_pcvar_num(g_nCvarData[PLAYBACK_CONNECT]);
    g_nCvarData[CHANGE_VOLUME] = get_pcvar_num(g_nCvarData[CHANGE_VOLUME]);
}

public MusicSwitch(nClientIndex)
    g_bPlayerPlayback[nClientIndex] = !g_bPlayerPlayback[nClientIndex],
    client_print_color(nClientIndex, print_team_default, "%s %L", NAME_PREFIX, nClientIndex, g_bPlayerPlayback[nClientIndex] ? "PLAY_SWITCH_ON" : "PLAY_SWITCH_OFF");

public client_connect(nClientIndex)
{
    if (g_nCvarData[PLAYBACK_CONNECT])
    {
        static szSound[MAX_STRSIZE];
        
        get_track(szSound, _, true);
        
        if (contain(szSound, ".mp3") != -1)
            client_cmd(nClientIndex, "%s mp3 play %s", g_nCvarData[CHANGE_VOLUME] ? "MP3Volume 1;" : "", szSound);
        else if (contain(szSound, ".wav") != -1)
            client_cmd(nClientIndex, "%s spk %s", g_nCvarData[CHANGE_VOLUME] ? "volume 1;" : "", szSound);
    }
}

public fwdEndRound()
{
    static szSound[MAX_STRSIZE], szDescription[MAX_STRSIZE], 
    gPlayers[MAX_PLAYERS], iNum, i, nClientIndex;
    
    get_players(gPlayers, iNum, "ch");

    if (!iNum)
        return;

    get_track(szSound, szDescription);
        
    for (i = 0; i < iNum; i++)
    {
        nClientIndex = gPlayers[i];
            
        if (!g_bPlayerPlayback[nClientIndex])
            continue;
            
        if (contain(szSound, ".mp3") != -1)
            client_cmd(nClientIndex, "%s mp3 play %s", g_nCvarData[CHANGE_VOLUME] ? "MP3Volume 1;" : "", szSound);
        else if (contain(szSound, ".wav") != -1)
            client_cmd(nClientIndex, "%s spk %s", g_nCvarData[CHANGE_VOLUME] ? "volume 1;" : "", szSound);
        
        if (szDescription[0] != '\0')
            client_print_color(nClientIndex, print_team_default, "%s %L \1%s", NAME_PREFIX, nClientIndex, "PLAY_INFO", szDescription);
        else if (szDescription[0] == '\0' && g_nCvarData[VISIBLE_INFO_NULL])                
            client_print_color(nClientIndex, print_team_default, "%s %L \1%L", NAME_PREFIX, nClientIndex, "PLAY_INFO", LANG_PLAYER, "PLAY_INFO_NULL");
    }
    
    if (szDescription[0] != '\0')
        szDescription[0] = '\0';
}

stock get_track(szSound[MAX_STRSIZE], szDescription[MAX_STRSIZE] = "", bool: bConnect = false)
{
    static szBuffer[MAX_ARRAYSIZE], nRandomSound[Type];
    
    if (g_nCvarData[PLAYBACK_MODE])
    {
        while (nRandomSound[NEW_SOUND] == nRandomSound[OLD_SOUND])
            nRandomSound[NEW_SOUND] = random(g_nArraySize);

        nRandomSound[OLD_SOUND] = nRandomSound[NEW_SOUND];
        
        ArrayGetString(g_aPlayList, nRandomSound[NEW_SOUND], szBuffer, charsmax(szBuffer));
        parse(szBuffer, szSound, charsmax(szSound), szDescription, charsmax(szDescription));
    }
    else
    {
        static nSoundRound, nSoundConnect;
        
        ArrayGetString(g_aPlayList, bConnect ? nSoundConnect : nSoundRound, szBuffer, charsmax(szBuffer));
        parse(szBuffer, szSound, charsmax(szSound), szDescription, charsmax(szDescription));
        
        if (bConnect)
        {
            if (nSoundConnect == g_nArraySize)
                nSoundConnect = 0;
            else
                nSoundConnect++;
        }
        else
        {
            if (nSoundRound == g_nArraySize)
                nSoundRound = 0;
            else
                nSoundRound++;
        }
    }
}

stock log_to_error(const szMessage[], ...)
{
    new szLog[192], szDate[32];
    vformat(szLog, charsmax(szLog), szMessage, 2);
    get_time("error_%Y%m%d.log", szDate, charsmax(szDate));

    log_to_file(szDate, "[%s] Displaying debug trace (plugin \"%s\", version \"%s\")", PLUGIN, PLUGIN, VERSION);
    log_to_file(szDate, "[%s] %s", PLUGIN, szLog);
}
