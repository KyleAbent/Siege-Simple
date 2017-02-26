local networkVars = {lastredeemorrebirthtime = "time", canredeemorrebirth = "boolean",  primaled = "boolean",  primaledID = "entityid",} 
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
      self.primaled = false
      self.primaledID = Entity.invalidI 

end
local orig_Alien_OnInitialized = Alien.OnInitialized
function Alien:OnInitialized()
    orig_Alien_OnInitialized(self)
     if not self:isa("Embryo") then
      self:AddTimedCallback(Alien.UpdateHealthAmountManual, .5) 
      self:AddTimedCallback(Alien.UpdateArmorAmountManual, .5) 
   end
     self:AddTimedCallback(Alien.CheckRedemptionTimer, .5) 

end
local function CheckPrimalScream(self)
	self.primaled = self.primalGiveTime - Shared.GetTime() > 0
	return self.primaled
end
if Server then

    function Alien:PrimalScream(duration)
        if not self.primaled then
			self:AddTimedCallback(CheckPrimalScream, duration)
		end
        self.primaled = true
        self.primalGiveTime = Shared.GetTime() + duration
    end

end
function Alien:GetHasPrimalScream()
    return self.primaled
end
function Alien:CancelPrimal()

    if self.primalGiveTime > Shared.GetTime() or self:GetIsOnFire() then 
        self.primalGiveTime = Shared.GetTime()
        self.primaledID = Entity.invalidI
    end
    
end
--Hmm? Overwrite? My palms are open, not clenched.. Idk about my asshole, though.
function Alien:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)
    
    local attackSpeed = self:GetIsEnzymed() and kEnzymeAttackSpeed or 1
    attackSpeed = attackSpeed * ( self.electrified and kElectrifiedAttackSpeed or 1 )
    attackSpeed = attackSpeed + ( self:GetHasPrimalScream() and kPrimalScreamROFIncrease or 0)
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeedTable.attackSpeed
        
    end
    
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
    
end
function Alien:CheckRedemptionTimer()
    if  GetHasRedemptionUpgrade(self) then 
        if Server then
        self:AddTimedCallback(Alien.RedemptionTimer, 3) 
        end
       end
       return false
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

function Alien:CreditBuy(techId)
        local cost = LookupTechData(techId, kTechDataCostKey, 0)
         self:AddResources(cost)
        local upgradetable = {}
        local upgrades = Player.lastUpgradeList
        if upgrades and #upgrades > 0 then
            table.insert(upgradetable, upgrades)
        end
        
        table.insert(upgradetable, techId)
        self:ProcessBuyAction(upgradetable, true)
        self:AddResources(cost)
end

function Alien:RefreshTechsManually()
         local t4 = ( self.GetTierFourTechId and self:GetTierFourTechId() ) or nil
UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), t4 )
end


end

if Server then

function Alien:RedemptionTimer()
           local threshold =   math.random(kRedemptionEHPThresholdMin,kRedemptionEHPThresholdMax)  / 100
              --Print("threshold is %s", threshold)
              local scalar = self:GetHealthScalar()
               if self:GetHasUpgrade(kTechId.Redemption) and scalar <= threshold  then
                 self.canredeemorrebirth = Shared.GetTime() > self.lastredeemorrebirthtime  + self:GetRedemptionCoolDown()
                 --Print("scalar is %s threshold is %s", scalar, threshold)
                 if self.canredeemorrebirth then
                 self.canredeemorrebirth = false
                 self:AddTimedCallback(Alien.RedemAlienToHive, math.random(1,4) ) 
                 end      
        end
          return true
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
     if self:GetEligableForRebirth() then
        self:TeleportToHive()
         self:OnRedeem(self:GetClient():GetControllingPlayer())
        self.lastredeemorrebirthtime = Shared:GetTime()
     end
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

if Client then
Alien.kPrimaledViewMaterialName = "cinematics/vfx_materials/primal_view.material"
Alien.kPrimaledThirdpersonMaterialName = "cinematics/vfx_materials/primal.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/primal_view.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/primal.surface_shader")

local kEnzymeEffectInterval = 0.2


function Alien:UpdatePrimalEffect(isLocal)
    if self.primaledClient ~= self.primaled then

        if isLocal then
        
            local viewModel= nil        
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()  
            end
                
            if viewModel then
   
                if self.primaled then
                    self.primaledViewMaterial = AddMaterial(viewModel, Alien.kPrimaledViewMaterialName)
                else
                
                    if RemoveMaterial(viewModel, self.primaledViewMaterial) then
                        self.primaledViewMaterial = nil
                    end
  
                end
            
            end
        
        end
        
        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then
        
            if self.primaled then
                self.primaledMaterial = AddMaterial(thirdpersonModel, Alien.kPrimaledThirdpersonMaterialName)
            else
            
                if RemoveMaterial(thirdpersonModel, self.primaledMaterial) then
                    self.primaledMaterial = nil
                end

            end
        
        end
        
        self.primaledClient = self.primaled
        
    end

    // update cinemtics
    if self.primaled then

        if not self.lastprimaledEffect or self.lastprimaledEffect + kEnzymeEffectInterval < Shared.GetTime() then
        
            self:TriggerEffects("enzymed")
            self.lastprimaledEffect = Shared.GetTime()
        
        end

    end 

end

local origcupdate = Alien.UpdateClientEffects
function Alien:UpdateClientEffects(deltaTime, isLocal)
     self:UpdatePrimalEffect(isLocal)
     origcupdate(self, deltaTime,isLocal)
end

end//client

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars)

