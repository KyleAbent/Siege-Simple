--Kyle 'Avoca' Abent
function GetSiegeLocation()
--local locations = {}

local hive = nil

 for _, hivey in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
    hive = hivey
 end
 local siegeloc = nil
 if hive ~= nil then
  siegeloc = GetNearest(hive:GetOrigin(), "Location", nil, function(ent) return string.find(ent.name, "siege") or string.find(ent.name, "Siege") end)
 end
 
if siegeloc then return siegeloc end
 return nil
end
local kExtents = Vector(0.4, 0.5, 0.4) -- 0.5 to account for pathing being too high/too low making it hard to palce tunnels
 function GetHasActiveObsInRange(where)

            local obs = GetEntitiesForTeamWithinRange("Observatory", 1, where, kScanRadius)
            if #obs == 0 then return false end
            for i = 1, #obs do
             local ent = obs[i]
             if GetIsUnitActive(ent) then return true end
            end
            
            return false  
                
end
function isPathable(position)
--Gorgetunnelability local function

    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
end
function GetSiegePowerFunc()
  local powers = {}
  for _, loc in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
      if ( string.find(loc.name, "siege") or string.find(loc.name, "Siege") )  and not
       ( string.find(loc.name, "hall") and not  string.find(loc.name, "Hall") ) then 
        Print("Found Siege Power")
        return GetPowerPointForLocation(loc.name)
      end
    end
end
function GetRandomActivePower()
  local powers = {}
  for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if power:GetIsBuilt() and not power:GetIsDisabled() then table.insert(powers,power) end
    end
    return table.random(powers)
end
function GetRandomPowerOrigin()
  local powers = {}
  for _, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
        if power:GetIsBuilt() and not power:GetIsDisabled() then table.insert(powers,power) end
    end
    if #powers == 0 then return end
    return table.random(powers):GetOrigin()
end
 function GetHasCragHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.CragHive then return true end
    end
    return false
end
 function GetHasShiftHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.ShiftHive then return true end
    end
    return false
end
 function GetHasShadeHive()
    for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
       if hive:GetTechId() == kTechId.ShadeHive then return true end
    end
    return false
end
local function GetLocationNameWhere(where)
        local location = GetLocationForPoint(where)
        local locationName = location and location:GetName() or ""
        return locationName
end
function GetWhereIsInSiege(where)
if string.find(GetLocationNameWhere(where), "siege") or string.find(GetLocationNameWhere(where), "Siege") then return true end
return false
end
       function FindArcHiveSpawn(where)    
        for index = 1, 24 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, .5, 48, EntityFilterAll())
           local inradius = false

           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
             inradius = #GetEntitiesWithinRange("Hive", spawnPoint, ARC.kFireRange) >= 1
           end
                -- Print("FindArcHiveSpawn inradius is %s", inradius)
           local sameLocation = spawnPoint ~= nil and GetWhereIsInSiege(spawnPoint)
         --  Print("FindArcHiveSpawn sameLocation is %s", sameLocation)

           if spawnPoint ~= nil and sameLocation and inradius then
           return spawnPoint
           end
       end
          Print("No valid spot found for FindArcHiveSpawn")
           return nil --FindFreeSpace(where, .5, 48)
    end
    
function UpdateTypeOfHive(who)
local hasshade = false
local hasecrag = false
local hasshift = false

             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() and hive:GetIsBuilt() then 
                  if hive:GetTechId() ==  kTechId.CragHive then
                  hasecrag = true
                  elseif hive:GetTechId() ==  kTechId.ShadeHive then
                  hasshade = true
                  elseif hive:GetTechId() ==  kTechId.ShiftHive then
                  hasshift = true
                  end
                end
              end
local techids = {}
if hasecrag == false then table.insert(techids, kTechId.CragHive) end
if hasshade == false then table.insert(techids, kTechId.ShadeHive) end
if hasshift == false then table.insert(techids, kTechId.ShiftHive) end
   
   if #techids == 0 then return end 
    for i = 1, #techids do
      local current = techids[i]
      if who:GetTechId() == techid then
      table.remove(techids, current)
      end
    end
    
    local random = table.random(techids)
    
    who:UpgradeToTechId(random) 
    who:GetTeam():GetTechTree():SetTechChanged()

end

function ChangeArcTo(who, mapname)

if not who or not mapname or not who.rolledout  then return end



                      local entity = CreateEntity(mapname, who:GetOrigin(), 1)
                      entity:SetHealth(who:GetHealth())
                      entity:SetArmor(who:GetArmor())
                      who.rolledout = true
                      if who:GetIsDeployed() then entity:SetDeployed() end
                      DestroyEntity(who)
                     

end
function GetNonBusyArc()
          for _, ARC in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
               if not ARC:GetInAttackMode() and not ARC:isa("AvocaArc") and not ARC:isa("ARCCredit") and ARC.mode ~= ARC.kMode.Moving then
                return ARC
                end
          end
