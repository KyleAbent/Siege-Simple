function PowerConsumerMixin:GetHasSentryBatteryInRadius()
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or self:GetHasSentryBatteryInRadius()
end

if Server then
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


kMACSupply = 5
--Add drifter egg fix




kJetpackReplenishFuelRate = .14 -- .11 to .14 %30 increase
kJetpackUseFuelRate = 0.147 -- 30% decrease from .21
kSentrySupply = 5
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

