#define TEAMNAME_MAXCHAR 9

RegisterNatives()
{
    register_native("hns_switch_teams", "SwitchTeams", true);
    register_native("hns_get_gamestarted", "GetGameStarted", true);
    register_native("hns_get_aliveplayers", "GetAlivePlayers");
}

public SwitchTeams()
{
    static gPlayers[32], iNum, i, nClientIndex;
    get_players(gPlayers, iNum);
    
    if (!iNum) return false;
    
    for (i = 0; i < iNum; i++)
    {
        nClientIndex = gPlayers[i];
        
        if (cs_get_user_team(nClientIndex) == CS_TEAM_CT)
            cs_set_user_team(nClientIndex, CS_TEAM_T),
            ExecuteForward(g_fwBecameTerror, g_Result, nClientIndex);
        else if (cs_get_user_team(nClientIndex) == CS_TEAM_T)
            cs_set_user_team(nClientIndex, CS_TEAM_CT);
    }
    
    return true;
}

public GetAlivePlayers()
{
    static szArg[TEAMNAME_MAXCHAR];
    get_array(1, szArg, charsmax(szArg));
    
    if (equal(szArg, "CT"))
        return g_iAliveCount[CS_TEAM_CT];
    else if (equal(szArg, "TERRORIST"))
        return g_iAliveCount[CS_TEAM_T];
    
    return false;
}