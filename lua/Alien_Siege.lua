local networkVars = {lastredeemorrebirthtime = "time", canredeemorrebirth = "boolean",} 
local orig_Alien_OnCreate = Alien.OnCreate
    function Alien:SlapPlayer()
     self:SetVelocity(  self:GetVelocity() + Vector(math.random(100,900),math.random(100,900),math.random(100,900)  ) )
    end
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    if Server then
        local t4 = ( self.GetTierFourTechId and self:GetTierFourTechId() ) or nil
        self:AddTimedCallback(function() UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), t4) end, .8) 
    end
     self.lastredeemorrebirthtime = 0 --i would like to make a new alien class with custom networkvars like this some day :/
     self.canredeemorrebirth = true

end
local orig_Alien_OnInitialized = Alien.OnInitialized
function Alien:OnInitialized()
    orig_Alien_OnInitialized(self)
     if not self:isa("Embryo") then
      self:AddTimedCallback(Alien.UpdateHealthAmountManual, .5) 
      self:AddTimedCallback(Alien.UpdateArmorAmountManual, .5) 
   end
end
function Alien:GetRebirthLength()
return 0
end
function Alien:GetRedemptionCoolDown()
return 0
end
function Alien:UpdateArmorAmountManual(carapaceLevel)
    local teamInfo = GetTeamInfoEntity(2)
          if teamInfo then
      local bioMassLevel = teamInfo:GetBioMassLevel()
 --default, just manual. Outdated if modified... 
    local level = GetHasCarapaceUpgrade(self) and carapaceLevel or 0
    local newMaxArmor = (level / 3) * (self:GetArmorFullyUpgradedAmount() - self:GetBaseArmor()) + self:GetBaseArmor()

    if newMaxArmor ~= self.maxArmor then

        local armorPercent = self.maxArmor > 0 and self.armor/self.maxArmor or 0
        self.maxArmor = newMaxArmor
        self:SetArmor(self.maxArmor * armorPercent)
    
    end
    end
  return false
end

function Alien:UpdateHealthAmountManual(bioMassLevel, maxLevel)
    local teamInfo = GetTeamInfoEntity(2)
          if teamInfo then
      local bioMassLevel = teamInfo:GetBioMassLevel()
 ---default w/ mod of thick skin. I know this is not perfect because the orig can be modified and make this one outdated. But im not worried. 
    local level = math.max(0, bioMassLevel - 1)
    local newMaxHealth = self:GetBaseHealth() + level * self:GetHealthPerBioMass()
    newMaxHealth =  ConditionalValue(self:GetHasUpgrade(kTechId.ThickenedSkin), newMaxHealth * 1.10, newMaxHealth)
   -- Print(" newMaxHealth is %s", newMaxHealth)
        self:AdjustMaxHealth(newMaxHealth)
        self:SetMaxHealth(newMaxHealth)
    end
   return false
end

function Alien:UpdateArmorAmount(carapaceLevel)

return
--why onupdate? 

end

function Alien:UpdateHealthAmount(bioMassLevel, maxLevel)

return
--why onupdate?

end
if Server then

function Alien:CreditBuy(Class)

        local upgradetable = {}
        local upgrades = Player.lastUpgradeList
        if upgrades and #upgrades > 0 then
            table.insert(upgradetable, upgrades)
        end
        local class = nil
        
        if Class == Gorge then
        class = kTechId.Gorge
        elseif Class == Lerk then
        class = kTechId.Lerk
        elseif Class == Fade then
        class = kTechId.Fade
        elseif Class == Onos then
        class = kTechId.Onos
        end
        
        table.insert(upgradetable, class)
        self:ProcessBuyAction(upgradetable, true)
        
end

function Alien:RefreshTechsManually()
         local t4 = ( self.GetTierFourTechId and self:GetTierFourTechId() ) or nil
UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), t4 )
end


end

if Server then

local origmove = Alien.OnProcessMove

function Alien:OnProcessMove(input)

origmove(self, input)

           self.canredeemorrebirth = Shared.GetTime() > self.lastredeemorrebirthtime  + kRedemptionCooldown 
 
        if  (GetHasRedemptionUpgrade(self) and self:GetHealthScalar() <= kRedemptionEHPThreshold ) then
                 if self.canredeemorrebirth then
                 self.canredeemorrebirth = false
                 self:AddTimedCallback(Alien.RedemAlienToHive, math.random(4,8) ) 
                 end         
        end

end
local function GetRelocationHive(usedhive, origin, teamnumber)
    local hives = GetEntitiesForTeam("Hive", teamnumber)
	local selectedhive
	
    for i, hive in ipairs(hives) do
			selectedhive = hive
	end
	return selectedhive
