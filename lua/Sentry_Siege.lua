Sentry.kFov = 360
Sentry.kMaxPitch = 360
Sentry.kMaxYaw = 360
Sentry.kBarrelScanRate = 120



function Sentry:GetFov()
    return 360
end
local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end


local function NewUpdateBatteryState( self )
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 1) then
        
           local location = GetLocationForPoint(self:GetOrigin())
           local powerpoint = location ~= nil and GetPowerPointForLocation(location:GetName())   
            self.attachedToBattery = false
           if powerpoint then 
            self.attachedToBattery = (powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled()) or GetHasSentryBatteryInRadius(self)
            end
            self.lastBatteryCheckTime = time
        end
end
if Server then


 function Sentry:OnUpdate(deltaTime)
    
        PROFILE("Sentry:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)  
        
        NewUpdateBatteryState(self)
        
        if self.timeNextAttack == nil or (Shared.GetTime() > self.timeNextAttack) then
        
            local initialAttack = self.target == nil
            
            local prevTarget = nil
            if self.target then
                prevTarget = self.target
            end
            
            self.target = nil
            
            if GetIsUnitActive(self) and self.attachedToBattery and self.deployed then
                self.target = self.targetSelector:AcquireTarget()
            end
            
            if self.target then
            
                local previousTargetDirection = self.targetDirection
                self.targetDirection = GetNormalizedVector(self.target:GetEngagementPoint() - self:GetAttachPointOrigin(Sentry.kMuzzleNode))
                
                -- Reset damage ramp up if we moved barrel at all
                if previousTargetDirection then
                    local dotProduct = previousTargetDirection:DotProduct(self.targetDirection)
                    if dotProduct < .99 then
                    
                        self.timeLastTargetChange = Shared.GetTime()
                        
                    end    
                end

                -- Or if target changed, reset it even if we're still firing in the exact same direction
                if self.target ~= prevTarget then
                    self.timeLastTargetChange = Shared.GetTime()
                end            
                
                -- don't shoot immediately
                if not initialAttack then
                
                    self.attacking = true
                    self:FireBullets()
                    
                end    
                
            else
            
                self.attacking = false
                self.timeLastTargetChange = Shared.GetTime()

            end
                    
            -- Random rate of fire so it can't be gamed

            if initialAttack and self.target then --and barrel point facing enemy?
                self.timeNextAttack = Shared.GetTime() + Sentry.kTargetAcquireTime
            else
                self.timeNextAttack = Shared.GetTime() + Sentry.kBaseROF + math.random() * Sentry.kRandROF
            end    
            
            if not GetIsUnitActive() or not self.attacking or not self.attachedToBattery then
            
                if self.attackSound:GetIsPlaying() then
                    self.attackSound:Stop()
                end
                
            elseif self.attacking then
            
                if not self.attackSound:GetIsPlaying() then
                    self.attackSound:Start()
                end

            end 
        
        end
    
    end
    
end
if Client then
    local function UpdateAttackEffects(self, deltaTime)
    
        local intervall = Sentry.kAttackEffectIntervall
        if self.attacking and (self.timeLastAttackEffect + intervall < Shared.GetTime()) then
 
            
            -- plays muzzle flash and smoke
            self:TriggerEffects("sentry_attack")

            self.timeLastAttackEffect = Shared.GetTime()
            
        end
        
    end
 function Sentry:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if GetIsUnitActive(self) and self.deployed and self.attachedToBattery then
      
            -- Swing barrel yaw towards target
            if self.attacking then
            
                if self.targetDirection then
                
                    local invSentryCoords = self:GetAngles():GetCoords():GetInverse()
                    self.relativeTargetDirection = GetNormalizedVector( invSentryCoords:TransformVector( self.targetDirection ) )
                    self.desiredYawDegrees = Clamp(math.asin(-self.relativeTargetDirection.x) * 360 / math.pi, -360, 360)            
                    self.desiredPitchDegrees = Clamp(math.asin(self.relativeTargetDirection.y) * 360 / math.pi, -360, 360)           
                    
                end
                
                UpdateAttackEffects(self, deltaTime)
                
            -- Else when we have no target, swing it back and forth looking for targets
            else
            
                local sin = math.sin(math.rad((Shared.GetTime() + self:GetId() * .3) * Sentry.kBarrelScanRate))
                self.desiredYawDegrees = sin * self:GetFov() 
                
                -- Swing barrel pitch back to flat
                self.desiredPitchDegrees = 0
            
            end
            
            -- swing towards desired direction
            self.barrelPitchDegrees = Slerp(self.barrelPitchDegrees, self.desiredPitchDegrees, Sentry.kBarrelMoveRate * deltaTime)    
            self.barrelYawDegrees = Slerp(self.barrelYawDegrees , self.desiredYawDegrees, Sentry.kBarrelMoveRate * deltaTime)
        
        end
    
    end


end






--SentryBattery.kRange = 9999


Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")

class 'SentryAvoca' (Sentry)
SentryAvoca.kMapName = "sentryavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function SentryAvoca:OnInitialized()
         Sentry.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.Sentry)
    end
        function SentryAvoca:GetTechId()
         return kTechId.Sentry
    end

if Server then

end
    function SentryAvoca:GetMaxLevel()
    return kDefaultLvl
    end
    function SentryAvoca:GetAddXPAmount()
    return kDefaultAddXp
    end


function SentryAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Sentry
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("SentryAvoca", SentryAvoca.kMapName, networkVars)

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
    
    return validRoom and numInRoom < kCommSentryPerRoom
    
end


 function SentryAvoca:FireBullets()

    local startPoint = self:GetBarrelPoint()
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then
    
        local targetVelocity = self.target:GetVelocity()
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * 0.5 - (self.level/100) ) * GetNormalizedVector(targetVelocity))
        
    end
    
    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)    
    local spreadDirection = CalculateSpread(fireCoords, Math.Radians(8), math.random)
    
    local endPoint = startPoint + spreadDirection * (Sentry.kRange * (self.level/100) + Sentry.kRange)
    
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
    
    if trace.fraction < 1 then
    
        local surface = nil
        
        // Disable friendly fire.
        local validtarget = GetAreEnemies(trace.entity, self)
        trace.entity = (not trace.entity or validtarget) and trace.entity or nil
        
        if not trace.entity then
            surface = trace.surface
        end
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        local damage = 5 
        //if not self:GetIsaCreditStructure() and trace.entity and trace.entity:isa("Onos") then damage = 7 end 
        self:DoDamage(damage * (self.level/100) + damage, trace.entity, trace.endPoint, fireDirection, surface, false, true)
        
    end
    
        
end

