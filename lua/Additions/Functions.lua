--Kyle 'Avoca' Abent
function UpdateAliensWeaponsManually() ///Seriously this makes more sense than spamming some complicated formula every 0.5 seconds no?
 for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        alien:RefreshTechsManually() 
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
        if frontdoor  then who:Kill( )return end
  end
  
    if who:isa("TunnelEntrance") then --Better than getentwithinrange because that returns a table regardless of these specifics of range and origin
     local frontdoor = GetNearest(who:GetOrigin(), "FrontDoor", 0, function(ent) return who:GetDistance(ent) <= 3 and(  ent.GetIsLocked and ent:GetIsLocked() )  end)
        if frontdoor  then who:Kill( )return end
  end
  
  if GetIsInSiege(who)  then
     -- Print("Player is in siege!")
    if not GetSandCastle():GetIsSiegeOpen() then who:Kill() end
  end

end
function AddSiegeTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                sandcastle:AddSiegeTime(seconds) 
    end    
end
function AddFrontTime(seconds)
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                sandcastle:SendNotification(seconds)
                sandcastle:AddTime(seconds) 
    end    
end
function GetSideDoorOpen()
   return GetSandCastle():GetIsSideOpen()
end
function GetFrontDoorOpen()
   return GetSandCastle():GetIsFrontOpen()
end
function GetSiegeDoorOpen()
   return GetSandCastle():GetIsSiegeOpen()
end
function GetSandCastle() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                 return sandcastle
    end    
    return nil
end
function GetIsPointInMarineBase(where)    
    local cclocation = nil
           for _, cc in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        cclocation = GetLocationForPoint(cc:GetOrigin())
        cclocation = cclocation.name
             break
          end
    
    local pointlocation = GetLocationForPoint(where)
          pointlocation = pointlocation and pointlocation.name or nil
          
          return pointlocation == cclocation
    
end
function GetIsPointInAlienBase(where)    
    local cclocation = nil
           for _, cc in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
        cclocation = GetLocationForPoint(cc:GetOrigin())
        cclocation = cclocation.name
             break
          end
    
    local pointlocation = GetLocationForPoint(where)
          pointlocation = pointlocation and pointlocation.name or nil
          
          return pointlocation == cclocation
    
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