end
function Alien:TeleportToHive(usedhive)
	local selectedhive = GetRelocationHive(usedhive, self:GetOrigin(), self:GetTeamNumber())
    local success = false
    if selectedhive then 
            local position = table.random(selectedhive.eggSpawnPoints)
                SpawnPlayerAtPoint(self, position)
//               Shared.Message("LOG - %s SuccessFully Redeemed", self:GetClient():GetControllingPlayer():GetUserId() )
                success = true
    end

end
function Alien:TriggerRebirth()


        local position = self:GetOrigin()
        local trace = Shared.TraceRay(position, position + Vector(0, -0.5, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
        
            // Check for room
            local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
            local newLifeFormTechId = self:GetTechId() /// :P
            local upgradeManager = AlienUpgradeManager()
            upgradeManager:Populate(self)
             upgradeManager:AddUpgrade(lifeFormTechId)
            local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
            local physicsMask = PhysicsMask.Evolve
            
            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
             local evolveAllowed = self:GetIsOnGround() and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)

            local roomAfter
            local spawnPoint
       
            // If not on the ground for the buy action, attempt to automatically
            // put the player on the ground in an area with enough room for the new Alien.
            if not evolveAllowed then
            
                for index = 1, 100 do
                
                    spawnPoint = GetRandomSpawnForCapsule(eggExtents.y, math.max(eggExtents.x, eggExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
  
                    if spawnPoint then
                        self:SetOrigin(spawnPoint)
                        position = spawnPoint
                        break 
                    end
                    
                end
            end   
            
            if not GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self:GetOrigin() + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterOne(self)) then
           
                for index = 1, 100 do

                    roomAfter = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                    
                    if roomAfter then
                        evolveAllowed = true
                        break
                    end

                end
                
            else
                roomAfter = position
                evolveAllowed = true
            end
            
            if evolveAllowed and roomAfter ~= nil then

                local newPlayer = self:Replace(Embryo.kMapName)
                position.y = position.y + Embryo.kEvolveSpawnOffset
                newPlayer:SetOrigin(position)
                // Clear angles, in case we were wall-walking or doing some crazy alien thing
                local angles = Angles(self:GetViewAngles())
                angles.roll = 0.0
                angles.pitch = 0.0
                newPlayer:SetOriginalAngles(angles)
                newPlayer:SetValidSpawnPoint(roomAfter)
                
                // Eliminate velocity so that we don't slide or jump as an egg
                newPlayer:SetVelocity(Vector(0, 0, 0))                
                newPlayer:DropToFloor()
                
               newPlayer:TriggerRebirthCountDown(newPlayer:GetClient():GetControllingPlayer())
               newPlayer:SetGestationData(upgradeManager:GetUpgrades(), newLifeFormTechId, 10, 10) //Skulk to X 
               newPlayer.gestationTime = self:GetRebirthLength()
               
               //Spawn protective boneshield    
                success = true
                
                
            else

               self:TeleportToHive()

            end    
            
    
    
    
end
function Alien:GetEligableForRebirth()
return Shared.GetTime() > self.lastredeemorrebirthtime  + self:GetRedemptionCoolDown() 
end
local function SingleHallucination(self, player)
  --Why a cloud ?
                local alien = player
                local newAlienExtents = LookupTechData(alien:GetTechId(), kTechDataMaxExtents)
                local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(newAlienExtents) 
                
                local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, alien:GetModelOrigin(), 0.5, 5)
                
                if spawnPoint then

                    local hallucinatedPlayer = CreateEntity(alien:GetMapName(), spawnPoint, self:GetTeamNumber())
                    hallucinatedPlayer.isHallucination = true
                    InitMixin(hallucinatedPlayer, PlayerHallucinationMixin)                
                    InitMixin(hallucinatedPlayer, SoftTargetMixin)                
                    InitMixin(hallucinatedPlayer, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance }) 

                    hallucinatedPlayer:SetName(alien:GetName())
                    hallucinatedPlayer:SetHallucinatedClientIndex(alien:GetClientIndex())
                end
                    


end
function Alien:OnRedeem(player)

   --self:GiveItem(HallucinationCloud.kMapName)
   SingleHallucination(self, player)
self:AddScore(1, 0, false)
   self:TriggerRedeemCountDown(player)
end
function Alien:TriggerRedeemCountDown(player)

end
function Alien:TriggerRebirthCountDown(player)

end
function Alien:RedemAlienToHive()
        self:TeleportToHive()
         self:OnRedeem(self:GetClient():GetControllingPlayer())
        self.lastredeemorrebirthtime = Shared:GetTime()
        return false
end
local origderp = Alien.CopyPlayerDataFrom

function Alien:CopyPlayerDataFrom(player)
 origderp(self, player)
    if GetHasRebirthUpgrade(self) and self.canredeemorrebirth then
      self:TriggerRebirthCountDown(self:GetClient():GetControllingPlayer())
     end

end


end //server
Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars)

