function Egg:GetClassToGestate()
    return self:GetMapNameOf()
end

function Egg:GetMapNameOf()
    local techId = self:GetTechId()
    local mapanme = LookupTechData(self:GetGestateTechId(), kTechDataMapName, Skulk.kMapName)
    --Print("mapanme is %s", mapanme)
    
    if techId == kTechId.GorgeEgg then
   --  Print("GorgeEgg")
        return Gorge.kMapName
    elseif techId == kTechId.LerkEgg  then
      --   Print("LerkEgg")
        return Lerk.kMapName
    elseif techId == kTechId.FadeEgg then
       --      Print("FadeEgg")
        return Fade.kMapName
    elseif techId == kTechId.OnosEgg  then
       --      Print("OnosEgg")
        return Onos.kMapName
    end
        return Skulk.kMapName
end

local origcreate = Egg.OnCreate
function Egg:OnCreate()
origcreate(self)

if Server then

local techIds = {}
local tree = GetTechTree(2)

               table.insert(techIds, kTechId.GorgeEgg )
               table.insert(techIds, kTechId.LerkEgg )

            if tree:GetTechAvailable( kTechId.FadeEgg) then
               table.insert(techIds, kTechId.FadeEgg )
            end
            
            if tree:GetTechAvailable( kTechId.OnosEgg) then
               table.insert(techIds, kTechId.OnosEgg )
             end
               
                local random = table.random(techIds)
                local techNode = tree:GetTechNode(random)
           
           if techNode and tree:GetTechAvailable(random) then
                self:SetTechId(random)
                return
          end
end
end


function Egg:SetQueuedPlayerId(playerId)

    self.queuedPlayerId = playerId
    self.empty = false
    
    local playerToSpawn = Shared.GetEntity(playerId)
    assert(playerToSpawn:isa("AlienSpectator"))
    
    playerToSpawn:SetEggId(self:GetId())

    --Refund costs for a non skulk egg
  --  local techId = self:GetIsResearching() and self:GetResearchingId() or self:GetTechId()
  --  if techId ~= kTechId.Egg then
 --       local eggCosts = LookupTechData(techId, kTechDataCostKey, 0)
 --       local team = self:GetTeam()
 --       team:AddTeamResources(eggCosts, true)
 --       self:ClearResearch()
  --      self:SetTechId(kTechId.Egg)
  --  end

    playerToSpawn:SetIsRespawning(true)
    
    if Server then
                
        if playerToSpawn.SetSpectatorMode then
            playerToSpawn:SetSpectatorMode(kSpectatorMode.Following)
        end
        
        playerToSpawn:SetFollowTarget(self)
        
    end
    
end

function Egg:SpawnPlayer(player)

    PROFILE("Egg:SpawnPlayer")

    local queuedPlayer = player
    
    if not queuedPlayer or self.queuedPlayerId ~= nil then
        queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
    end
    
    if queuedPlayer ~= nil then
    
        local queuedPlayer = player
        if not queuedPlayer then
            queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
        end
    
        -- Spawn player on top of egg
        local spawnOrigin = Vector(self:GetOrigin())
        -- Move down to the ground.
        local _, normal = GetSurfaceAndNormalUnderEntity(self)
        if normal.y < 1 then
            spawnOrigin.y = spawnOrigin.y - (self:GetExtents().y / 2) + 1
        else
            spawnOrigin.y = spawnOrigin.y - (self:GetExtents().y / 2)
        end

        local gestationClass = self:GetClassToGestate()
        
        -- We must clear out queuedPlayerId BEFORE calling ReplaceRespawnPlayer
        -- as this will trigger OnEntityChange() which would requeue this player.
        self.queuedPlayerId = nil
        
        local team = queuedPlayer:GetTeam()
        local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetAngles(), gestationClass)                
        player:SetCameraDistance(0)
        player:SetHatched()
        -- It is important that the player was spawned at the spot we specified.
        assert(player:GetOrigin() == spawnOrigin)
        
        if success then
        
            self:TriggerEffects("egg_death")
            DestroyEntity(self) 
            
            
            if player.lastUpgradeList then            
                    player.upgrade1 = player.lastUpgradeList[1] or 1
                    player.upgrade2 = player.lastUpgradeList[2] or 1
                    player.upgrade3 = player.lastUpgradeList[3] or 1
          end
                 
                 
            return true, player
            
        end
            
    end
    
    return false, nil

end





