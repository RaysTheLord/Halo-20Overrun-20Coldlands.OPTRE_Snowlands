/*
    File: area_cleanse.sqf
    Author: UselessFodder
    Date: 2020-10-18
    Last Update: 2022-09-13

    Description:
        Spawns zombies in 

*/

/*
	if # of zombies in passed marker < passed total # of Z
		spawn random zombie type at random _SP#
*/

//variables
private _nearLoc = "";
private _locIndex = -1;

diag_log "Cleanse activated";

{
	diag_log format ["Checking distance to %1", _x select 0];
	if (50 >= (deconTruck distance getMarkerPos (_x select 0))) then {	
		_nearLoc = (_x select 0);
		_locIndex = _forEachIndex;
		diag_log format ["DECON truck is within 50m to %1", _nearLoc];		
	} else {
		diag_log "Distance >50m";
	};	
	
} forEach ZoneArray;

//if null, this is not near location
if(_nearLoc isEqualTo "") then {
	titleText ["The DECON Vehicle is too far from any infected point.\nIt can only be operated within 50m of an infection center", "PLAIN"];
} else {
	// Check if area is still infected
	//if (isInfected select _locIndex == false) then {
		if (ZoneArray select _locIndex select 1 == false) then {
		titleText [format ["%1 has already been decontaminated!", _nearLoc], "PLAIN"];
	} else {
		// Else, check if infection rate is below 10%
		if((ZoneArray select _locIndex select 2) > 0.1) then {
			titleText ["The Flood are already agitated.\nClear more of them from the area!", "PLAIN"];
		} else {
			
			if(isServer) then {
				[_locIndex,_nearLoc] remoteExec ["fnc_deconStart",2];			
			};
			
			fnc_deconStart = {
				params ["_locIndex","_nearLoc"];
				private _locIndex = _this select 0;
				private _nearLoc = _this select 1;
				
				[[_nearLoc,300,"Attracting Flood forms... Please Hold...."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];
				sleep 5;
				
				if(isServer) then {
					//set CleanseActive to true and execute area_cleanse
					CleanseActive = true;
					publicVariable "CleanseActive";					

					If(isNil "_deconMan") then {
						_decon = createGroup [west, deleteWhenEmpty];
						_decon addVehicle deconTruck; 
						deconTruck lock true;
						deconTruck lockDriver true;
						_deconMan = _decon createUnit ["OPTRE_FC_Marines_Soldier_Unarmed", getPos deconTruck,[],5, "NONE"];
						[_deconMan] orderGetIn true;
						_deconMan disableAI "all";
						_deconMan setBehaviour "CARELESS";
						_deconMan assignAsCargo deconTruck;
						_deconMan moveInCargo [deconTruck,0];
						deconTruck allowCrewInImmobile true;
						//if deconMan gets out, delete him
						_deconMan addEventHandler ["GetOutMan", {params ["_unit", "_role", "_vehicle", "_turret"]; __unit moveInCargo [deconTruck,0];}];
					};
					
					//send all nearby zombies to attack
					private _nearbyZGroups = [];
					//get all units near truck
					{
						if(_x distance deconTruck < 600) then {
							//only add groups if not yet added
							_nearbyZGroups pushBackUnique group _x;
						};
					} forEach allUnits;
					
					//give orders to attack deconTruck
					{
						[_x] execVM "zOrders.sqf";
					} forEach _nearbyZGroups;
					
					//[_locIndex,_nearLoc] remoteExec ["area_cleanse.sqf", [0,2] select isDedicated, true];
					//[_locIndex,_nearLoc] execVM "area_cleanse.sqf";
					[[_locIndex,_nearLoc],"area_cleanse.sqf"] remoteExec ["BIS_fnc_execVM",2];
				};			
			
			};
		};
	
	};

};
