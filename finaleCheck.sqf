/*
	Checks if all currently unlocked zones are deconed and begins final zone, if enabled
*/

//log run of this script
diag_log "Running Finale Check";

//get mission param on victory % needed
_victoryPercent = ["PercentToVictory", 100] call BIS_fnc_getParamValue;

//get full list and count of ZoneArray indexes currently created in Overrun
_victoryZoneCount = (count ZoneArray) * _victoryPercent;

//value to hold total number of deconed zones
_totalDeconed = 0;

//forEach loop to check each member of _currrentZones
{
	//check if isInfected is false, meaning it's deconed
	if(!(_x select 1)) then{
		//add a counter to the overal deconed areas
		_totalDeconed = _totalDeconed + 1;
	};//end if

} forEach ZoneArray;

//log total number of deconed zones
diag_log format ["%1 out of %2 zones deconed",_totalDeconed,_victoryZoneCount];

//If all zones are deconed, _totalDeconed will equal _victoryZoneCount and the finale event will open up
if (_totalDeconed >= _victoryZoneCount) then {
    execVM "victory.sqf";
    
    //NO FINALE FOR NOW
    /*
	//check if finale is enabled in params
	private _doFinale = ["DoFinale", 0] call BIS_fnc_getParamValue;
	if (_doFinale) then {
		//Notify all players
		[["The Flood infestation has almost been destroyed. Finish the fight.", "PLAIN"]] remoteExec ["titleText", 0];
		
		sleep 3;
		
		//create a task notification
		["TaskAssigned", ["", format ["Decontaminate the Infection source at the old Military Base"]]] remoteExec ['BIS_fnc_showNotification',0,FALSE];
		
		//change area warning to draw the players in
		"finaleWarning" setMarkerText "DESTROY THE LAST OF THE FLOOD";
		
		
		//set FinaleReady variable to ensure access to the final area
		FinaleReady = true;
		publicVariable "FinaleReady";
	} else {
		//if finale is disabled, simply generate victory
		execVM "victory.sqf";
	};
    */
};
