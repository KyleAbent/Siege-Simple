--Kyle 'Avoca' Abent
function GetBallForPlayerOwner(who)
            for _, ball in ientitylist(Shared.GetEntitiesWithClassname("Ball")) do
                 if ball:GetParent() == who then --not owner
                 return ball
                 end
    end    
    return nil
end
function GetIsTimeUp(timeof, timelimitof)
 local time = Shared.GetTime()
 local boolean = (timeof + timelimitof) <= time
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

end
function GetIsRoomPowerDown(who)
 local location = GetLocationForPoint(who:GetOrigin())
  if not location then return false end
 local powernode = GetPowerPointForLocation(location.name)
 if powernode and powernode:GetIsDisabled()  then return true end
 return false
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
function FindFreeSpace(where, mindistance, maxdistance)    
     if not mindistance then mindistance = .5 end
     if not maxdistance then maxdistance = 24 end
        for index = 1, 1 do
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
        
           if spawnPoint ~= nil and sameLocation   then
              return spawnPoint
           end
       end
--           Print("No valid spot found for FindFreeSpace")
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
--Print("Exploit check")
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end

 if not gamestarted then return end 
 
 
  if who:isa("Cyst") then --Better than getentwithinrange because that returns a table regardless of these specifics of range and origin
     local frontdoor = GetNearest(who:GetOrigin(), "FrontDoor", 0, function(ent) return who:GetDistance(ent) <= 12 and(  ent.GetIsLocked and ent:GetIsLocked() )  end)
     local sidedoor = GetNearest(who:GetOrigin(), "SideDoor", 0, function(ent) return who:GetDistance(ent) <= 12 and(  ent.GetIsLocked and ent:GetIsLocked() )  end)
        if sidedoor or frontdoor then who:Kill() return end
  end
  
    if who:isa("TunnelEntrance") then --Better than getentwithinrange because that returns a table regardless of these specifics of range and origin
     local frontdoor = GetNearest(who:GetOrigin(), "FrontDoor", 0, function(ent) return who:GetDistance(ent) <= 4 and(  ent.GetIsLocked and ent:GetIsLocked() )  end)
        if frontdoor  then who:Kill( )return end
  end
  
  if GetIsInSiege(who)  then
     -- Print("Player is in siege!")
    if not GetSandCastle():GetIsSiegeOpen() then who:Kill() end
  end

end

function GetSetupConcluded()
return ( GetSandCastle():GetPrimaryLength() > 1 and GetPrimaryDoorOpen() ) or GetFrontDoorOpen()
end
function GetPrimaryDoorOpen()
   return GetSandCastle():GetIsPrimaryOpen()
end
function GetFrontDoorOpen()
   return GetSandCastle():GetIsFrontOpen()
end
function GetSiegeDoorOpen()
   return GetSandCastle():GetIsSiegeOpen()
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
      local roundlength =   Shared.GetTime()   - ( gameRules:GetStartTime() + kFrontTimer )
                            --Don't count the setup duration 
      level = math.round(roundlength/  kSiegeTimer, 2)
     -- Print("GetRoundLengthToSiege = %s", level)
       return level 
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
    local entityList = Shared.GetEntitiesWithClassname("TechPoint")
    if entityList:GetSize() > 0 then
                 local commandstation = entityList:GetEntityAtIndex(0) 
                 return commandstation
    end    
    return nil
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