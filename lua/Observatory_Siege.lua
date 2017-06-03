Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/SaltMixin.lua")

--Remove this from being its own class ya derp
local networkVars = { lastbeacon = "private time" }

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(SaltMixin, networkVars)
    

function Observatory:GetMinRangeAC()
return ObsAutoCCMR   
end
/*
function Observatory:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    if techId == kTechId.SiegeBeacon then
    allowed = allowed and GetSiegeDoorOpen() and not GetSandCastle():GetHasSiegeBeaconed() and not GetSandCastle():GetSDBoolean()
    end
    
    if techId == kTechId.AdvancedBeacon then
    allowed = allowed and not GetSandCastle():GetSDBoolean()
    end
    
    return allowed, canAfford
    
end
*/
function Observatory:GetTechButtons(techId)

--Right now pure overwrites because lazy
local kObservatoryTechButtons = { kTechId.Scan, kTechId.DistressBeacon, kTechId.Detector, kTechId.None,
kTechId.PhaseTech, kTechId.AdvancedBeacon, kTechId.None, kTechId.None }


if GetSandCastle():GetSDBoolean() then
kObservatoryTechButtons[6] = kTechId.None
end

if GetSiegeDoorOpen() and not GetSandCastle():GetHasSiegeBeaconed() and not GetSandCastle():GetSDBoolean() then
kObservatoryTechButtons[7] = kTechId.SiegeBeacon
end

    
    
    if techId == kTechId.RootMenu then
        return kObservatoryTechButtons
    end
    
    return nil
    
end

local function TriggerMarineBeaconEffects(self)

    for index, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
    
        if player:GetIsAlive() and (player:isa("Marine") or player:isa("Exo")) then
            player:TriggerEffects("player_beacon")
        end
    
    end

end
function Observatory:OnVortex()

    if self:GetIsBeaconing() then
        self:CancelDistressBeacon()
    elseif self:GetIsAdvancedBeaconing() then
       self:CancelAdvancedBeacon()
      
    end
    
end
function Observatory:GetSiegePowerOrigin()
local siegelocation = GetSiegeLocation()
local siegepower = GetPowerPointForLocation(siegelocation.name)
 return siegepower:GetOrigin()
end
function Observatory:TriggerSiegeBeacon()

    local success = false
    
    if not self:GetIsBeaconing() then

        self.distressBeaconSound:Start()

        local origin = self:GetSiegePowerOrigin()
        
        if origin then
        
            self.distressBeaconSound:SetOrigin(origin)

            // Beam all faraway players back in a few seconds!
           // self.distressBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
              self.siegeBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
            if Server then
            
                TriggerMarineBeaconEffects(self)
                
                local location = GetLocationForPoint(origin)
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)
                
            end
            
            success = true
        
        end
    
    end
    
    return success, not success
    
end

function Observatory:TriggerAdvancedBeacon()

    local success = false
    
    if not self:GetIsBeaconing() then

        self.distressBeaconSound:Start()

        local origin = self:GetDistressOrigin()
        
        if origin then
        
            self.distressBeaconSound:SetOrigin(origin)

            // Beam all faraway players back in a few seconds!
           // self.distressBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
              self.advancedBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
            if Server then
            
                TriggerMarineBeaconEffects(self)
                
                local location = GetLocationForPoint(self:GetDistressOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)
                
            end
            
            success = true
        
        end
    
    end
    
    return success, not success
    
end
function Observatory:CancelAdvancedBeacon()

    self.advancedBeaconTime = nil
    self.distressBeaconSound:Stop()

end
local function RespawnPlayer(self, player, distressOrigin)

    // Always marine capsule (player could be dead/spectator)
    local extents = HasMixin(player, "Extents") and player:GetExtents() or LookupTechData(kTechId.Marine, kTechDataMaxExtents)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
    local range = Observatory.kDistressBeaconRange
    local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, distressOrigin, 2, range, EntityFilterAll())
    
    if spawnPoint then
    
        if HasMixin(player, "SmoothedRelevancy") then
            player:StartSmoothedRelevancy(spawnPoint)
        end
        
        player:SetOrigin(spawnPoint)
        if player.TriggerBeaconEffects then
            player:TriggerBeaconEffects()
        end

    end
    
    return spawnPoint ~= nil, spawnPoint
    
