/*
	Script to inform players of scenario victory!
*/
sleep 2;

[["It's finished. The Flood have been eradicated from the area.", "PLAIN"]] remoteExec ["titleText", 0];

sleep 5;

[["Thank you for playing Flood Overrun Alpha!\nPlease give UselessFodder and Ray your feedback to improve this scenario!\nYou can find them at discord.gg/UselessFodder or on socials", "PLAIN"]] remoteExec ["titleText", 0];

sleep 5;

//end the mission and return to select screen
"end1" call BIS_fnc_endMission;