enum HnsTeams
{
    HNS_DRAW,
    HNS_TEAM_T,
    HNS_TEAM_CT
};

new g_fwRoundEnd, g_fwTaskProcess, 
g_fwRoundStart, g_fwBecameTerror,
g_fwTeamLoner, g_Result, 
g_iSecond, g_iRoundEnd;

Events_Init()
{
    register_event("SendAudio", "EventCTWin", "a", "2&%!MRAD_ctwin");
    register_event("SendAudio", "EventTWin", "a", "2&%!MRAD_terwin");
    register_event("SendAudio", "EventDraw", "a", "2&%!MRAD_rounddraw");
    
    register_event("HLTV", "EvenNewRound", "a", "1=0", "2=0");
    
    g_fwRoundStart = CreateMultiForward("hns_round_start", ET_CONTINUE, FP_CELL);
    g_fwRoundEnd = CreateMultiForward("hns_round_end", ET_CONTINUE, FP_CELL, FP_CELL);
    g_fwBecameTerror = CreateMultiForward("hns_became_terrorist", ET_CONTINUE, FP_CELL);
    g_fwTaskProcess = CreateMultiForward("hns_timer_process", ET_CONTINUE, FP_CELL, FP_CELL);
    g_fwTeamLoner = CreateMultiForward("hns_player_loner", ET_CONTINUE, FP_CELL, FP_CELL);
}

public EventCTWin() if (!g_iRoundEnd) g_iRoundEnd = true, remove_task(), ExecuteForward(g_fwRoundEnd, g_Result, HNS_TEAM_CT, GetGameStarted());
public EventTWin() if (!g_iRoundEnd) g_iRoundEnd = true, remove_task(), ExecuteForward(g_fwRoundEnd, g_Result, HNS_TEAM_T, GetGameStarted());
public EventDraw() if (!g_iRoundEnd) g_iRoundEnd = true, remove_task(), ExecuteForward(g_fwRoundEnd, g_Result, HNS_DRAW, GetGameStarted());

public EvenNewRound()
{
    g_iRoundEnd = false;
    
    g_iSecond = g_pDate[TIMER_SECONDS] + EXTRATIME;
    
    remove_task();
    set_task(TASK_INTERVAL, "TimerStart", .flags = "b");
}

public TimerStart()
{
    if (g_iSecond > EXTRATIME)
    {
        static gPlayers[MAX_PLAYERS], iNum;
        get_players(gPlayers, iNum);
        
        if (iNum < MIN_PLAYERS)
        {
            remove_task();
            ExecuteForward(g_fwRoundStart, g_Result, false);
            return;
        }
        
        for (new i, nClientIndex; i < iNum; i++)
        {
            nClientIndex = gPlayers[i];
            
            ExecuteForward(g_fwTaskProcess, g_Result, nClientIndex, g_iSecond - EXTRATIME);
        }
    }
    
    g_iSecond--;
    
    if (!g_iSecond)
    {
        remove_task();
        ExecuteForward(g_fwRoundStart, g_Result, true);
    }
}

public bool: GetGameStarted()
{
    static gPlayers[MAX_PLAYERS], iNum;
    get_players(gPlayers, iNum, "CT");
    
    if (iNum)
    {
        get_players(gPlayers, iNum, "TERRORIST");
        
        return iNum ? true : false;
    }
    
    return false;
}