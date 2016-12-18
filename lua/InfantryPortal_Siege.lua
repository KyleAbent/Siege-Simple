local origcreate = InfantryPortal.OnInitialized
function InfantryPortal:OnInitialized()

 origcreate(self)
 if not self:isa("InfantryPortalAvoca") then
     
      if Server then
     
      local ip = CreateEntity(InfantryPortalAvoca.kMapName, self:GetOrigin(), 1)
      ip:SetConstructionComplete()
      end
      DestroyEntity(self)
     
 end
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


Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
class 'InfantryPortalAvoca' (InfantryPortal)
InfantryPortalAvoca.kMapName = "infantryportalavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function InfantryPortalAvoca:OnInitialized()
         InfantryPortal.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.InfantryPortal)
    end
        function InfantryPortalAvoca:GetTechId()
         return kTechId.InfantryPortal
    end
    
    function InfantryPortalAvoca:GetMaxLevel()
    return kInfantryPortalMaxLevel
    end
    
    function InfantryPortalAvoca:GetAddXPAmount()
    return kInfantryPortalXPGain
    end

    function InfantryPortalAvoca:GetSpawnTime()
    local levelbonus = ( kMarineRespawnTime - (self.level/100) * kMarineRespawnTime)
    local roundbonus = ( levelbonus - ( ( GetRoundLengthToSiege() / 2 ) /1) * levelbonus)
    local total = roundbonus
   -- Print("InfantryPortalAvoca GetSpawnTime Is: (level bonus is %s, roundbonus is %s)", levelbonus, roundbonus)
    return Clamp(total, 4, kMarineRespawnTime)
end

function InfantryPortalAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.InfantryPortal
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end



Shared.LinkClassToMap("InfantryPortalAvoca", InfantryPortalAvoca.kMapName, networkVars)