LerkUmbraMixin = CreateMixin( LerkUmbraMixin )
LerkUmbraMixin.type = "LerkUmbra"

-- Players heal by base amount + percentage of max health
local kHealPlayerPercent = 2

local kRange = 4
local kHealCylinderWidth = 3


-- LerkUmbraMixin:GetHasSecondary should completely override any existing
-- GetHasSecondary function defined in the object.
LerkUmbraMixin.overrideFunctions =
{
    "GetHasSecondary",
    "GetSecondaryEnergyCost"
}

LerkUmbraMixin.networkVars =
{
    lastSecondaryAttackTime = "float"
}

function LerkUmbraMixin:__initmixin()

    self.secondaryAttacking = false
    self.lastSecondaryAttackTime = 0
    self.lastSprayAttacked = false

end

function LerkUmbraMixin:GetHasSecondary(player)
    return true
end

function LerkUmbraMixin:GetSecondaryAttackDelay()
    return 1.3
end

function LerkUmbraMixin:GetSecondaryEnergyCost(player)
    return kUmbraEnergyCost
end

function LerkUmbraMixin:GetDeathIconIndex()
    return kDeathMessageIcon.Umbra 
end

function LerkUmbraMixin:GetRange()
    return kUmbraMaxRange
end
local function CreateUmbraCloud(self, player)
    
    local maxRange = self:GetRange()
    
    local trace = Shared.TraceRay(
        player:GetEyePos(), 
        player:GetEyePos() + player:GetViewCoords().zAxis * maxRange, 
        CollisionRep.Damage, 
        PhysicsMask.Bullets, 
        EntityFilterOneAndIsa(player, "Babbler")
    )
    
    local origin = player:GetModelOrigin()
    local travelVector = trace.endPoint - origin
    local distance = math.min( maxRange, travelVector:GetLength() )
    local destination = GetNormalizedVector(travelVector) * distance + origin
    local umbraCloud = CreateEntity( CragUmbra.kMapName, origin, player:GetTeamNumber() )
    
    umbraCloud:SetTravelDestination( destination )
    
    if gDebugSporesAndUmbra then
    --TEMP - Remove once tuning / debugging of VFX, etc done
        DebugWireSphere( destination, kUmbraRadius, kUmbraDuration, 1, 1, 0, 0.8, false )
        DebugDrawAxes( Coords.GetTranslation( destination + trace.normal * 0.35), destination, 2, kUmbraDuration, 1 )
    end
    
end
function LerkUmbraMixin:OnSecondaryAttack(player)

    if player:GetEnergy() >= self:GetSecondaryEnergyCost(player) then
        self.secondaryAttacking = true
    else
        self.secondaryAttacking = false
    end
    
end
function LerkUmbraMixin:OnSecondaryAttackEnd(player)
    self.secondaryAttacking = false
end
function LerkUmbraMixin:PerformSecondaryAttack(player)
    self.secondaryAttacking = true
end

function LerkUmbraMixin:OnSecondaryAttackEnd(player)

    Ability.OnSecondaryAttackEnd(self, player)
    
    self.secondaryAttacking = false

end

function LerkUmbraMixin:GetDamageType()
    return kHealsprayDamageType
end

local function DrainFuel(self, player, targetEntity)

    targetEntity:SetFuel( targetEntity:GetFuel() - 0.15  )
    

end
    

function LerkUmbraMixin:OnTag(tagName)

    PROFILE("LerkUmbraMixin:OnTag")
   local enoughTimePassed = (Shared.GetTime() - self.lastSecondaryAttackTime) > self:GetSecondaryAttackDelay()
    if self.secondaryAttacking and enoughTimePassed then
        
        local player = self:GetParent()
        if player and player:GetEnergy() >= self:GetSecondaryEnergyCost(player) then
            if Server then
                    self:TriggerEffects("umbra_attack")
                    CreateUmbraCloud(self, player)
                    player:DeductAbilityEnergy(self:GetEnergyCost())
            end
            
        end
    
    end
    
end

function LerkUmbraMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("LerkUmbraMixin:OnUpdateAnimationInput")
    

    
        
        local activityString = "none"
        if self.primaryAttacking or self.secondaryAttacking then
            activityString = "primary"
        end
        
        modelMixin:SetAnimationInput("activity", activityString)
    
    
end
    
