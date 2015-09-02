#include <amxmodx>
#include <hamsandwich>
#include <fakemeta_util>

#pragma semicolon 1

#define PLUGIN "Knife Drop"
#define VERSION "1.0"
#define DATE "28.08.2015"
#define URL "http://eriurias.ru"
#define AUTHOR "Eriurias"

new const ENTITY_CLASSNAME[] = "weapon_knife";
 
public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR/*DATE, URL*/);
     
    RegisterHam(Ham_CS_Item_CanDrop, ENTITY_CLASSNAME, "fwHamItemCanDrop_Pre");
    RegisterHam(Ham_Touch, "weaponbox", "fwHamTouch_Pre");
    RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawn_Post", .Post = true);
}
 
public fwHamItemCanDrop_Pre(pWeapon)
{
    SetHamReturnInteger(true);
        
    return HAM_SUPERCEDE;
}

public fwHamTouch_Pre(pEntity, nClientIndex)
{
    if (pev(pEntity, pev_flags) & FL_ONGROUND)
    {
        static szModel[32];
        pev(pEntity, pev_model, szModel, charsmax(szModel));
        
        if (szModel[9] == 'k' && szModel[12] == 'f' && user_has_weapon(nClientIndex, CSW_KNIFE))
            return HAM_SUPERCEDE;
    }
    
    return HAM_IGNORED;
}

public fwHamPlayerSpawn_Post(nClientIndex)
{
    if (is_user_alive(nClientIndex) && !user_has_weapon(nClientIndex, CSW_KNIFE))
        fm_give_item(nClientIndex, ENTITY_CLASSNAME);
}