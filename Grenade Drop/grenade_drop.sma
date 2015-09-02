#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta_util>
 
#pragma semicolon 1

#define OFFSET_ACTIVE_ITEM 373
#define OFFSET_LINUX 5

#define PLUGIN "Grenade Drop"
#define VERSION "1.2"
#define DATE "20.07.2015"
#define URL "http://eriurias.ru"
#define AUTHOR "Eriurias & PRoSToTeM@"

enum
{
    HEGRENADE,
    FLASHBANG,
    SMOKEGRENADE
};

new const szItemList[][] =
{
    "weapon_hegrenade",
    "weapon_flashbang",
    "weapon_smokegrenade"
};

new g_nRestoreFlashbangCount;
new bool:g_fIsFlashbangActive;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR/*, DATE, URL*/);
   
    for (new i; i < sizeof(szItemList); i++)
        RegisterHam(Ham_CS_Item_CanDrop, szItemList[i], "fwHamItemCanDrop_Pre");
    
    register_clcmd("drop", "ClCmdDrop");
    register_forward(FM_ClientCommand, "ClientCommand_PostHook", true);
    
    register_message(get_user_msgid("WeapPickup"), "msgWeaponPickup");
    register_message(get_user_msgid("AmmoPickup"), "msgWeaponPickup");
}

public fwHamItemCanDrop_Pre(iWeapon)
{    
    SetHamReturnInteger(true);
       
    return HAM_SUPERCEDE;
}

public ClCmdDrop(nClientIndex)
{    
    g_nRestoreFlashbangCount = cs_get_user_bpammo(nClientIndex, CSW_FLASHBANG);
    cs_set_user_bpammo(nClientIndex, CSW_FLASHBANG, -g_nRestoreFlashbangCount);
    
    static pActiveItem; pActiveItem = get_pdata_cbase(nClientIndex, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
    if (pActiveItem > 0)
        g_fIsFlashbangActive = cs_get_weapon_id(pActiveItem) == CSW_FLASHBANG;
}

public ClientCommand_PostHook(nClientIndex)
{
    if (g_nRestoreFlashbangCount)
    {
        if (cs_get_user_bpammo(nClientIndex, CSW_FLASHBANG) == -1)
            cs_set_user_bpammo(nClientIndex, CSW_FLASHBANG, 1);
        else if (cs_get_user_bpammo(nClientIndex, CSW_FLASHBANG) == -2)
            cs_set_user_bpammo(nClientIndex, CSW_FLASHBANG, 2);
        else if (g_nRestoreFlashbangCount == 2)
        {
            fm_give_item(nClientIndex, szItemList[FLASHBANG]);
            
            if (g_fIsFlashbangActive)
                engclient_cmd(nClientIndex, szItemList[FLASHBANG]);
        }
        
        g_nRestoreFlashbangCount = 0;
    }
    
    g_fIsFlashbangActive = false;
}

public msgWeaponPickup(pMsgId, pMsgDest, pMsgReceiver)
{
    if (g_nRestoreFlashbangCount) 
        return PLUGIN_HANDLED;
    
    return PLUGIN_CONTINUE;
}