end
 function TresCheck(team, cost)
    if team == 1 then
    return GetGamerules().team1:GetTeamResources() >= cost
    elseif team == 2 then
    return GetGamerules().team2:GetTeamResources() >= cost
    end

end
function GetAllLocationsWithSameName(origin)
local location = GetLocationForPoint(origin)
if not location then return end
local locations = {}
local name = location.name
 for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location.name == name then table.insert(locations, location) end
    end
    return locations
end
function GetImaginator() 
    local entityList = Shared.GetEntitiesWithClassname("Imaginator")
    if entityList:GetSize() > 0 then
                 local imaginator = entityList:GetEntityAtIndex(0) 
                 return imaginator
    end    
    return nil
end
function GetIsTimeUp(timeof, timelimitof)
 local time = Shared.GetTime()
 local boolean = (timeof + timelimitof) < time
 --Print("timeof is %s, timelimitof is %s, time is %s", timeof, timelimitof, time)
 -- if boolean == true then Print("GetTimeIsUp boolean is %s, timelimitof is %s", boolean, timelimitof) end
 return boolean
end
function GetLocationWithMostMixedPlayers()

local team1avgorigin = Vector(0, 0, 0)
local marines = 1
local team2avgorigin = Vector(0, 0, 0)
local aliens = 1
local neutralavgorigin = Vector(0, 0, 0)

            for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
            if marine:GetIsAlive() and not marine:isa("Commander") then marines = marines + 1 team1avgorigin = team1avgorigin + marine:GetOrigin() end
             end
             
           for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do
            if alien:GetIsAlive() and not alien:isa("Commander") then aliens = aliens + 1 team2avgorigin = team2avgorigin + alien:GetOrigin() end 
             end
             --v1.23 added check to make sure room isnt empty
         neutralavgorigin =  team1avgorigin + team2avgorigin
         neutralavgorigin =  neutralavgorigin / (marines+aliens) --better as a table i know
     //    Print("neutralavgorigin is %s", neutralavgorigin)
     local nearest = GetNearestMixin(neutralavgorigin, "Combat", nil, function(ent)  return ent:isa("Player") and ent:GetIsInCombat() end)
    if nearest then
   // Print("nearest is %s", nearest.name)
        return nearest
    end
  return nil
end
function GetIsRoomPowerUp(who)
 local location = GetLocationForPoint(who:GetOrigin())
  if not location then return false end
 local powernode = GetPowerPointForLocation(location.name)
 if powernode and powernode:GetIsBuilt() and not powernode:GetIsDisabled()  then return true end
 return false
end
function GetIsRoomPowerDown(who)
 local location = GetLocationForPoint(who:GetOrigin())
  if not location then return false end
 local powernode = GetPowerPointForLocation(location.name)
 if powernode and powernode:GetIsDisabled()  then return true end
 return false
end
function GetRandomHive() 
   local hives = {}
 for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do 
       table.insert(hives, hive)
end
   if #hives == 0 then return nil end
   
   return table.random(hives)
end
function GetIsOriginInHiveRoom(point)  
 local location = GetLocationForPoint(point)
 local hivelocation = nil
     local hives = GetEntitiesWithinRange("Hive", point, 999)
     if not hives then return false end
     
     for i = 1, #hives do  --better way to do this i know
     local hive = hives[i]
     hivelocation = GetLocationForPoint(hive:GetOrigin())
     break
     end
     
     if location == hivelocation then return true end
     
     return false
     
end
function GetIsPointWithinHiveRadius(point)     

   local hive = GetEntitiesWithinRange("Hive", point, ARC.kFireRange)
   if #hive >= 1 then return true end

   return false
end

function UpdateAliensWeaponsManually() 
 for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        alien:UpdateWeapons() 
end
end
function FindFreeSpace(where, mindistance, maxdistance, infestreq)    
     if not mindistance then mindistance = .5 end
     if not maxdistance then maxdistance = 24 end
        for index = 1, math.random(4,8) do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, where, mindistance, maxdistance, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local wherelocation = GetLocationForPoint(where)
           wherelocation = wherelocation and wherelocation.name or nil
           local sameLocation = spawnPoint ~= nil and locationName == wherelocation
           
           if infestreq then
             sameLocation = sameLocation and GetIsPointOnInfestation(spawnPoint)
           end
        
           if spawnPoint ~= nil and sameLocation   then
              return spawnPoint
           end
       end
--           Print("No valid spot found for FindFreeSpace")
          if infestreq and not GetIsPointOnInfestation(where) then
             if Server then CreateEntity(Cyst.kMapName, FindFreeSpace(where,1, 6),  2) end
             --For now anyway, bite me. Remove later? :X or tres spend. Who knows right now. I wanna see this in action.
          end
          
           return where
