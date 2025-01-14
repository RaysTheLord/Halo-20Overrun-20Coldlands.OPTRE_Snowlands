/*
	Spawns a helicopter if it is unlocked with a respawn command
*/
if (!isServer) exitWith {};

if(isServer) then {

	//create new littleBird
	littleBird = LittleBirdType createVehicle getMarkerPos "heliSpawn"; 
	littleBird setDir 136;

	//add new eventHandler to new vic
	//littleBird addEventHandler ["Killed",{execVM "littleBirdDestroyed.sqf"}];
	[littleBird, ["Killed",{
		["littleBirdDestroyed.sqf"] remoteExec ["BIS_fnc_execVM",2]
	}]] remoteExec ["addEventHandler",0];
	
	
	//global variable for if airborne decon needs to be rearmed
	LittleBirdArmed = true;
	publicVariable "LittleBirdArmed";
	
	
	//create marker
	createMarker ["littleBirdMarker",littleBird];
	"littleBirdMarker" setMarkerType "mil_triangle";
	"littleBirdMarker" setMarkerText "Falcon";
	"littleBirdMarker" setMarkerAlpha 0.7;
	
	//update marker
	execVM "littleBirdMarker.sqf";

	//add decon action to heli
	[littleBird,["Attract Flood", {["littleBirdDecon.sqf"] remoteExec ["BIS_fnc_execVM",0];},nil,1.5,FALSE,true,"","LittleBirdArmed == true",5,false,"",""]] remoteExec ["addAction",0];
	[littleBird,["Rearm Flood Attractors", {["rearmLittleBird.sqf"] remoteExec ["BIS_fnc_execVM",0];},nil,1.5,FALSE,true,"","LittleBirdArmed == false",5,false,"",""]] remoteExec ["addAction",0];
	sleep 0.5;
	
	//log
	diag_log "** littleBird has been unlocked.";

};