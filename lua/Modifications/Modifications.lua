Script.Load("lua/Modifications/ReallyNow.lua")

local origkill = LiveMixin.Kill
function LiveMixin:Kill(attacker, doer, point, direction)
  if self:GetIsAlive() and self:GetCanDie() then
         if self:isa("Alien") then
               if GetHasRebirthUpgrade(self) and self:GetEligableForRebirth() then
                self:TriggerRebirth()
                return
                end
            end
            
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
   if points ~= nil and wasKill and self:isa("Alien") then points = math.round(points * 1.30 + points, 2) end
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
function GetCheckCommandStationLimit(techId, origin, normal, commander)
    local num = 0

        
       for _, cc in ipairs(GetEntitiesWithinRange("CommandStation", origin, 9999)) do
        
                num = num + 1
            
    end
    
    return num < 3
end
end
local function GetHiveReq(techId, origin, normal, commander)
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

SetCachedTechData(kTechId.DropExosuit, kTechDataBuildMethodFailedMessage, "Trying to crash the server?")

SetCachedTechData(kTechId.Hive, kTechDataBuildRequiresMethod, GetHiveReq)
SetCachedTechData(kTechId.Hive, kTechDataBuildMethodFailedMessage, "Techpoint is occupied")


SetCachedTechData(kTechId.CommandStation, kTechDataAttachOptional, true)

SetCachedTechData(kTechId.CommandStation, kTechDataBuildRequiresMethod, GetCheckCommandStationLimit)

SetCachedTechData(kTechId.CommandStation, kTechDataIgnorePathingMesh, false)

SetCachedTechData(kTechId.DropExosuit, kTechDataBuildRequiresMethod, GetCheckExoDropLimit)

SetCachedTechData(kTechId.RoboticsFactory, kTechDataMapName, RoboSiege.kMapName)

SetCachedTechData(kTechId.MAC, kTechDataMapName, MACSiege.kMapName)
SetCachedTechData(kTechId.ARC, kTechDataMapName, ARCSiege.kMapName)


---Hacks------------

SetCachedTechData(kTechId.ArmsLab, kTechDataMapName, ArmsLabAvoca.kMapName)
SetCachedTechData(kTechId.Armory, kTechDataMapName, ArmoryAvoca.kMapName)
SetCachedTechData(kTechId.PhaseGate, kTechDataMapName, PhaseGateAvoca.kMapName)
SetCachedTechData(kTechId.PrototypeLab, kTechDataMapName, PrototypeLabAvoca.kMapName)
SetCachedTechData(kTechId.Observatory, kTechDataMapName, ObservatoryAvoca.kMapName)
SetCachedTechData(kTechId.CommandStation, kTechDataMapName,CommandStationAvoca.kMapName)
SetCachedTechData(kTechId.InfantryPortal, kTechDataMapName,InfantryPortalAvoca.kMapName)
SetCachedTechData(kTechId.Sentry, kTechDataMapName,SentryAvoca.kMapName)
SetCachedTechData(kTechId.Exo, kTechDataMapName,ExoAvoca.kMapName)


SetCachedTechData(kTechId.Whip, kTechDataMapName,WhipAvoca.kMapName)
SetCachedTechData(kTechId.Crag, kTechDataMapName,CragAvoca.kMapName)
SetCachedTechData(kTechId.Shade, kTechDataMapName,ShadeAvoca.kMapName)
SetCachedTechData(kTechId.Shift, kTechDataMapName,ShiftAvoca.kMapName)
SetCachedTechData(kTechId.Hydra, kTechDataMapName,HydraAvoca.kMapName)





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
    
    return validRoom and numInRoom < 4
    
end
function DeniedBitch()
return false
end
SetCachedTechData(kTechId.Sentry, kStructureBuildNearClass, false)
SetCachedTechData(kTechId.Sentry, kStructureAttachRange, 999)
SetCachedTechData(kTechId.Sentry, kTechDataSpecifyOrientation, false)



SetCachedTechData(kTechId.SentryBattery,kVisualRange, kBatteryPowerRange)
SetCachedTechData(kTechId.SentryBattery,kTechDataDisplayName, "Backup Battery")
SetCachedTechData(kTechId.SentryBattery, kTechDataHint, "Powers structures without power!")


SetCachedTechData(kTechId.Sentry, kTechDataBuildMethodFailedMessage, "4 per room")

SetCachedTechData(kTechId.Fade, kTechDataMapName,FadeAvoca.kMapName)
SetCachedTechData(kTechId.Fade, kTechDataGestateName, FadeAvoca.kMapName)





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
        
       if   ( self:isa("SiegeDoor") and self:GetIsLocked() ) then
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

    if self:GetMaxArmor() == 0 then
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
        
        if not self:isa("PowerPoint") and self:GetArmor() == 0 and not self:isa("ARC")  and GetIsRoomPowerDown(self) then
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
