function InfantryPortal:GetMinRangeAC()
return IPAutoCCMR  
end
function InfantryPortal:CheckSpaceAboveForSpawn()

    local startPoint = self:GetOrigin() 
    local endPoint = startPoint + Vector(0.35, 0.95, 0.35)
    
    return GetWallBetween(startPoint, endPoint, self)
    
end


local function StopSpinning(self)

    self:TriggerEffects("infantry_portal_stop_spin")
    self.timeSpinUpStarted = nil
    
end

if Server then

// Spawn player on top of IP. Returns true if it was able to, false if way was blocked.
local function SpawnPlayer(self)

    if self.queuedPlayerId ~= Entity.invalidId then
    
        local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
        local team = queuedPlayer:GetTeam()
        
        // Spawn player on top of IP
        local spawnOrigin = self:GetAttachPointOrigin("spawn_point")
        spawnOrigin = ConditionalValue(self:CheckSpaceAboveForSpawn(), FindFreeSpace(self:GetOrigin(), 1, 4), spawnOrigin)
        local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetAngles())
        if success then

            player:SetCameraDistance(0)
            
            if HasMixin( player, "Controller" ) and HasMixin( player, "AFKMixin" ) then
                
                if player:GetAFKTime() > self:GetSpawnTime() - 1 then
                    
                    player:DisableGroundMove(0.1)
                    player:SetVelocity( Vector( GetSign( math.random() - 0.5) * 2.25, 3, GetSign( math.random() - 0.5 ) * 2.25 ) )
                    
                end
                
            end
            
            self.queuedPlayerId = Entity.invalidId
            self.queuedPlayerStartTime = nil
            
            player:ProcessRallyOrder(self)

            self:TriggerEffects("infantry_portal_spawn")            
            
            return true
            
        else
            Print("Warning: Infantry Portal failed to spawn the player")
        end
        
    end
    
    return false

end


    function InfantryPortal:FinishSpawn()
    
        SpawnPlayer(self)
        StopSpinning(self)
        self.timeSpinUpStarted = nil
end

end


    function InfantryPortal:GetSpawnTime()
    local roundbonus =  ( ( GetRoundLengthToSiege() / 2 ) /1) 
    local total = roundbonus
   -- Print("InfantryPortalAvoca GetSpawnTime Is: (level bonus is %s, roundbonus is %s)", levelbonus, roundbonus)
    return Clamp(total, 6, kMarineRespawnTime)
end
