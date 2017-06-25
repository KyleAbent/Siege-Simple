Script.Load("lua/DefaultOverwrites/CloakableMixin.lua")

function GetAlienCatalystTimeAmount(baseTime, entity)

        local catalystTime = 1 * baseTime * (1 + kNutrientMistPercentageIncrease/100)
        return catalystTime
    
end


/*
local origdamgebytype = GetDamageByType
function GetDamageByType(target, attacker, doer, damage, damageType, hitPoint, weapon)
    
    if not GetSiegeDoorOpen() and attacker and attacker:isa("Player") and target and target:isa("Player") and doer then
       if doer:isa("Minigun") then
              local dist = Clamp(attacker:GetDistance(target), 1, kMinigunDamage)
              damage = Clamp( (kMinigunDamage - dist) + 6, kMinigunDamage -4, kMinigunDamage)
              if Client then Print("Damage is %s", damage) end
       elseif doer:isa("HeavyMachineGun") then
              local dist = Clamp(attacker:GetDistance(target), 1, kMinigunDamage)
              damage = Clamp( (kHeavyMachineGunDamage - dist) + 8, kHeavyMachineGunDamage -2, kHeavyMachineGunDamage)
               if Client then Print("Damage is %s", damage) end
       end   
    end 
        return origdamgebytype(target, attacker, doer, damage, damageType, hitPoint, weapon)
end
*/
function ConstructMixin:OnProcessMove(input)
    Log("%s: Called OnProcessMove???", self:GetClassName())
end


function BotTeamController:NeededCommanders()
    return 0
