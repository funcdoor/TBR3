function AssignMaterials( event )
	print("Assigning Materials")

	-- handle of the creep that was just killed
	local killedUnit = EntIndexToHScript( event.caster_entindex )
	local materialsToAssign = 0

	-- This could/should be done with a table, but I'm lazy so I'll use a bunch of ifs
	if killedUnit:GetUnitName() == "npc_demon_fire" then
		materialsToAssign = 322 --placeholder, will use the proper values when we port the units
	end

	-- Find nearby units
	local units = FindUnitsInRadius(event.caster:GetTeamNumber(), event.caster:GetAbsOrigin(), nil, 900,
						DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	-- Increase the resource of each one
    for _,unit in pairs(units) do
    	if unit:IsRealHero() then
    		unit.materials = unit.materials + materialsToAssign
    		print("Materials Assigned. " .. unit:GetName() .. " is currently at " .. unit.materials)
    	end
    end

    -- Display the custom popup (could be done for every player instead of the killedUnit)
    PopupMaterials(killedUnit, 322)
    PopupExperience(killedUnit, math.floor(killedUnit:GetLevel()*5))
end