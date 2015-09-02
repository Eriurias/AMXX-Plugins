#define NAME_CONFIG "hns_settings.ini"
#define MAX_STRSIZE 96
#define SECTION_ENTITY_LIST 3

enum DATE_TYPES
{
    TIMER_SECONDS,
    SERVER_AA,
    JOIN_TEAM,
    JOIN_CLASS,
    BLOCK_MONEY
}

new g_pDate[DATE_TYPES];
new Trie: g_tEntityList;

new const szTrieValue[] = "Entity";

LoadConfig()
{
    g_tEntityList = TrieCreate();
    
    new szCfgDir[MAX_STRSIZE], iFile, g_iSection;
    get_configsdir(szCfgDir, charsmax(szCfgDir));
    
    formatex(szCfgDir, charsmax(szCfgDir), "%s/%s", szCfgDir, NAME_CONFIG);
    
    iFile = fopen(szCfgDir, "rt");
    
    if (!file_exists(szCfgDir))
    {
        log_to_error("Config file not found! Plugin stopped!");
        pause("d");
    }
    
    new szBuffer[MAX_STRSIZE], szKey[MAX_STRSIZE], szValue[MAX_STRSIZE], szDescription[MAX_STRSIZE];
    
    while (!feof(iFile))
    {
        fgets(iFile, szBuffer, charsmax(szBuffer));
        
        if(szBuffer[0] == ';' || szBuffer[0] == '\0' || szBuffer[0] == '{' || szBuffer[0] == '}')
            continue;
        
        if (szBuffer[0] == '[')
        {
            g_iSection++;
            continue;
        }
    
        if (g_iSection != SECTION_ENTITY_LIST)
        {
            strtok(szBuffer, szKey, charsmax(szKey), szValue, charsmax(szValue), '=');
            
            if (contain(szValue, "//") != -1) strtok(szValue, szValue, charsmax(szValue), szDescription, charsmax(szDescription), '/');

            trim(szKey);
            trim(szValue);
        }            

        switch (g_iSection)
        {
            case 1:
            {
                if (equal(szKey, "HNS_TIMER_SECONDS")) g_pDate[TIMER_SECONDS] = str_to_num(szValue);
                else if (equal(szKey, "HNS_SERVER_AA")) g_pDate[SERVER_AA] = str_to_num(szValue);
                else if (equal(szKey, "HNS_BLOCK_MONEY")) g_pDate[BLOCK_MONEY] = str_to_num(szValue);
            }
            
            case 2:
            {
                if (equal(szKey, "HNS_JOIN_TEAM")) g_pDate[JOIN_TEAM] = str_to_num(szValue);
                else if (equal(szKey, "HNS_JOIN_CLASS")) g_pDate[JOIN_CLASS] = str_to_num(szValue);
            }
            
            case SECTION_ENTITY_LIST: 
            {
                if (contain(szBuffer, "//") != -1) strtok(szBuffer, szBuffer, charsmax(szBuffer), szDescription, charsmax(szDescription), '/');
                
                trim(szBuffer), TrieSetString (g_tEntityList, szBuffer, szTrieValue);
            }
        }
    }
}

SetCvars()
{
    set_cvar_num("sv_airaccelerate", g_pDate[SERVER_AA]);
}

stock log_to_error(const szMessage[], ...)
{
    new szLog[192], szDate[32];
    vformat(szLog, charsmax(szLog), szMessage, 2);
    get_time("error_%Y%m%d.log", szDate, charsmax(szDate));

    log_to_file(szDate, "[%s] Displaying debug trace (plugin \"%s\", version \"%s\")", PLUGIN, PLUGIN, VERSION);
    log_to_file(szDate, "[%s] %s", PLUGIN, szLog);
}