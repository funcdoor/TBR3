
-- called when 1 hero enters an area

function SpawnArea( trigger )
	areaName = trigger.caller:GetName()

	if not IsAreaActive( areaName ) then
		SetAreaActive( areaName, true )
		
		print("\n Spawning units of "..areaName.. "\n")
		
		-- initialize the table to store all the creeps in the area
		InitializeCreepList( areaName )

		-- Spawn Initial Units
		local AreaInfoList = GameMode.SpawnInfoKV[ areaName ]
		DeepPrintTable(AreaInfoList)
		for k,v in pairs( AreaInfoList ) do
			--v.Name is the unit to spawn
			--v.MaxSpawn is how many
			print("Spawning",v.MaxSpawn,k)
			for i=1,v.MaxSpawn do
				-- Get a spawn location for a particular unit
				local spawnLocation = GetNewPositionInAreaFor(areaName,k)

				if spawnLocation ~= nil then	
					local unit = CreateUnitByName(k, spawnLocation:GetOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
					unit:SetForwardVector(RandomVector(5000)) -- variate facing of the unit
					unit.area = areaName -- set the area to respawn easier
					table.insert( GetAreaCreepList(areaName) ,unit) -- store the unit in the area table
				else
					print("No spawn location found")
				end
			end	
		end		
	end
end

-- called after all the heroes leave the area
function DespawnArea( trigger )
	areaName = trigger.caller:GetName()

	if IsAreaActive( areaName ) then
		SetAreaActive( areaName )
		print("\n Despawning units of "..areaName.. " \n")

		local creepsDeleted = 0
		local creep_list = GetAreaCreepList( areaName )
		for _,creep in pairs(creep_list) do
			if creep ~= nil and creep:IsAlive() then 
				UTIL_Remove(creep)
				creepsDeleted = creepsDeleted+1
			else print("Creep is not alive or has not respawned yet, ignoring.") end
		end
		print("Deleted ",creepsDeleted," creeps")
	end
end

-- called after a unit dies, starts a timer to spawn a new unit near the original spawn location
function RespawnCreep( event )

	-- get the unit name to respawn
	local unit = event.caster 
	local unit_name = unit:GetUnitName()

	-- get the area the unit belongs to
	local unit_area = unit.area
	local area_table = GameMode.SpawnInfoKV[unit_area]

	-- get the unit respawn time from the spawn_info table
	local unitTableIndex = getUnitIndex(area_table,unit_name)
	local respawn_time = area_table[unit_name].RespawnTime

	Timers:CreateTimer({
    endTime = respawn_time,
    callback = function()
    	-- we have to check to which area this unit belongs
    	if IsAreaActive(unit_area) then
			-- get a new position and create the unit
			local new_position = GetNewPositionInAreaFor(unit_area,unit_name)
			local new_unit = CreateUnitByName(unit_name, new_position:GetOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
			print("Respawned unit in "..respawn_time.. " seconds on ",new_position:GetOrigin())

			-- variate facing of the unit
			new_unit:SetForwardVector(RandomVector(5000))
			-- set the area to respawn easier
			new_unit.area = unit_area 

			-- get the creep list to add and remove
			local creep_list = GetAreaCreepList(unit_area)

			-- add the new_unit handle to the area creep list
			table.insert(creep_list,new_unit)
			-- remove the old unit
			table.remove(creep_list,getIndex(creep_list, unit))
		end
    end
  	})

end

------------------
-- Area Methods --
------------------

-- returns whether the area is activate or not, that is, there are still players inside the area
function IsAreaActive( areaName )
	if areaName == "GoblinArea" then
		return GameMode.GoblinAreaActive
	elseif areaName == "BlackGoblinArea" then
		return GameMode.BlackGoblinAreaActive
	elseif areaName == "BanditArea" then
		return GameMode.BanditAreaActive
	end
end

-- sets the area active or inactive
function SetAreaActive( areaName, bool )
	if areaName == "GoblinArea" then
		GameMode.GoblinAreaActive = bool
	elseif areaName == "BlackGoblinArea" then
		GameMode.BlackGoblinAreaActive = bool
	elseif areaName == "BanditArea" then
		GameMode.BanditAreaActive = bool
	end
end

function InitializeCreepList( areaName )
	if areaName == "GoblinArea" then
		GameMode.GoblinAreaCreeps = {}
	elseif areaName == "BlackGoblinArea" then
		GameMode.BlackGoblinAreaCreeps = {}
	elseif areaName == "BanditArea" then
		GameMode.BanditAreaCreeps = {}
	end
end

-- returns the list in which the creeps of the area are stored
function GetAreaCreepList( areaName )
	if areaName == "GoblinArea" then
		return GameMode.GoblinAreaCreeps
	elseif areaName == "BlackGoblinArea" then
		return GameMode.BlackGoblinAreaCreeps
	elseif areaName == "BanditArea" then
		return GameMode.BanditAreaCreeps
	end
end

-- Gives a new position from the available for that type of creature
function GetNewPositionInAreaFor( areaName, unitName )
	print("Finding new position in ",areaName," for ",unitName)
	if areaName == "GoblinArea" then
		if unitName == "npc_goblin" then
			return GameMode.goblin_spawnLocations[RandomInt(1, #GameMode.goblin_spawnLocations)]
		elseif unitName == "npc_shaman" then
			return GameMode.shaman_spawnLocations[RandomInt(1, #GameMode.shaman_spawnLocations)]
		end
	elseif areaName == "BlackGoblinArea" then
		if unitName == "npc_black_goblin" then
			return GameMode.black_goblin_spawnLocations[RandomInt(1, #GameMode.black_goblin_spawnLocations)]
		elseif unitName == "npc_black_shaman" then
			return GameMode.black_shaman_spawnLocations[RandomInt(1, #GameMode.black_shaman_spawnLocations)]
		elseif unitName == "npc_ogre" then
			return GameMode.ogre_spawnLocations[RandomInt(1, #GameMode.ogre_spawnLocations)]
		end
	elseif areaName == "BanditArea" then
		if unitName == "npc_bandit" then
			return GameMode.bandit_spawnLocations[RandomInt(1, #GameMode.bandit_spawnLocations)]
		end
	end
end