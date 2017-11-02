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

enum RequestType
{
	t_PROFILE,
	t_INVENTORY
}

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
	
	LoadTranslations("anti_private.phrases");
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
		SteamWorks_SetHTTPRequestContextValue(hPlayerRequest, iClient, t_PROFILE);
		SteamWorks_SetHTTPCallbacks(hPlayerRequest, OnSteamWorksHTTPComplete); 
		if (!SteamWorks_SendHTTPRequest(hPlayerRequest))
			HandleHTTPError(iClient);
	}
	else if (STEAMTOOLS_AVAILABLE())
	{
		HTTPRequestHandle hPlayerRequest = Steam_CreateHTTPRequest(HTTPMethod_GET, PlayerURL);
		Steam_SetHTTPRequestGetOrPostParameter(hPlayerRequest, "key", sDKey);
		Steam_SetHTTPRequestGetOrPostParameter(hPlayerRequest, "steamids", SteamID);
		
		DataPack pData = new DataPack();
		
		pData.WriteCell(iClient);
		pData.WriteCell(t_PROFILE);
		
		
		if (!Steam_SendHTTPRequest(hPlayerRequest, OnSteamToolsHTTPComplete, iClient))
			HandleHTTPError(iClient);
	}
}

public int OnSteamWorksHTTPComplete(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int iClient, RequestType iType)
{
	if (bRequestSuccessful && eStatusCode == k_EHTTPStatusCode200OK)
	{
		int iSize;
		
		SteamWorks_GetHTTPResponseBodySize(hRequest, iSize);
		
		char[] sBody = new char[iSize];
		
		SteamWorks_GetHTTPResponseBodyData(hRequest, sBody, iSize);
		
		if (iType == t_PROFILE)
			ParseProfile(sBody, iClient);
		else if (iType == t_INVENTORY)
			ParseInventory(sBody, iClient);
	} 
	else
		HandleHTTPError(iClient);
}

public int OnSteamToolsHTTPComplete(HTTPRequestHandle HTTPRequest, bool requestSuccessful, HTTPStatusCode statusCode, DataPack pData)
{
	pData.Reset();
}

void ParseProfile(const char[] sBody, int iClient)
{
	Handle hJson = json_load(sBody);
	
	Handle hResponse = json_object_get(hJson, "response");
	Handle hPlayers = json_object_get(hResponse, "players");
	Handle hPlayer = json_array_get(hPlayers, 0);
	int iState = json_object_get_int(hPlayer, "communityvisibilitystate");
	
	if (iState == 3)
	{
		// Send request for inventory
	}
	else
		HandleDeal(t_PROFILE, iClient);
}

void ParseInventory(const char[] sBody, int iClient)
{
	
}

void HandleDeal(RequestType iType, int iClient)
{
	if (iDealMethod = d_KICK)
		if (iType == t_PROFILE)
			KickClient(iClient, "%T", "Private Profile");
		else if (iType == t_INVENTORY)
			KickClient(iClient, "%T", "Private Inventory");
		
}

void HandleHTTPError(int iClient)
{
	if (iFailMethod == f_KICK)
		KickClient(iClient, "%T", "Error");
		
	LogError("Failed to send HTTP request (Is Steam Down?)");
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