end
local function GetLocationName(who)
        local location = GetLocationForPoint(who:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function GetIsInSiege(who)
if string.find(GetLocationName(who), "siege") or string.find(GetLocationName(who), "Siege") then return true end
return false
end
function GetWhereIsSiege(where)
local location = GetLocationForPoint(where)
if string.find(location.name, "siege") or string.find(location.name, "Siege") then return true end
return false
end
local function GetLocationNameWhere(where)
        local location = GetLocationForPoint(where)
        local locationName = location and location:GetName() or ""
        return locationName
end
function GetGameStarted()
     local gamestarted = false
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   return gamestarted
end
function ExploitCheck(who)
local gamestarted = false
if GetSiegeDoorOpen() then return end
 
  local frontdoor = nil
  
  if not GetFrontDoorOpen() then 
      
      if who:isa("Cyst") or who:isa("Clog") and not GetImaginator():GetAlienEnabled() then --Better than getentwithinrange because that returns a table regardless of these specifics of range and origin
            frontdoor = GetNearest(who:GetOrigin(), "FrontDoor", 0, function(ent) return who:GetDistance(ent) <= 12   end)
            frontdoor = frontdoor or GetIsRoomPowerUp(who) -- if it doesnt cause problems with maps. Power shouldn't be up alien side.
            if who:isa("Cyst") and GetIsRoomPowerUp(who) then who:WarningMessage(who) end
     elseif who:isa("TunnelEntrance") then --Better than getentwithinrange because that returns a table regardless of these specifics of range and origin
            frontdoor = GetNearest(who:GetOrigin(), "FrontDoor", 0, function(ent) return who:GetDistance(ent) <= 4   end)
      end
  
      if frontdoor  then who:Kill( )return end
      
  end
   
  if GetIsInSiege(who)  then
    Print("in Siege")
   who:Kill() 
  end

end

function GetSetupConcluded()
return ( GetSandCastle():GetPrimaryLength() > 1 and GetPrimaryDoorOpen() ) or GetFrontDoorOpen()
end
function GetPrimaryDoorOpen()
   return GetSandCastle():GetIsPrimaryOpen()
end
function GetFrontDoorOpen()
   return GetSandCastle():GetFrontOpenBoolean()
end
function GetSiegeDoorOpen()
   local boolean = GetSandCastle():GetSiegeOpenBoolean()
   return boolean
end
function GetRoundLengthToSiege()
    
    local gameRules = nil
        local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then
                 gameRules = entityList:GetEntityAtIndex(0) 
    end    
    
local level = 1
  if not gameRules then return 0.1 end
 if not gameRules:GetGameStarted() then 
   return 0.1 
 end
  if GetSiegeDoorOpen() then
   return 1
  end 
      local roundlength =   Shared.GetTime()   - ( gameRules:GetStartTime()  )
      level = math.round(roundlength/  kSiegeTimer, 2)
     -- Print("GetRoundLengthToSiege = %s", level)
       return level 
end

function GetPayloadPercent() 
    local entityList = Shared.GetEntitiesWithClassname("AvocaArc")
    if entityList:GetSize() > 0 then
                 local payload = entityList:GetEntityAtIndex(0) 
                 local furthestgoal = payload:GetHighestWaypoint()
                 local speed = payload:GetMoveSpeed()
                 local isReverse = speed < 1
                 local distance =  GetPathDistance(payload:GetOrigin(), furthestgoal:GetOrigin()) 
                 local time = math.round(distance / speed, 1)
                 //Print("Distance is %s, speed is %s, time is %s", distance, speed, time)
                 return time, speed, isReverse
    end    
    return nil
end
function GetSiegeDoor() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SiegeDoor")
    if entityList:GetSize() > 0 then
                 local siegedoor = entityList:GetEntityAtIndex(0) 
                 return siegedoor
    end    
    return nil
end
function GetSandCastle() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                 return sandcastle
    end    
    return nil
end
function GetRandomTechPoint()
       local techs = {}
 for _, tech in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do 
       table.insert(techs, tech)
end
   if #techs == 0 then return nil end
   
   return table.random(techs)
end
function GetNearestMixin(origin, mixinType, teamNumber, filterFunc)
    assert(type(mixinType) == "string")
    local nearest = nil
    local nearestDistance = 0
    for index, ent in ientitylist(Shared.GetEntitiesWithTag(mixinType)) do
        if not filterFunc or filterFunc(ent) then
            if teamNumber == nil or (teamNumber == ent:GetTeamNumber()) then
                local distance = (ent:GetOrigin() - origin):GetLength()
                if nearest == nil or distance < nearestDistance then
                    nearest = ent
                    nearestDistance = distance
                end
            end
        end
    end
    return nearest
end