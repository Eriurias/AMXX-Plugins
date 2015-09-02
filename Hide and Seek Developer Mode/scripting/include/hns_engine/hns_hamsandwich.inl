new HamHook:gHamPreThink, 
g_iAliveCount[CsTeams];

HamSandwich_Init()
{
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwdHamWeaponPrimaryAttack_Pre", .Post = false);
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwdHamWeaponSecondaryAttack_Pre", .Post = false);
    RegisterHam(Ham_Spawn, "player", "fwdPlayerSpawn_Post", .Post = true);
    RegisterHam(Ham_Killed, "player", "fwdPlayerKilled_Pre", .Post = false);
    
    register_event("HLTV", "EventNewRound_Hamsandwich", "a", "1=0", "2=0");
    
    DisableHamForward(gHamPreThink = RegisterHam(Ham_Player_PreThink, "player", "fwdPlayerPreThink_Post", .Post = true));
}

public fwdHamWeaponPrimaryAttack_Pre(pWeaponEntity)
{
    static nClientIndex; nClientIndex = get_pdata_cbase(pWeaponEntity, m_pPlayer, OFFSET_LINUX);
    
    if (is_user_alive(nClientIndex) && cs_get_user_team(nClientIndex) == CS_TEAM_CT)
        ExecuteHam(Ham_Weapon_SecondaryAttack, pWeaponEntity);
    
    return HAM_SUPERCEDE;
}

public fwdHamWeaponSecondaryAttack_Pre(pWeaponEntity)
{
    static nClientIndex; nClientIndex = get_pdata_cbase(pWeaponEntity, m_pPlayer, OFFSET_LINUX);
    
    if (is_user_alive(nClientIndex) && cs_get_user_team(nClientIndex) == CS_TEAM_T)
        return HAM_SUPERCEDE;
    
    return HAM_IGNORED;
}

public fwdPlayerSpawn_Post(nClientIndex)
{
    if (is_user_alive(nClientIndex))
    {        
        fm_strip_user_weapons(nClientIndex), fm_give_item(nClientIndex, "weapon_knife");
        
        g_iAliveCount[cs_get_user_team(nClientIndex)]++;
    }
}

public fwdPlayerKilled_Pre(nClientIndex)
{
    static gPlayers[32], iNum, i;
    g_iAliveCount[cs_get_user_team(nClientIndex)]--;
    
    if (g_iAliveCount[CS_TEAM_CT] == IS_LONER_COUNT)
    {
        get_players(gPlayers, iNum, "ae", "CT");
        
        if (GetGameStarted())
            for (i = 0; i < iNum; i++)
                nClientIndex = gPlayers[i], ExecuteForward(g_fwTeamLoner, g_Result, nClientIndex, HNS_TEAM_CT);
    }

    if (g_iAliveCount[CS_TEAM_T] == IS_LONER_COUNT)
    {
        get_players(gPlayers, iNum, "ae", "TERRORIST");
        
        if (GetGameStarted())
            for (i = 0; i < iNum; i++)
                nClientIndex = gPlayers[i], ExecuteForward(g_fwTeamLoner, g_Result, nClientIndex, HNS_TEAM_T);
    }
}

public EventNewRound_Hamsandwich()
{
    g_iAliveCount[CS_TEAM_T] = 0;
    g_iAliveCount[CS_TEAM_CT] = 0;
}

public fwdPlayerPreThink_Post(nClientIndex)
{
    DisableHamForward(gHamPreThink);

    static iOldShowMenuBlock;iOldShowMenuBlock = get_msg_block(MsgId_ShowMenu);
    static iOldVGUIMenuBlock;iOldShowMenuBlock = get_msg_block(MsgId_VGUIMenu);
    static sz_CvarJoinTeam[9]; if (sz_CvarJoinTeam[0] == '\0') num_to_str(g_pDate[JOIN_TEAM], sz_CvarJoinTeam, charsmax(sz_CvarJoinTeam));
    static sz_CvarJoinClass[9]; if (sz_CvarJoinClass[0] == '\0') num_to_str(g_pDate[JOIN_CLASS], sz_CvarJoinClass, charsmax(sz_CvarJoinClass));
    
    set_msg_block(MsgId_ShowMenu, BLOCK_SET);
    set_msg_block(MsgId_VGUIMenu, BLOCK_SET);
    engclient_cmd(nClientIndex, "jointeam", sz_CvarJoinTeam);
    engclient_cmd(nClientIndex, "joinclass", sz_CvarJoinClass);
    set_msg_block(MsgId_VGUIMenu, iOldVGUIMenuBlock);
    set_msg_block(MsgId_ShowMenu, iOldShowMenuBlock);
}