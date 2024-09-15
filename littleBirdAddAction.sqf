/*
	Adds correct command to littleBird based on passed value
*/

params["_littleBirdArmed"];

_littleBirdArmed = _this select 0;

//check if littleBird is still armed
if(_littleBirdArmed == true) then {
	littleBird addAction ["Attract Flood", {["littleBirdDecon.sqf"] remoteExec ["BIS_fnc_execVM",0];},nil,1.5,FALSE,true,"","true",5,false,"",""];
} else {
	//if not, add rearm command
	littleBird addAction ["Rearm Flood attractors", {["rearmLittleBird.sqf"] remoteExec ["BIS_fnc_execVM",0];},nil,1.5,FALSE,true,"","true",5,false,"",""];
};