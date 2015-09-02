new g_fmSpawn;

CreateFakeBuyZone()
{
    engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"));
}

CreateFakeHostage()
{
    new pHostage = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"));
    
    engfunc(EngFunc_SetOrigin, pHostage, Float:{0.0, 0.0, -55000.0});
    engfunc(EngFunc_SetSize, pHostage, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
    dllfunc(DLLFunc_Spawn, pHostage);
}

Fakemeta_Precache()
{
    CreateFakeBuyZone();
    CreateFakeHostage();
    g_fmSpawn = register_forward(FM_Spawn, "fwdFMSpawn", true);
}

Fakemeta_Init()
{
    unregister_forward(FM_Spawn, g_fmSpawn, true);
}

public fwdFMSpawn(pEntity)
{
    if(!pev_valid(pEntity))
        return;
    
    new szClassName[32];
    pev(pEntity, pev_classname, szClassName, charsmax(szClassName));
    
    if(TrieKeyExists(g_tEntityList, szClassName))
        engfunc(EngFunc_RemoveEntity, pEntity);   
}