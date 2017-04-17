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
function SentryAvoca:GetMaxArmor()
    return kSentryArmor 
end
function SentryAvoca:GetMinRangeAC()
return SentryAutoCCMR     
end
function SentryAvoca:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sentry:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("attack", self.attacking)
    modelMixin:SetAnimationInput("powered", true)
    
end
if Server then

end
    function SentryAvoca:GetMaxLevel()
    return 25
    end
    function SentryAvoca:GetAddXPAmount()
    return 0.25
    end
function SentryAvoca:GetFov()
    return 360
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

function GetBatteryInRange(commander)

    local batteries = {}
    for _, battery in ipairs(GetEntitiesForTeam("CommandStation", commander:GetTeamNumber())) do
        batteries[battery] = 999
    end
    
    return batteries
    
end


 function SentryAvoca:FireBullets()

    local startPoint = self:GetBarrelPoint()
    local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
    local targetDistanceSquared = directionToTarget:GetLengthSquared()
    local theTimeToReachEnemy = targetDistanceSquared / (10 * 10)
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then
    
        local targetVelocity = self.target:GetVelocity()
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * 0.5 - (self.level/100) * 1 * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))
        
    end
    
    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)    
    local spreadDirection = CalculateSpread(fireCoords, Math.Radians(15), math.random)
    
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