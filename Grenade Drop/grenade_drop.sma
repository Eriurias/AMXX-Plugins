#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
 
#pragma semicolon 1

#define PLUGIN "Grenade Drop"
#define VERSION "2.5"
#define DATE "10.09.2015"
#define URL "http://eriurias.ru"
#define AUTHOR "Eriurias & PRoSToTeM@"

#define IsValidPrivateDate(%1) (pev_valid(%1) == 2)

const m_pActiveItem = 373;
const XO_CBASEPLAYER = 5;

const m_pPlayer = 41;
const XO_CBASEPLAYERWEAPON = 4;

const MsgId_WeapPickup = 92;
const MsgId_AmmoPickup = 91;

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
new bool: g_bIsFlashbangActive;
new g_fwHookClientCommand;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR/*, DATE, URL*/);
   
    for (new i; i < sizeof(szItemList); i++)
        RegisterHam(Ham_CS_Item_CanDrop, szItemList[i], "fwHamItemCanDrop_Pre");
    
    register_message(MsgId_WeapPickup, "msgWeaponPickup");
    register_message(MsgId_AmmoPickup, "msgWeaponPickup");
}

public fwHamItemCanDrop_Pre(nWeapon)
{
    if (!IsValidPrivateDate(nWeapon))
        return HAM_IGNORED;
    
    SetHamReturnInteger(true);
    
    new nClientIndex = get_pdata_cbase(nWeapon, m_pPlayer, XO_CBASEPLAYERWEAPON);
    
    g_nRestoreFlashbangCount = cs_get_user_bpammo(nClientIndex, CSW_FLASHBANG);
    cs_set_user_bpammo(nClientIndex, CSW_FLASHBANG, -g_nRestoreFlashbangCount);
    
    new pActiveItem = get_pdata_cbase(nClientIndex, m_pActiveItem, XO_CBASEPLAYER);
    
    if (pActiveItem > 0)
        g_bIsFlashbangActive = cs_get_weapon_id(pActiveItem) == CSW_FLASHBANG;
    
    g_fwHookClientCommand = register_forward(FM_ClientCommand, "fwClientCommand_Post", true);
       
    return HAM_SUPERCEDE;
}

public fwClientCommand_Post(nClientIndex)
{
    unregister_forward(FM_ClientCommand, g_fwHookClientCommand, true);
    
    static szCommand[5]; read_argv(0, szCommand, charsmax(szCommand));
    
    if(equal(szCommand, "drop"))
    {
        if (g_nRestoreFlashbangCount)
        {
            cs_set_user_bpammo(nClientIndex, CSW_FLASHBANG, abs(cs_get_user_bpammo(nClientIndex, CSW_FLASHBANG)));
            
            if (g_nRestoreFlashbangCount >= 2)
            {
                give_item(nClientIndex, szItemList[FLASHBANG]);
                
                if (g_bIsFlashbangActive)
                    engclient_cmd(nClientIndex, szItemList[FLASHBANG]);
            }
            
            g_nRestoreFlashbangCount = 0;
            
            g_bIsFlashbangActive = false;
        }
    }
}

public msgWeaponPickup(pMsgId, pMsgDest, pMsgReceiver)
{
    if (g_nRestoreFlashbangCount) 
        return PLUGIN_HANDLED;
    
    return PLUGIN_CONTINUE;
}
