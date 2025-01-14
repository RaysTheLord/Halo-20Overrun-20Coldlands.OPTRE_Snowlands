/*
	Spawns a random mini-objective 
*/

params ["_locationIndex","_spawnArray"];

private _locationIndex = _this select 0;
private _spawnArray = _this select 1;

private _objLocs = [];
_objLocs append _spawnArray;
private _zCount = 0;

//objectiveComplete = false;
//publicVariable "objectiveComplete";
//_currentLoc = selectRandom _objLocs;

if (isServer) then {
	
	/*
	_suitableLoc = false; //***OUTDATED DELETE AFTER TEST
	_tooClose = false;
	
	
	//loop to ensure location doesn't spawn too close to players
	while{!_suitableLoc} do {
		//select a waypoint
		_currentLoc = selectRandom _objLocs;
		
		//check if it is too close to a player
		{
			if ((_currentLoc) distance _x < 31) then {
				_tooClose = true;				
			};
		} forEach allPlayers;
		
		//if there weren't any players too close, then exit loop
		if(_tooClose == false) then {
			_suitableLoc = true;
		};  
	};
	*/	
	//select a position for the new spawn group and ensure it's more than 30m from the players
	private _locCheck = false;
	private _locCheckCounter = 0;
	private _minimumDistance = 30;
	private _currentLoc = [ZoneArray select _locationIndex select 0, false] call CBA_fnc_randPosArea;
	
	while {!_locCheck} do {
		if (_locCheckCounter < 5) then {
			
			//select random spawnpoint
			_startSpawn = [ZoneArray select _locationIndex select 0, false] call CBA_fnc_randPosArea;
			_currentLoc = _startSpawn findEmptyPosition [0,10];
			
			//default _locCheck to true and only change to false if a player is too close to the spawn
			_locCheck = true;
			
			//check if it is within minimum distance of a player
			{
				//_currentDistance = getMarkerPos _currentLoc distance _x;
				_currentDistance = _currentLoc distance _x;
				if (_currentDistance < _minimumDistance) then {
					//*** debug
					diag_log format ["Cannot use spawn as it is within %1 of a player, less than the minimum of %2", _currentDistance, _minimumDistance];
				
					//if the spawn is too close, change _locCheck to false so the check runs again
					_locCheck = false;
				};							
			} forEach allPlayers;
			
			//increment counter
			_locCheckCounter = _locCheckCounter + 1;
		} else {
				//if no location can be found in 5 tries, lower the distance and try again
				if (_minimumDistance > 5) then {
					_minimumDistance = _minimumDistance - 2;
					_locCheckCounter = 0;							
				} else {
					//If distance is 5m, just use this as the best possible choice
					_locCheck = true;							
				};
		};
		
	};

	//select a random mini-objective
	_miniObj = selectRandom[0,1,2];
	//_miniObj = selectRandom[0];
	
	// -- generate mini-objective --
	
	//boss Z
	if(_miniObj == 0) then {
        //Flood objective
        _flood_objects = ["dev_flood_ball", "dev_flood_rock"];
        
        //Spawn it on the objective
        _gravemind = (selectRandom _flood_objects) createVehicle _currentLoc;
        
        //add index to gravemind
		_gravemind setVariable ["_bossLocationIndex", _locationIndex, true];
        
        //create marker to show the Gravemind
		createMarker ["_bossZMarker", _currentLoc];
		
		//make marker visible
		"_bossZMarker" setMarkerShape "ELLIPSE";
		"_bossZMarker" setMarkerColor "ColorRed";	
		"_bossZMarker" setMarkerSize [10,10];
		"_bossZMarker" setMarkerText "Proto-Gravemind Forming";		
		
		[_gravemind,_locationIndex] remoteExec ["fnc_bossZMarker",2];

		//log
		diag_log format ["Proto-Gravemind created near %1", ZoneArray select _locationIndex select 0];
			
        fnc_bossZMarker = {
            params ["_bossZ"];

            _bossZ = _this select 0;

            while {alive _bossZ} do {
                "_bossZMarker" setMarkerPos getPos _bossZ;

                sleep 10;
            };
        };
        
        //Handler to kill the Proto-Gravemind
        [
            _gravemind,														// Object the action is attached to
            "Destroy Proto_gravemind",													// Title of the action
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_forceRespawn_ca.paa",	// Idle icon shown on screen
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_forceRespawn_ca.paa",	// Progress icon shown on screen
            "_this distance _target < 3",									// Condition for the action to be shown
            "_caller distance _target < 3",									// Condition for the action to progress
            {},																// Code executed when action starts
            {},																// Code executed on every progress tick
            { 
                deleteVehicle _target;  

            },							// Code executed on completion
            {},																// Code executed on interrupted
            [],																// Arguments passed to the scripts as _this select 3
            12,																// Action duration in seconds
            0,																// Priority
            true,															// Remove on completion
            false															// Show in unconscious state
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _gravemind];				// MP-compatible implementation
        
        
        //Defenders
        _num_defenders = 6;
        
        //create group to put demon in
		private _bossGroup = createGroup[EAST,true]; 

        for "_i" from 1 to _num_defenders do {
            //select a demon
            _demonSelect = selectRandom DemonList; 
            //spawn the demon
            _flood = _bossGroup createUnit[_demonSelect,  _currentLoc, [], 5, "NONE"];
        };
		
		//set demon to defend point or patrol
		switch (selectRandom[0,0,1]) do {
			case 0: {[_bossGroup, _currentLoc] call BIS_fnc_taskDefend};
			case 1: {[_bossGroup, _currentLoc,20] call BIS_fnc_taskPatrol};
		};//end switch	

		//set mission as active in this location
		ZoneArray select _locationIndex set [4, true];
		
		//inform players		
		[["_bossZMarker",500,"The Flood are creating a Proto-Gravemind in your area. Destroy it to reduce infection."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];
        
        //Waituntil the gravemind is dead
        waitUntil{sleep 0.5; !alive _gravemind};
        //private _locationIndex = _gravemind getVariable "_bossLocationIndex";

        //set the objective variable to false
        ZoneArray select _locationIndex set [4, false];

        //set infection rate lower to prevent mission happening again
        ZoneArray select _locationIndex set [2, (ZoneArray select _locationIndex select 2) - 0.01];

        //inform nearby players
        private _messageMarker = ZoneArray select _locationIndex select 0;
        [[_messageMarker,500,"Proto-Gravemind destroyed. Carry on with the mission."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];		

        //subtract a point of infection so the objective doesn't proc again
        private _currentInfection = ZoneArray select _locationIndex select 2;
        _currentInfection = _currentInfection - 0.014;
        ZoneArray select _locationIndex set [2, _currentInfection];

        //add 10 currency into faction bank
        [[10],"addToBank.sqf"] remoteExec ["BIS_fnc_execVM",2];
        deleteMarker "_bossZMarker";		

        //log
        diag_log format ["Proto-Gravemind destroyed at %1", ZoneArray select _locationIndex select 0];

	};
	
	
	//kill zombie group
	if(_miniObj == 1) then {
		//select a random amount of zombies
		
		//set skill for group
		private _currentSkill = selectRandom [0.2,0.3,0.4,0.5,0.6,0.7];
		
		//create group to hold zombies
		zGroup = createGroup[EAST,true];
		
		//spawn zombies into group
		for [{ _i = 0 }, { _i < (round(random 15 + 5)) }, { _i = _i + 1 }] do {
			_newZ = zGroup createUnit[(selectRandom ZList), _currentLoc, [], 5, "NONE"]; 		
			//set random skill level
			_newZ setSkill _currentSkill;			
		};

		//order group to protect spawn
		[zGroup, _currentLoc] call BIS_fnc_taskDefend;
		
		//execute a script to check if zombies are still alive and if not, set mission active to false
		[_locationIndex] remoteExec ["fnc_zGroupWatch",2];
		[] remoteExec ["fnc_zGroupMarker",2];
		
			//Inline Function
			fnc_zGroupWatch = {
				params ["_locationIndex"];
				//detect if all units are dead
				waitUntil {({alive _x} count units zGroup) < 1;};
				//delete marker and set mission status to false				
				ZoneArray select _locationIndex set [4, false];
				//set infection rate lower to prevent mission happening again
				ZoneArray select _locationIndex set [2, (ZoneArray select _locationIndex select 2) - 0.01];
			   [["_zMarker",300,"Looks like you've neutralized the Flood there. Keep working on clearing the rest of the area."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];
			   sleep 0.5;
			   deleteMarker "_zMarker";
			   //add 10 currency into faction bank
				[[10],"addToBank.sqf"] remoteExec ["BIS_fnc_execVM",2];
				
				//log
				diag_log format ["Flood eliminated %1", ZoneArray select _locationIndex select 0];
			   
			};//end zGroupWatch
			
			//Set marker to center of group every 10 seconds
			fnc_zGroupMarker = {

				while {({alive _x} count units zGroup) > 1;} do {
					private _centerPos = [0,0,0];

					//-- Add all zombie positions
					{
						_centerPos = _centerPos vectorAdd (getPos _x);
					} forEach units zGroup; // array of zombies

					//-- Divide sums by count of players
					_centerPos = _centerPos vectorMultiply (1 / count units zGroup); // vectorDivide is not a command
					
					"_zMarker" setMarkerPos _centerPos;
					
					sleep 10;
				};
			};
		
		
		//create marker to show zombie location
		createMarker ["_zMarker", _currentLoc];
		
		//make marker visible
		"_zMarker" setMarkerShape "ELLIPSE";
		"_zMarker" setMarkerColor "ColorRed";	
		"_zMarker" setMarkerSize [25,25];
		"_zMarker" setMarkerText "Significant Flood Presence";
		
		//set mission as active in this location
		ZoneArray select _locationIndex set [4, true];

		//inform players
		[["_zMarker",500,"A significant presence of Flood forms has been detected. Go clear them out to reduce the infection..."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];
		
		//log
		diag_log format ["Zombie horde spawned near %1", ZoneArray select _locationIndex select 0];
	};
	
		//gather research
	if(_miniObj == 2) then {
		//pick from research objects
		_researchSelect = selectRandom ResearchObjects;		
		
		//create marker to show research location
		createMarker ["_intelMarker", _currentLoc];
		
		//make marker visible
		"_intelMarker" setMarkerShape "ELLIPSE";
		"_intelMarker" setMarkerColor "ColorRed";	
		"_intelMarker" setMarkerSize [15,15];
		"_intelMarker" setMarkerText "Research area";		
		
		private _spawnLoc = _currentLoc;
		
		//spawn object at selected point
		_researchObject = _researchSelect createVehicle _spawnLoc;
		_researchObject setPos [getPos _researchObject select 0, getPos _researchObject select 1, (getPos _researchObject select 2) + 2];	

		//add index to research object
		_researchObject setVariable ["_intelLocationIndex", _locationIndex, true];
		
		//[_researchObject] remoteExec ["fnc_takeResearch",0];
		[_researchObject, _locationIndex] remoteExec ["fnc_researchMarker",2];
		
			/*
			fnc_takeResearch = {
				params["_locationIndex","_researchObject"];
				 //_researchObject = _this select 0;
				 //_locationIndex = _this select 1;
				hintSilent format ["values are %1 + %2", _researchObject, _locationIndex]; //***TESTING DELETE
				//objectiveComplete = true;
				//publicVariable "objectiveComplete"; 
				ZoneArray select _locationIndex set [4, false];
				deleteVehicle _researchObject; 
				[["_intelMarker",300,"Thanks, we'll begin analyzing this now. Continue the clean-up."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];
				sleep 0.5;
				deleteMarker "_intelMarker";
				//add 10 currency into faction bank
				[[10],"addToBank.sqf"] remoteExec ["BIS_fnc_execVM",2];
			};
			*/
			
			//move marker over research object in case it gets moved (explosion, etc)
			fnc_researchMarker = {
				//params ["_researchObject","_locationIndex"];				
				 _researchObject = _this select 0;
				 _locationIndex = _this select 1;

				//while {!objectiveComplete} do {
				while {ZoneArray select _locationIndex select 4 == true} do {;
					"_intelMarker" setMarkerPos getPos _researchObject;
					sleep 10;
				};
			};
			
			
		//add an action to take research
		//[_researchObject,["Take research", {[_researchObject,_locationIndex] remoteExec ["fnc_takeResearch",2];},nil,1.5,FALSE,FALSE,"","CleanseActive == false",5,false,"",""]] remoteExec ["addAction",0];			
		[_researchObject,["Take research", {call {
			//get location from object
			_researchObject = _this select 0;
			//get point mission is connected to 
			private _locationIndex = _researchObject getVariable "_intelLocationIndex";
			
			deleteVehicle _researchObject; 
			//alert players mission is over
			private _messageMarker = ZoneArray select _locationIndex select 0;
			[[_messageMarker,500,"Collected for analysis. Continue the clean-up."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];	
			sleep 0.5;
			deleteMarker "_intelMarker";
			//add 10 currency into faction bank
			[[10],"addToBank.sqf"] remoteExec ["BIS_fnc_execVM",2];
			
			
		};},nil,1.5,FALSE,FALSE,"","CleanseActive == false",5,false,"",""]] remoteExec ["addAction",0];			

		//set mission as active in this location
		ZoneArray select _locationIndex set [4, true];

		//inform players
		[["_intelMarker",500,"Reports indicate valuable research on the Flood was dropped in your area. Secure it for further study..."],"messageNear.sqf"] remoteExec ["BIS_fnc_execVM",0];
		
		//log
		diag_log format ["Research spawned near %1", ZoneArray select _locationIndex select 0];
		
		//wait until pickup has destroyed the object
		waitUntil{sleep 0.5; isNull _researchObject};

		//update server that mission is over
		//log
		diag_log format ["Research picked up near %1", ZoneArray select _locationIndex select 0];
		//clear mission state			
		ZoneArray select _locationIndex set [4, false];
		//set infection rate lower to prevent mission happening again
		ZoneArray select _locationIndex set [2, (ZoneArray select _locationIndex select 2) - 0.01];		

	};
	
	/* *** ADD AFTER ENGI-ONLY EXPLOSIVES ADDED
	//destroy object
	if(_miniObj == 3) then{
		//select object
		_objectSelect = selectRandom["Land_TrailerCistern_wreck_F","Land_Tank_rust_F","Land_dp_smallTank_F",
	
		//create a suspicious object to destroy
		
	};
	*/
	
};