end
/*
function ConstructMixin:GetTotalConstructionTime()
    local time = LookupTechData(self:GetTechId(), kTechDataBuildTime, kDefaultBuildTime)
   -- Print("time is %s", time)
    if not GetSetupConcluded() then time = time * 0.7 end
    -- Print("time is %s", time)
    return time
end
*/
function GetIsCloseToMenuStructure(player)
    
    local ptlabs = GetEntitiesForTeamWithinRange("PrototypeLab", player:GetTeamNumber(), player:GetOrigin(), PrototypeLab.kResupplyUseRange)
    local armories = GetEntitiesForTeamWithinRange("Armory", player:GetTeamNumber(), player:GetOrigin(), Armory.kResupplyUseRange)
    local armslabs = GetEntitiesForTeamWithinRange("ArmsLab", player:GetTeamNumber(), player:GetOrigin(), 2.5)
    return (ptlabs and #ptlabs > 0) or (armories and #armories > 0) or (armslabs and #armslabs >0)

end

function Shell:GetMinRangeAC()
return  9999   
end
function Spur:GetMinRangeAC()
return  9999   
end
function Veil:GetMinRangeAC()
return  9999   
end
function Armory:GetMinRangeAC()
return ArmoryAutoCCMR 
end
function ArmsLab:GetMinRangeAC()
return ArmsLabAutoCCMR 
end
function Clog:GetMinRangeAC()
return  kCystRedeployRange * .7      
end
function CommandStation:GetMinRangeAC()
return math.random(16,42)      
end

if Server then

    local function UpdateLifetime(self, deltaTime)
    
        local lifeTime = self.lifeTime - deltaTime or nil
        if lifeTime <= 0 then
            DestroyEntity(self)
        else
            self.lifeTime = lifeTime
        end
     end   
        
    function ParticleEffect:OnUpdate(deltaTime)
        UpdateLifetime(self, deltaTime)
    end
    

end

Script.Load("lua/Modifications/ReallyNow.lua")
/*
local kUmbraModifier = {}
kUmbraModifier["Shotgun"] = kUmbraShotgunModifier
kUmbraModifier["Rifle"] = kUmbraBulletModifier
kUmbraModifier["HeavyMachineGun"] = kUmbraBulletModifier
kUmbraModifier["Pistol"] = kUmbraBulletModifier
kUmbraModifier["Sentry"] = kUmbraBulletModifier
kUmbraModifier["Minigun"] = kUmbraMinigunModifier
kUmbraModifier["Railgun"] = kUmbraRailgunModifier
kUmbraModifier["Grenade"] = kUmbraGrenadeModifer

function UmbraMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if self:GetHasUmbra() then
    
        local modifier = 1
        if doer then        
            modifier = kUmbraModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end
*/
if Client then 

local originalGUISetColorOf = GUIItem.SetColor
function GUIItem:SetColor(color)
	if color then
		originalGUISetColorOf(self, color)
	else
		originalGUISetColorOf(self, Color(1,1,0,1)) 
	end
end

end

function GetValidTargetInWarmUp(target)
    return not target:isa("CommandStructure")
end

local origkill = LiveMixin.Kill
function LiveMixin:Kill(attacker, doer, point, direction)
  if self:GetIsAlive() and self:GetCanDie() then
          ---Rebirth
          
         if self:isa("Alien") then
         
         /*
          if GetHasRebirthUpgrade(self) and self:GetEligableForRebirth() then
                if Server then 
                    if attacker and attacker:isa("Player")  then 
                      local points = self:GetPointValue()
                       attacker:AddScore(points)
                     end 
                    end
                self:TriggerRebirth()
                return
                end
             */   
             
             if doer and doer:isa("XenocideLeap") and Server and GetHasTech(doer, kTechId.SkulkXenoRupture) and Server then
              CreateEntity(Rupture.kMapName, point, 2)
             end
             
         end
            
            --Hunger
            /*
      if self:GetTeamNumber() == 1 then 
         if self:isa("Player")  then
              if attacker and attacker:isa("Alien") and attacker:isa("Player") and GetHasHungerUpgrade(attacker) then
                  local duration = 6
                     if attacker:isa("Onos") then
                       duration = duration * .7
                       end
                    attacker:TriggerEnzyme(duration)

          attacker:AddEnergy(attacker:GetMaxEnergy() * .10 )
          attacker:AddHealth(attacker:GetHealth() * (10/100))
        end
      elseif ( HasMixin(self, "Construct") or self:isa("ARC") or self:isa("MAC") ) and attacker and attacker:isa("Player") then 
              if GetHasHungerUpgrade(attacker) and attacker:isa("Gorge") and doer:isa("DotMarker") then 
                        attacker:TriggerEnzyme(5)
                        attacker:AddEnergy(attacker:GetMaxEnergy() * .10)
               end
          end
     end 
     */
            
            
   end     
return origkill(self, attacker, doer, point, direction)
end
          ---DirectorBot
    function ForceEvenTeams_AssignPlayer( player, team )
      if not player:isa("AvocaSpectator") then
        player:SetCameraDistance(0)
        GetGamerules():JoinTeam(player, team, true)
        end
    end


if Server then



local origscore = ScoringMixin.AddScore

function ScoringMixin:AddScore(points, res, wasKill)
   if points ~= nil and wasKill and self:isa("Alien") then points = math.round(points * 1.30 + points, 1) end
   origscore(self, points, res, wasKill)
end

end

function Gamerules_GetDamageMultiplier()

    if Server  then
        return GetGamerules():GetDamageMultiplier()
    end

    return 1
    
end

function LeapMixin:GetHasSecondary(player)
    return GetHasTech(player, kTechId.Leap)
end
function StompMixin:GetHasSecondary(player)
    return  GetHasTech(player, kTechId.Stomp)
end


local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or GetHasSentryBatteryInRadius(self)
end

if Server then

/*
 function MaturityMixin:OnMaturityUpdate(deltaTime)
 PROFILE("MaturityMixin:OnMaturityUpdate")
   Print("Maturity update")
 -- return false
  end
  */
    function GetCheckNotSiege(techId, origin, normal, commander)
         return not GetWhereIsInSiege(origin)
  end
  
  /*
  
  function GetCheckWallLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
   -- local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if location then
    
        validRoom = true
        
        for index, wall in ientitylist(Shared.GetEntitiesWithClassname("Wall")) do
        
            if GetLocationForPoint(wall:GetOrigin()) == location then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    return validRoom and numInRoom < kWallCommLimitPerRoom
end
*/


function GetCheckCommandStationLimit(techId, origin, normal, commander)
  if GetSandCastle():GetSDBoolean() then return false end
    local num = 0

        
       for _, cc in ipairs(GetEntitiesWithinRange("CommandStation", origin, 9999)) do
        
                num = num + 1
            
    end
    
    return num < 3
end
end
local function GetHiveReq(techId, origin, normal, commander)
  if GetSandCastle():GetSDBoolean() then return false end
    local num = 0

         for _, cc in ipairs(GetEntitiesWithinRange("CommandStation", origin, 2)) do
        
        if cc then return false end     
            
    end
    
    return true
end
local function GetCheckExoDropLimit(techId, origin, normal, commander)
    local num = 0
                 for index, exosuit in ientitylist(Shared.GetEntitiesWithClassname("ExoSuit")) do
                num = num + 1
    end
    
    return num < 10
end

SetCachedTechData(kTechId.Contamination, kTechDataBuildRequiresMethod, GetCheckNotSiege)

SetCachedTechData(kTechId.Door, kTechDataModel, BreakableDoor.kModelName)
SetCachedTechData(kTechId.DropExosuit, kTechDataBuildMethodFailedMessage, "Trying to crash the server?")

SetCachedTechData(kTechId.Hive, kTechDataBuildRequiresMethod, GetHiveReq)
SetCachedTechData(kTechId.Hive, kTechDataBuildMethodFailedMessage, "Techpoint is occupied")


SetCachedTechData(kTechId.CommandStation, kTechDataAttachOptional, true)

SetCachedTechData(kTechId.CommandStation, kTechDataBuildRequiresMethod, GetCheckCommandStationLimit)

--SetCachedTechData(kTechId.Wall, kTechDataBuildRequiresMethod, GetCheckWallLimit)

SetCachedTechData(kTechId.CommandStation, kTechDataIgnorePathingMesh, false)

SetCachedTechData(kTechId.DropExosuit, kTechDataBuildRequiresMethod, GetCheckExoDropLimit)



---Hacks------------







------------------



function GetCheckSentryLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName  and not sentry.isacreditstructure then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kSentrysPerRoom
    
end
function DeniedBitch()
return false
end
SetCachedTechData(kTechId.Sentry, kStructureBuildNearClass, false)
SetCachedTechData(kTechId.Sentry, kStructureAttachRange, 999)
--SetCachedTechData(kTechId.Sentry, kTechDataSpecifyOrientation, false)



SetCachedTechData(kTechId.SentryBattery,kVisualRange, kBatteryPowerRange)
SetCachedTechData(kTechId.SentryBattery,kTechDataDisplayName, "Backup Battery")
SetCachedTechData(kTechId.SentryBattery, kTechDataHint, "Powers structures without power!")


SetCachedTechData(kTechId.Sentry, kTechDataBuildMethodFailedMessage, "limt per room reached")






--------------------------------------------------------------------
/*
360 degree sentrys, 4 per room, without battery.
Shine hooks the local function of sentry saying whether or not a battery is around (powered or not without powerconsumermixin)


local OldUpdateBatteryState

local function NewUpdateBatteryState( self )
     self.attachedToBattery = true
end

OldUpdateBatteryState = Shine.Hook.ReplaceLocalFunction( Sentry.OnUpdate, "UpdateBatteryState", NewUpdateBatteryState )

*/
-------------------------------------------------------------------

-------------------------------------------------------------------------------------------

   local function GetMaxDistanceFor(player)
    
        if player:isa("AlienCommander") then
            return 63
        end

        return 33
    
    end
if Client then
 function HiveVisionMixin:OnUpdate(deltaTime)   
        PROFILE("HiveVisionMixin:OnUpdate")
        // Determine if the entity should be visible on hive sight
        local visible = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
        local player = Client.GetLocalPlayer()
        local now = Shared.GetTime()
        
       if   ( self:isa("SiegeDoor") and self:GetIsLocked() ) or self:isa("TunnelEntrance") then
        visible = true
        end
        
        if Client.GetLocalClientTeamNumber() == kSpectatorIndex
              and self:isa("Alien") 
              and Client.GetOutlinePlayers()
              and not self.hiveSightVisible then

            local model = self:GetRenderModel()
            if model ~= nil then
            
                HiveVision_AddModel( model )
                   
                self.hiveSightVisible = true    
                self.timeHiveVisionChanged = now
                
            end
        
        end
        
        // check the distance here as well. seems that the render mask is not correct for newly created models or models which get destroyed in the same frame
        local playerCanSeeHiveVision = player ~= nil and (player:GetOrigin() - self:GetOrigin()):GetLength() <= GetMaxDistanceFor(player) and (player:isa("Alien") or player:isa("AlienCommander") or player:isa("AlienSpectator"))

        if not visible and playerCanSeeHiveVision and self:isa("Player") then
        
            // Make friendly players always show up - even if not obscured     
            visible = player ~= self and GetAreFriends(self, player)
            
        end
        
        if visible and not playerCanSeeHiveVision then
            visible = false
        end
        
        // Update the visibility status.
        if visible ~= self.hiveSightVisible and self.timeHiveVisionChanged + 1 < now then
        
            local model = self:GetRenderModel()
            if model ~= nil then
            
                if visible then
                    HiveVision_AddModel( model )
                    //DebugPrint("%s add model", self:GetClassName())
                else
                    HiveVision_RemoveModel( model )
                    //DebugPrint("%s remove model", self:GetClassName())
                end 
                   
                self.hiveSightVisible = visible    
                self.timeHiveVisionChanged = now
                
            end
            
        end
            
    end
end



 if Client then
function MarineOutlineMixin:OnUpdate(deltaTime)   
        PROFILE("MarineOutlineMixin:OnUpdate")
        local player = Client.GetLocalPlayer()
        
        local model = self:GetRenderModel()
        if model ~= nil then 
        
            local outlineModel = Client.GetOutlinePlayers() and 
                                    ( ( Client.GetLocalClientTeamNumber() == kSpectatorIndex ) or 
                                      ( player:isa("MarineCommander") and self.catpackboost ) )
                                                            or
                               ( self:isa("SiegeDoor") and self:GetIsLocked() )
                                    
            local outlineColor
            if self.catpackboost then
                outlineColor = kEquipmentOutlineColor.Fuchsia
            elseif HasMixin(self, "ParasiteAble") and self:GetIsParasited() then
                outlineColor = kEquipmentOutlineColor.Yellow
            else
                outlineColor = kEquipmentOutlineColor.TSFBlue
            end

            if outlineModel ~= self.marineOutlineVisible or outlineColor ~= self.marineOutlineColor then

                EquipmentOutline_RemoveModel( model )
                if outlineModel then
                    EquipmentOutline_AddModel( model, outlineColor )
                    self.marineOutlineColor = outlineColor
                end

                self.marineOutlineVisible = outlineModel
            end

        end
            
    end


end


---Corrode hp dmg on unpowered struct


local function CorrodeOnInfestation(self)

    if self:GetMaxArmor() == 0 or not GetFrontDoorOpen() then
        return false
    end

    if self.updateInitialInfestationCorrodeState and GetIsPointOnInfestation(self:GetOrigin()) then
    
        self:SetGameEffectMask(kGameEffect.OnInfestation, true)
        self.updateInitialInfestationCorrodeState = false
        
    end

    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self:GetCanTakeDamage() and (not HasMixin(self, "GhostStructure") or not self:GetIsGhostStructure()) then
        
        self:SetCorroded()
        
        if self:isa("PowerPoint") and self:GetArmor() == 0 then
            self:DoDamageLighting()
        end
        
        if not self:isa("PowerPoint") or self:GetArmor() > 0 then 
            -- stop damaging power nodes when armor reaches 0... gets annoying otherwise.
            self:DeductHealth(kInfestationCorrodeDamagePerSecond, nil, nil, false, true, true)
        end
        
        if not self:isa("CommandStation") and not self:isa("PowerPoint") and self:GetArmor() == 0 and not self:isa("ARC")  and GetIsRoomPowerDown(self) then
           local damage = kInfestationCorrodeDamagePerSecond * 4
                    self:DeductHealth(damage, nil, nil, true, false, true)
        end
        
    end

    return true

end

function CorrodeMixin:__initmixin()

    if Server then
        
        self.isCorroded = false
        self.timeCorrodeStarted = 0
        
        if not self:isa("Player") and not self:isa("MAC") and not self:isa("Exosuit") and kCorrodeMarineStructureArmorOnInfestation then
        
            self:AddTimedCallback(CorrodeOnInfestation, 1)
            self.updateInitialInfestationCorrodeState = true
            
        end
        
    end
    
end


--Really? Not enemy only by default? IDGAF. I'm copy pasting the whole thing with the change. 


function RadiusDamageAliens(entities, centerOrigin, radius, fullDamage, doer, ignoreLOS, fallOffFunc)

    assert(HasMixin(doer, "Damage"))

    -- Do damage to every target in range
    for index, target in ipairs(entities) do
      if target:GetTeamNumber() == 2 then
        -- Find most representative point to hit
        local targetOrigin = GetTargetOrigin(target)
        
        -- Trace line to each target to make sure it's not blocked by a wall
        local wallBetween = false
        local distanceFromTarget = (targetOrigin - centerOrigin):GetLength()
        
        if not ignoreLOS then
            wallBetween = GetWallBetween(centerOrigin, targetOrigin, target)
        end
        
        if (ignoreLOS or not wallBetween) and (distanceFromTarget <= radius) then
        
            -- Damage falloff
            local distanceFraction = distanceFromTarget / radius
            if fallOffFunc then
                distanceFraction = fallOffFunc(distanceFraction)
            end
            
            distanceFraction = Clamp(distanceFraction, 0, 1)        
            local damage = fullDamage * (1 - distanceFraction)

            local damageDirection = targetOrigin - centerOrigin
            damageDirection:Normalize()
            
            -- we can't hit world geometry, so don't pass any surface params and let DamageMixin decide
            doer:DoDamage(damage, target, target:GetOrigin(), damageDirection, "none")

        end
        
    end
    end
end



local function GetMaturityRate(self)

    if self.GetMaturityRate then
        return self:GetMaturityRate()
    end
    
    return kDefaultMaturityRate
    
end

if Server then
  
    function MaturityMixin:OnMaturityUpdate(deltaTime)
        
        PROFILE("MaturityMixin:OnMaturityUpdate")
        
        if not self:GetIsMature() then
               self.matureFraction = 1
               self.finalMatureFraction = 1
               self:UpdateMaturity()
            if self.OnMaturityComplete then
                self:OnMaturityComplete()
            end
        end
        
        -- to prevent too much network spam from happening we update only every second the max health
        if self:isa("Cyst") or self:isa("TunnelEntrance") and GetIsTimeUp(self.timeMaturityLastUpdate, 8 ) then
        
            self:ArtificialLeveling()
            self.timeMaturityLastUpdate = Shared.GetTime()
            
        end
        
        return true
        
    end

end



if Server then
	
	local function RewardAchievement(player, name)

	end
	
	function AchievementReceiverMixin:CheckWeldedPowerNodes()

	end

	function AchievementReceiverMixin:CheckWeldedPlayers()

	end

	function AchievementReceiverMixin:CheckBuildResTowers()

	end

	function AchievementReceiverMixin:CheckKilledResTowers()

	end

	function AchievementReceiverMixin:CheckDefendedResTowers()

	end

	function AchievementReceiverMixin:CheckFollowedOrders()

	end

	function AchievementReceiverMixin:CheckParasitedPlayers()

	end

	function AchievementReceiverMixin:CheckStructureDamageDealt()

	end

	function AchievementReceiverMixin:CheckPlayerDamageDealt()

	end

	function AchievementReceiverMixin:CheckDestroyedRessources()

	end

	function AchievementReceiverMixin:OnPhaseGateEntry()
		
	end

	function AchievementReceiverMixin:OnUseGorgeTunnel()

	end

	function AchievementReceiverMixin:AddWeldedPowerNodes()

	end

	function AchievementReceiverMixin:AddWeldedPlayers()

	end

	function AchievementReceiverMixin:AddBuildResTowers()

	end

	function AchievementReceiverMixin:AddKilledResTowers()

	end

	function AchievementReceiverMixin:AddDefendedResTowers()

	end

	function AchievementReceiverMixin:AddParsitedPlayers()
	end

	function AchievementReceiverMixin:AddStructureDamageDealt(amount)
	end

	function AchievementReceiverMixin:AddPlayerDamageDealt(amount)
	end

	function AchievementReceiverMixin:AddDestroyedRessources(amount)
	end

	function AchievementReceiverMixin:CompletedCurrentOrder()
	end

	function AchievementReceiverMixin:ResetScores()

	end

	function AchievementReceiverMixin:CopyPlayerDataFrom(player)
	end

end

if Client then

	function AchievementReceiverMixin:GetMaxPlayer()
	end

	function AchievementReceiverMixin:OnUpdatePlayer(deltaTime)
    end
end

if Server then

	function AchievementGiverMixin:PreUpdateMove(input, runningPrediction)

	end

	function AchievementGiverMixin:OnTaunt()

	end

	function AchievementGiverMixin:OnAddHealth()

	end

	function AchievementGiverMixin:OnCommanderStructureLogout(hive)
	
	end

	function AchievementGiverMixin:SetGestationData(techIds, previousTechId, healthScalar, armorScalar)

	end

	function AchievementGiverMixin:SetParasited(fromPlayer)

	end

	function AchievementGiverMixin:OnWeldTarget(target)

	end

	function AchievementGiverMixin:OnConstruct(builder, newFraction, oldFraction)

	end

	function AchievementGiverMixin:OnConstructionComplete(builder)

	end

	function AchievementGiverMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)

	end

	function AchievementGiverMixin:PreOnKill(attacker, doer, point, direction)
     end
end

