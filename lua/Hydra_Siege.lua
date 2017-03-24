Hydra.kSpikeSpeed = 80
Hydra.kSpread = Math.Radians(11)

local originit = Hydra.OnInitialized
function Hydra:OnInitialized()
self.startsMature = true
originit(self)

if Server then

               self.targetSelector = TargetSelector():Init(
                self,
                Hydra.kRange, 
                true,
                { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) } ) 


end

end

function Hydra:FilterTarget(slap)

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function Hydra:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("BreakableDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end
function Hydra:UpdateMaturity()
return false
end
function Hydra:OnConstructionComplete()
    self.updateMaturity = false
end



Script.Load("lua/Additions/LevelsMixin.lua")

class 'HydraSiege' (Hydra)
HydraSiege.kMapName = "hydrasiege"

local networkVars = {}
AddMixinNetworkVars(LevelsMixin, networkVars) --would explain it
function HydraSiege:OnInitialized()
 Hydra.OnInitialized(self)
   InitMixin(self, LevelsMixin)
   self:SetTechId(kTechId.Hydra) --Set Parent???
   self.level = 1 //div by 0 
end


        function HydraSiege:GetTechId()
         return kTechId.Hydra
    end
   function HydraSiege:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Hydra
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

    function HydraSiege:OnAddXp(amount)
        self:AdjustMaxHealth(kHydraHealth * (self.level/100) + kHydraHealth) 
    end
    
function HydraSiege:GetLevelPercentage()
return self.level / self:GetMaxLevel() * 1.3
end
function HydraSiege:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
    
    
    function HydraSiege:GetMaxLevel()
    return kAlienDefaultLvl
    end
    function HydraSiege:GetAddXPAmount()
    return self:GetMaxLevel() / math.random(8,16) 
    end
    
    if Server then
    local function CreateSpikeProjectile(self)

    // TODO: make hitscan at account for target velocity (more inaccurate at higher speed)
    
    local startPoint = self:GetBarrelPoint()
    local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
    local targetDistanceSquared = directionToTarget:GetLengthSquared()
    local theTimeToReachEnemy = targetDistanceSquared / (Hydra.kSpikeSpeed * Hydra.kSpikeSpeed)
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then
    
        local targetVelocity = self.target:GetVelocity()
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * Hydra.kTargetVelocityFactor * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))
        
    end
    
    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)    
    local spreadDirection = CalculateSpread(fireCoords, Hydra.kSpread, math.random)
    
    local endPoint = startPoint + spreadDirection * (Hydra.kRange * (self.level/100) + Hydra.kRange)
    
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
    
    if trace.fraction < 1 then
    
        local surface = nil
        
        // Disable friendly fire.
        trace.entity = (not trace.entity or GetAreEnemies(trace.entity, self)) and trace.entity or nil
        
        if not trace.entity then
            surface = trace.surface
        end
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        self:DoDamage(Hydra.kDamage * (self.level/100) + Hydra.kDamage, trace.entity, trace.endPoint, fireDirection, surface, false, true)
        
    end
    
end

function HydraSiege:AttackTarget()

    self:TriggerUncloak()
    
    CreateSpikeProjectile(self)    
    self:TriggerEffects("hydra_attack")
    
    // Random rate of fire to prevent players from popping out of cover and shooting regularly
    self.timeOfNextFire = Shared.GetTime() + .5 + math.random()
    
end

    
    end
Shared.LinkClassToMap("HydraSiege", HydraSiege.kMapName, networkVars) 



