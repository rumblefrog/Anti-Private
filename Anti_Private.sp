#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "0.0.0"

#include <sourcemod>
#include <smjansson>
#include <SteamWorks>

#pragma newdecls required

#define PlayerURL "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/"
#define InventoryURL "https://api.steampowered.com/IEconItems_440/GetPlayerItems/v0001/"

enum DealMethod {
	m_KICK = 1,
	m_WARN
}

ConVar cKey, cMethod;

char sDKey[64];
DealMethod mMethod;

public Plugin myinfo = 
{
	name = "Anti Private",
	author = PLUGIN_AUTHOR,
	description = "Kicks private profile & inventory",
	version = PLUGIN_VERSION,
	url = "https://keybase.io/rumblefrog"
};

public void OnPluginStart()
{
	CreateConVar("sm_anti_private_version", PLUGIN_VERSION, "Anti Private Version", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	
	cKey = CreateConVar("sm_anti_private_key", "", "Steam Developer API Key", FCVAR_NONE | FCVAR_PROTECTED);
	cMethod = CreateConVar("sm_anti_private_method", "1", "1 - Kick, 2 - Warn", FCVAR_NONE, true, 1.0, true, 2.0);
	
	cKey.GetString(sDKey, sizeof sDKey);
	cKey.AddChangeHook(OnConVarChanged);
	
	mMethod = view_as<DealMethod>(cMethod.IntValue);
	cMethod.AddChangeHook(OnConVarChanged);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == cKey)
		cKey.GetString(sDKey, sizeof sDKey);
	if (convar == cMethod)
		mMethod = view_as<DealMethod>(cMethod.IntValue);
}


