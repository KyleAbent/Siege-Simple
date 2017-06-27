    function Egg:GetMaxLevel()
    return 100
    end


function Egg:GetMax()

    local orig = kMatureEggHealth
    local bySiege = orig * 2
    local val = Clamp(orig * (GetRoundLengthToSiege()/1) + orig, orig, bySiege)
    self.level = self:GetMaxLevel() * GetRoundLengthToSiege()
 --  self.level = self.level * 
 
  --  local byFive = val * 2
    --local builttime = Clamp(Shared.GetTime() -  self.builtTime, 0, 300)
 --   val = Clamp(val * (builttime/300) + val, val, byFive)
    --self.level = (self.level * 2) * builttime
     --Print("builttime is %s, val is %s", builttime, val)
    return val

end 

/*
function Egg:GetMaxA()
    local orig = kMatureEggArmor
    local bySiege = orig * 2
    return Clamp(bySiege * GetRoundLengthToSiege(), orig, bySiege)
end 
*/

function Egg:ArtificialLeveling()
  if Server and GetIsTimeUp(self.timeMaturityLastUpdate, 8 )  then
   self:AdjustMaxHealth(self:GetMax())
  -- self:AdjustMaxArmor(self:GetMaxA())
   end
end




function Egg:GetClassToGestate()
    return self:GetMapNameOf()
end

function Egg:DelayedActivation()
   self.Auto = true
      self:AddTimedCallback(Egg.ResearchSpecifics, 8 )
end

function Egg:ResearchSpecifics()
     
      local techIds = {}
         local tree = GetTechTree(2)
         
       if self:GetTechId() == kTechId.Egg  then
       table.insert(techIds, kTechId.GorgeEgg )
       elseif self:GetTechId() == kTechId.GorgeEgg then
               table.insert(techIds, kTechId.LerkEgg )
        elseif self:GetTechId() == kTechId.LerkEgg and  GetHasTech(self, kTechId.BioMassNine) then
               table.insert(techIds, kTechId.FadeEgg )
         elseif  self:GetTechId() == kTechId.FadeEgg   and GetHasTech(self, kTechId.BioMassNine) then
               table.insert(techIds, kTechId.OnosEgg )
             end
               
                local random = table.random(techIds)
                local techNode = tree:GetTechNode(random)
           
           if techNode then
                self:SetResearching(techNode, self)
                self.Auto = false
          end
          
      
      return false
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



function Egg:SetQueuedPlayerId(playerId)

    self.queuedPlayerId = playerId
    self.empty = false
    
    local playerToSpawn = Shared.GetEntity(playerId)
    assert(playerToSpawn:isa("AlienSpectator"))
    
    playerToSpawn:SetEggId(self:GetId())

 -----------------This removed
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
            
        -------------------This added        
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

/*
if Server then
local orig = Egg.OnResearchComplete
function Egg:OnResearchComplete(researchId)


   self:AdjustMaxHealth(self:GetMaxHealth() * 1.10)
   
   orig(self, researchId)

end 

end

*/


