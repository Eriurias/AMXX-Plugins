Messages_Init()
{
    if (g_pDate[BLOCK_MONEY])
        register_message(MsgId_Money, "BlockMessage");
    
    register_message(MsgId_ScreenFade, "MessageScreenFade");
    register_message(MsgId_TextMsg, "MessageTextMsg");
    register_message(MsgId_ShowMenu, "MessageMenu");
    register_message(MsgId_VGUIMenu, "MessageMenu");
    
    register_clcmd("chooseteam", "BlockMessage");
    register_clcmd("jointeam", "BlockMessage");
}

public BlockMessage()
    return PLUGIN_HANDLED;

public MessageScreenFade(pMsgId, pMsgDest, pMsgReceiver)
{
    if( get_msg_arg_int(4) == MSG_ARG_R && get_msg_arg_int(5) == MSG_ARG_G && get_msg_arg_int(6) == MSG_ARG_B )
        if (cs_get_user_team(pMsgReceiver) == CS_TEAM_T)
            return PLUGIN_HANDLED;

    return PLUGIN_CONTINUE;
}

public MessageTextMsg()
{
    static szTextMessage[96];
    get_msg_arg_string(2, szTextMessage, charsmax(szTextMessage));
    
    if(equal(szTextMessage, "#Hostages_Not_Rescued") || 
    equal(szTextMessage, "#Round_Draw") || 
    equal(szTextMessage, "#Terrorists_Win") || 
    equal(szTextMessage, "#CTs_Win"))
        return PLUGIN_HANDLED;
    
    return PLUGIN_CONTINUE;
}

public MessageMenu(pMsgId, pMsgDest, pMsgReceiver)
{
    if (pMsgId == MsgId_VGUIMenu)
    {
        if (get_msg_arg_int(1) != VGUI_MENU_ID || get_msg_arg_int(2) & MENU_KEY_0)
            return PLUGIN_CONTINUE;
    }
    else
    { 
        static szMessageSelected[] = "#Team_Select"; static szMessageMenu[sizeof( szMessageSelected )];
        get_msg_arg_string(4, szMessageMenu, charsmax( szMessageMenu ));

        if (!equal(szMessageMenu, szMessageSelected))
            return PLUGIN_CONTINUE;
    }
    
    if (get_pdata_int(pMsgReceiver, m_iMenu) == Menu_ChooseTeam || get_pdata_int(pMsgReceiver, m_iJoiningState) != SHOWTEAMSELECT)
        return PLUGIN_CONTINUE;

    EnableHamForward(gHamPreThink);

    return PLUGIN_HANDLED;
}