end
local function GetIsPlayerNearby(self, player, toOrigin)
    return (player:GetOrigin() - toOrigin):GetLength() < Observatory.kDistressBeaconRange
end
local function GetPlayersToBeacon(self, toOrigin)

    local players = { }
    
    for index, player in ipairs(self:GetTeam():GetPlayers()) do
    
        // Don't affect Commanders or Heavies
        if player:isa("Marine") or player:isa("Exo") then
        
            // Don't respawn players that are already nearby.
            if not GetIsPlayerNearby(self, player, toOrigin) then
            
                if player:isa("Exo") then
                    table.insert(players, 1, player)
                else
                    table.insert(players, player)
                end
                
            end
            
        end
        
    end

    return players
    
end

function Observatory:PerformSiegeBeacon()
    GetSandCastle():SetSiegeBeaconed(true)
    self.distressBeaconSound:Stop()
    self.lastbeacon = Shared.GetTime()
    local anyPlayerWasBeaconed = false
    local successfullPositions = {}
    local successfullExoPositions = {}
    local failedPlayers = {}
    
    local distressOrigin =  FindFreeSpace(self:GetSiegePowerOrigin()) 
    if distressOrigin then
    
            // Respawn DeadPlayers
                        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("MarineSpectator")) do
                          if entity:GetTeamNumber() == 1 and not entity:GetIsAlive() then
                          entity:SetCameraDistance(0)
                          entity:GetTeam():ReplaceRespawnPlayer(entity, distressOrigin)
                          end
                        end
                        
                        
        for index, player in ipairs(GetPlayersToBeacon(self, distressOrigin)) do
        
            local success, respawnPoint = RespawnPlayer(self, player, distressOrigin)
            if success then
            
                anyPlayerWasBeaconed = true
                if player:isa("Exo") then
                    table.insert(successfullExoPositions, respawnPoint)
                end
                    
                table.insert(successfullPositions, respawnPoint)
                
            else
                table.insert(failedPlayers, player)
            end
            
        end
        

            
        
    end
    
    local usePositionIndex = 1
    local numPosition = #successfullPositions

    for i = 1, #failedPlayers do
    
        local player = failedPlayers[i]  
    
        if player:isa("Exo") then        
            player:SetOrigin(successfullExoPositions[math.random(1, #successfullExoPositions)])  
            player:SetCameraDistance(0)      
        else
              
            player:SetOrigin(distressOrigin)
            player:SetCameraDistance(0) 
            if player.TriggerBeaconEffects then
                player:TriggerBeaconEffects()
                player:SetCameraDistance(0)  
            end
            
            usePositionIndex = Math.Wrap(usePositionIndex + 1, 1, numPosition)
            
        end    
    
    end

    if anyPlayerWasBeaconed then
        self:TriggerEffects("distress_beacon_complete")
    end
    
end
function Observatory:PerformAdvancedBeacon()

    self.distressBeaconSound:Stop()
    self.lastbeacon = Shared.GetTime()
    local anyPlayerWasBeaconed = false
    local successfullPositions = {}
    local successfullExoPositions = {}
    local failedPlayers = {}
    
    local distressOrigin = self:GetDistressOrigin()
    if distressOrigin then
    
            // Respawn DeadPlayers
                        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("MarineSpectator")) do
                          if entity:GetTeamNumber() == 1 and not entity:GetIsAlive() then
                          entity:SetCameraDistance(0)
                          entity:GetTeam():ReplaceRespawnPlayer(entity, distressOrigin)
                          end
                        end
                        
                        
        for index, player in ipairs(GetPlayersToBeacon(self, distressOrigin)) do
        
            local success, respawnPoint = RespawnPlayer(self, player, distressOrigin)
            if success then
            
                anyPlayerWasBeaconed = true
                if player:isa("Exo") then
                    table.insert(successfullExoPositions, respawnPoint)
                end
                    
                table.insert(successfullPositions, respawnPoint)
                
            else
                table.insert(failedPlayers, player)
            end
            
        end
        

            
        
    end
    
    local usePositionIndex = 1
    local numPosition = #successfullPositions

    for i = 1, #failedPlayers do
    
        local player = failedPlayers[i]  
    
        if player:isa("Exo") then        
            player:SetOrigin(successfullExoPositions[math.random(1, #successfullExoPositions)])  
            player:SetCameraDistance(0)      
        else
              
            player:SetOrigin(successfullPositions[usePositionIndex])
            player:SetCameraDistance(0) 
            if player.TriggerBeaconEffects then
                player:TriggerBeaconEffects()
                player:SetCameraDistance(0)  
            end
            
            usePositionIndex = Math.Wrap(usePositionIndex + 1, 1, numPosition)
            
        end    
    
    end

    if anyPlayerWasBeaconed then
        self:TriggerEffects("distress_beacon_complete")
    end
    
end
function Observatory:SetPowerOff()    
    
    // Cancel distress beacon on power down
    if self:GetIsBeaconing() then    
        self:CancelDistressBeacon()  
        self:CancelAdvancedBeacon()   
    end

end
function Observatory:OnUpdate(deltaTime)
    ScriptActor.OnUpdate(self, deltaTime)

    if self:GetIsBeaconing() and (Shared.GetTime() >= self.distressBeaconTime) then
    
        self:PerformDistressBeacon()
        
        self.distressBeaconTime = nil
            
    elseif self:GetIsAdvancedBeaconing() and (Shared.GetTime() >= self.advancedBeaconTime) then
            self:PerformAdvancedBeacon()
        
        self.advancedBeaconTime = nil
    elseif self:GetIsSiegeBeaconing() and (Shared.GetTime() >= self.siegeBeaconTime) then
            self:PerformSiegeBeacon()
        
        self.siegeBeaconTime = nil
    end
 
end
function Observatory:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if GetIsUnitActive(self) then
    
        if techId == kTechId.DistressBeacon then
            return self:TriggerDistressBeacon()
        end
        if techId == kTechId.SiegeBeacon then
            return self:TriggerSiegeBeacon()
        end
        if techId == kTechId.AdvancedBeacon then
                  if not self:GetIsPowered() then
                   self:SetPowerSurgeDuration(5)
                   end
           return self:TriggerAdvancedBeacon()
         end
        
    end
    
    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    
end
function Observatory:GetIsAdvancedBeaconing()
    return self.advancedBeaconTime ~= nil
end
function Observatory:GetIsSiegeBeaconing()
    return self.siegeBeaconTime ~= nil
end
if Server then

    function Observatory:OnKill(killer, doer, point, direction)

        if self:GetIsBeaconing() then
            self:CancelDistressBeacon()
        elseif self:GetIsAdvancedBeaconing() then
           self:CancelAdvancedBeacon()
        end
        
        ScriptActor.OnKill(self, killer, doer, point, direction)
        
    end
    
end
      local originit = Observatory.OnInitialized
    function Observatory:OnInitialized()
         originit(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, SaltMixin)
    end
    function Observatory:GetMaxLevel()
    return kDefaultLvl
    end
    function Observatory:GetAddXPAmount()
    return kDefaultAddXp
    end
    local function GetRecentlyAdvBeaconed(self)
    local duration =  ( kObsAdvBeaconPowerOff - (self.level/100) * kObsAdvBeaconPowerOff)
    return (self.lastbeacon + duration) > Shared.GetTime()
end
    local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

    function Observatory:GetIsPowered()
        local override = ConditionalValue(GetRecentlyAdvBeaconed(self), false, true)
    return (self.powered or self.powerSurge or GetHasSentryBatteryInRadius(self) ) and override 
end

Shared.LinkClassToMap("Observatory", Observatory.kMapName, networkVars)