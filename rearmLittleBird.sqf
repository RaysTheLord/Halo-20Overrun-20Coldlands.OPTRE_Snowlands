/*
	Adds Airborne Decon command back to helicopter
*/

//remove all custom commands from heli
//littleBird remoteExec ["removeAllActions", 0];
{removeAllActions littleBird;} remoteExec ["call", 0]; 

//check if heli is near helipad
if ((littleBird distance getMarkerPos "heliSpawn") < 10) then {
	//Inform user of wait time
	[["heliSpawn",20,"Rearming airborne Flood attractors now..."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];	
	//wait 10 seconds
	sleep 10;
	//inform complete
	[["heliSpawn",20,"Flood attractors rearmed!"],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];
	//global variable for armed status
	LittleBirdArmed = true;
	publicVariable "LittleBirdArmed";
	
	//give action back
	[[LittleBirdArmed],"littleBirdAddAction.sqf"] remoteExec ["BIS_fnc_execVM",0];

} else {
	//if not near, inform user and add rearm command back to heli
	[["littleBirdMarker",200,"Helicopter is too far from helipad at base. Get within 10m and try again..."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];	
	//add rearm command
	[[LittleBirdArmed],"littleBirdAddAction.sqf"] remoteExec ["BIS_fnc_execVM",0];
};