#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "0.0.0"

#include <sourcemod>
#include <smjansson>
#undef REQUIRE_EXTENSIONS
#include <SteamWorks>
#include <steamtools>
#define REQUIRE_EXTENSIONS

#pragma newdecls required

#define STEAMTOOLS_AVAILABLE()	(GetFeatureStatus(FeatureType_Native, "Steam_CreateHTTPRequest") == FeatureStatus_Available)
#define STEAMWORKS_AVAILABLE()	(GetFeatureStatus(FeatureType_Native, "SteamWorks_WriteHTTPResponseBodyToFile") == FeatureStatus_Available)

#define PlayerURL "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/"
#define InventoryURL "https://api.steampowered.com/IEconItems_440/GetPlayerItems/v0001/"

enum DealMethod
{
	m_KICK = 1,
	m_WARN
}

enum FailMethod
{
	f_KICK = 1,
	f_STAY
}

ConVar cKey, cDeal, cFail;

char sDKey[64];

DealMethod iDealMethod;
FailMethod iFailMethod;

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
	if (!STEAMTOOLS_AVAILABLE() && !STEAMWORKS_AVAILABLE())
		SetFailState("This plugin requires either SteamWorks OR SteamTools");
	
	CreateConVar("sm_anti_private_version", PLUGIN_VERSION, "Anti Private Version", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	
	cKey = CreateConVar("sm_anti_private_key", "", "Steam Developer API Key", FCVAR_NONE | FCVAR_PROTECTED);
	cDeal = CreateConVar("sm_anti_private_deal_method", "1", "1 - Kick, 2 - Warn", FCVAR_NONE, true, 1.0, true, 2.0);
	cFail = CreateConVar("sm_anti_private_fail_method", "1", "1 - Allow them to stay on the server, 2 - Kicks them from the server", FCVAR_NONE, true, 1.0, true, 2.0);
	
	cKey.GetString(sDKey, sizeof sDKey);
	cKey.AddChangeHook(OnConVarChanged);
	
	iDealMethod = view_as<DealMethod>(cDeal.IntValue);
	cDeal.AddChangeHook(OnConVarChanged);
	
	iFailMethod = view_as<FailMethod>(cFail.IntValue);
	cFail.AddChangeHook(OnConVarChanged);
	
	RegAdminCmd("anti_private_admin", CmdVoid, ADMFLAG_RESERVATION, "Checks user permission level");
}

public Action CmdVoid(int iClient, int iArgs) {}

public void OnClientPostAdminCheck(int iClient)
{
	if (StrEqual(sDKey, ""))
		return;
	
	if (CheckCommandAccess(iClient, "anti_private_admin", ADMFLAG_RESERVATION))
		return;
		
	char SteamID[64];
	
	GetClientAuthId(iClient, AuthId_SteamID64, SteamID, sizeof SteamID);
		
	if (STEAMWORKS_AVAILABLE())
	{
		Handle hPlayerRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, PlayerURL);
		SteamWorks_SetHTTPRequestGetOrPostParameter(hPlayerRequest, "key", sDKey);
		SteamWorks_SetHTTPRequestGetOrPostParameter(hPlayerRequest, "steamids", SteamID);
	}
	else if (STEAMTOOLS_AVAILABLE())
	{
		
	}
	
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == cKey)
		cKey.GetString(sDKey, sizeof sDKey);
	if (convar == cDeal)
		iDealMethod = view_as<DealMethod>(cDeal.IntValue);
	if (convar == cFail)
		iFailMethod = view_as<FailMethod>(cFail.IntValue);
}


