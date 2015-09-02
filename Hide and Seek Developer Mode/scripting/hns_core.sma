#include <amxmisc>
#include <hamsandwich>
#include <fakemeta_util>
#include <cstrike>

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN "Hide and Seek: Developer Tools"
#define VERSION "3.5.1 Stable"
#define DATE "28.08.2015"
#define URL "http://eriurias.ru"
#define AUTHOR "Eriurias"

#include "hns_engine\hns_config.inl"
#include "hns_engine\hns_defines.inl"
#include "hns_engine\hns_events.inl"
#include "hns_engine\hns_hamsandwich.inl"
#include "hns_engine\hns_fakemeta.inl"
#include "hns_engine\hns_messages.inl"
#include "hns_engine\hns_natives.inl"

public plugin_precache()
{
    LoadConfig();
    Fakemeta_Precache();
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR/*, DATE, URL*/);
    
    Events_Init();
    Messages_Init();
    HamSandwich_Init();
    Fakemeta_Init();
}

public plugin_natives() RegisterNatives();

public plugin_cfg() SetCvars();