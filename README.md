<p align="center">
	<img alt="CIDR Blocker" src="assets/img/Anti_Private_256.png" height="250" width="250">
</p>

<p align="center">
	Kicks private profile & inventory
</p>

<p align="center">
	<a href="https://travis-ci.org/RumbleFrog/Anti-Private"><img alt="Travis CI Status" src="https://img.shields.io/travis/RumbleFrog/Anti-Private.svg?style=flat-square"></a>
	<a href="https://github.com/RumbleFrog/Anti-Private/issues"><img alt="Issues" src="https://img.shields.io/github/issues/RumbleFrog/Anti-Private.svg?style=flat-square"></a>
	<a href="https://discord.gg/gh8uMa9"><img src="https://img.shields.io/discord/364849839508553730.svg?style=flat-square"></a>
	<img alt="Downloads" src="https://img.shields.io/github/downloads/RumbleFrog/Anti-Private/total.svg?style=flat-square">
</p>

---

# Convar

- **sm_anti_private_deal_method** Method of action when private profile/inventory has been detected (1 - Kick | 2 - Warn) [Default: **1.0**] (Min: **1.0**) (Max: **2.0**)

- **sm_anti_private_fail_method** Method of action when the plugin fails to fetch result (1 - Nothing | 2 - Kick) [Default: **1.0**] (Min: **1.0**) (Max: **2.0**)

- **sm_anti_private_key** Steam Developer API Key; Required for this plugin to work

# Installation

1. Extract **Anti_Private.smx** to **/addons/sourcemod/plugins**

2. Extract **anti_private.phrases.txt** to **/addons/sourcemod/translations**

3. Load the plugin (`sm plugins load Anti_Private`), change the map, **OR** restart the server

4. Edit **/cfg/sourcemod/anti_private.cfg**
	- Update `sm_anti_private_key` with value obtained from https://steamcommunity.com/dev/apikey

5. Reload the plugin (`sm plugins reload Anti_Private`), change the map, **OR** restart the server

# Notes

- With high traffic servers, you may exceed Steam's API rate limit
- Since this plugin depends on Steam, during Steam maintenance/outage (*Tuesday*), this plugin may not work

# Translations

If you wish to contribute to the phrases file, please fork this repository and open a pull request

# Download

Download the latest version from the [release](https://github.com/RumbleFrog/Anti-Private/releases) page

# License

GPL-3.0

Icon made by <a href="http://www.freepik.com/" target="_blank">Freepik</a> from <a href="http://www.flaticon.com/" target="_blank">http://www.flaticon.com/</a>
