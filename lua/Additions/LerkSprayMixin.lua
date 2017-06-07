LerkSprayMixin = CreateMixin( LerkSprayMixin )
LerkSprayMixin.type = "LerkSpray"

-- Players heal by base amount + percentage of max health
local kHealPlayerPercent = 2

local kRange = 4
local kHealCylinderWidth = 3


-- LerkSprayMixin:GetHasSecondary should completely override any existing
-- GetHasSecondary function defined in the object.
LerkSprayMixin.overrideFunctions =
{
    "GetHasSecondary",
    "GetSecondaryEnergyCost"
}

LerkSprayMixin.networkVars =
{
    lastSecondaryAttackTime = "float"
}

function LerkSprayMixin:__initmixin()

    self.secondaryAttacking = false
    self.lastSecondaryAttackTime = 0
    self.lastSprayAttacked = false

end

function LerkSprayMixin:GetHasSecondary(player)
    return true
end

function LerkSprayMixin:GetSecondaryAttackDelay()
    return kHealsprayFireDelay / 2
end

function LerkSprayMixin:GetSecondaryEnergyCost(player)
    return kHealsprayEnergyCost * 0.7
end

function LerkSprayMixin:GetDeathIconIndex()
    return kDeathMessageIcon.Spray 
end

function LerkSprayMixin:OnSecondaryAttack(player)


    if player:GetEnergy() >= self:GetSecondaryEnergyCost() then
    
        self.secondaryAttacking = true
        
    else
        self.secondaryAttacking = false
    end  
   
    
end

function LerkSprayMixin:OnSecondaryAttackEnd(player)

    Ability.OnSecondaryAttackEnd(self, player)
    
    self.secondaryAttacking = false

end

local function GetHealOrigin(self, player)

    -- Don't project origin the full radius out in front of Gorge or we have edge-case problems with the Gorge
    -- not being able to hear himself
    local startPos = player:GetEyePos()
    local endPos = startPos + (player:GetViewAngles():GetCoords().zAxis * kHealsprayRadius * .9)
    local trace = Shared.TraceRay(startPos, endPos, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
    return trace.endPoint
    
end

function LerkSprayMixin:GetDamageType()
    return kHealsprayDamageType
end

function LerkSprayMixin:OnPrimaryAttack()
    self.lastSprayAttacked = false
end

function LerkSprayMixin:GetWasSprayAttack()
    return self.lastSprayAttacked
end

local function PerformHealSpray(self, player)

    local health = kHealsprayDamage + player:GetMaxHealth() * kHealPlayerPercent / 100.0
    local amountHealed = player:AddHealth(health)
    
    
end

function LerkSprayMixin:OnTag(tagName)

    PROFILE("LerkSprayMixin:OnTag")
   local enoughTimePassed = (Shared.GetTime() - self.lastSecondaryAttackTime) > self:GetSecondaryAttackDelay()
    if self.secondaryAttacking  and enoughTimePassed then
        
        local player = self:GetParent()
        if player and player:GetEnergy() >= self:GetSecondaryEnergyCost(player) then
        
            PerformHealSpray(self, player)            
            player:DeductAbilityEnergy(self:GetSecondaryEnergyCost(player))
            
            local effectCoords = Coords.GetLookIn(GetHealOrigin(self, player), player:GetViewCoords().zAxis)
            player:TriggerEffects("heal_spray", { effecthostcoords = effectCoords })
            
            self.lastSecondaryAttackTime = Shared.GetTime()
        
        end
    
    end
    
end

function LerkSprayMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("LerkSprayMixin:OnUpdateAnimationInput")

    if self.secondaryAttacking then
        modelMixin:SetAnimationInput("activity", "primary")
    end
    
end