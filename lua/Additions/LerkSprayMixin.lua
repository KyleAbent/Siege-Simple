LerkSprayMixin = CreateMixin( LerkSprayMixin )
LerkSprayMixin.type = "HealSpray"

-- Players heal by base amount + percentage of max health
local kHealPlayerPercent = 3

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
    return kHealsprayFireDelay
end

function LerkSprayMixin:GetSecondaryEnergyCost(player)
    return kHealsprayEnergyCost
end

function LerkSprayMixin:GetDeathIconIndex()
    return kDeathMessageIcon.Spray 
end

function LerkSprayMixin:OnSecondaryAttack(player)

    local enoughTimePassed = (Shared.GetTime() - self.lastSecondaryAttackTime) > self:GetSecondaryAttackDelay()
    if player:GetSecondaryAttackLastFrame() and enoughTimePassed then
    
        if player:GetEnergy() >= self:GetSecondaryEnergyCost(player) then
        
            self.lastSprayAttacked = true
            self:PerformSecondaryAttack(player)
            
            if self.OnHealSprayTriggered then
                self:OnHealSprayTriggered()
            end
        end

    end
    
end

function LerkSprayMixin:PerformSecondaryAttack(player)
    self.secondaryAttacking = true
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

local function DrainFuel(self, player, targetEntity)

    player:SetFuel( player:GetFuel() - 0.15  )
    

end
    

local kConeWidth = 0.6
local function GetEntitiesWithCapsule(self, player)

    local fireDirection = player:GetViewCoords().zAxis
    -- move a bit back for more tolerance, healspray does not need to be 100% exact
    local startPoint = player:GetEyePos() + player:GetViewCoords().yAxis * 0.2

    local extents = Vector(kConeWidth, kConeWidth, kConeWidth)
    local remainingRange = kRange
 
    local ents = {}
    
    -- always heal self as well
    HealEntity(self, player, player)
    
    for i = 1, 4 do
    
        if remainingRange <= 0 then
            break
        end
        
        local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, remainingRange, PhysicsMask.Melee, EntityFilterOne(player))
        
        if trace.fraction ~= 1 then
        
            if trace.entity then
            
                if HasMixin(trace.entity, "Live") then
                    table.insertunique(ents, trace.entity)
                end
        
            else
            
                -- Make another trace to see if the shot should get deflected.
                local lineTrace = Shared.TraceRay(startPoint, startPoint + remainingRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterOne(player))
                
                if lineTrace.fraction < 0.8 then
                
                    local dotProduct = trace.normal:DotProduct(fireDirection) * -1

                    if dotProduct > 0.6 then
                        player:TriggerEffects("healspray_collide",  {effecthostcoords = Coords.GetTranslation(lineTrace.endPoint)})
                        break
                    else                    
                        fireDirection = fireDirection + trace.normal * dotProduct
                        fireDirection:Normalize()
                    end    
                        
                end
                
            end
            
            remainingRange = remainingRange - (trace.endPoint - startPoint):GetLength() - kConeWidth
            startPoint = trace.endPoint + fireDirection * kConeWidth + trace.normal * 0.05
        
        else
            break
        end

    end
    
    return ents

end


local function GetEntitiesInCylinder(self, player, viewCoords, range, width)

    -- gorge always heals itself
    local ents = { player }
    local startPoint = viewCoords.origin
    local fireDirection = viewCoords.zAxis
    
    local relativePos = nil
    
    for _, entity in ipairs( GetEntitiesWithMixinWithinRange("Live", startPoint, range) ) do
    
        if entity:GetIsAlive() and not entity:isa("Weapon") then
    
            relativePos = entity:GetOrigin() - startPoint
            local yDistance = viewCoords.yAxis:DotProduct(relativePos)
            local xDistance = viewCoords.xAxis:DotProduct(relativePos)
            local zDistance = viewCoords.zAxis:DotProduct(relativePos)

            local xyDistance = math.sqrt(yDistance * yDistance + xDistance * xDistance)

            -- could perform a LOS check here or simply keeo the code a bit more tolerant. healspray is kinda gas and it would require complex calculations to make this check be exact
            if xyDistance <= width and zDistance >= 0 then
                table.insert(ents, entity)
            end
            
        end
    
    end
    
    return ents

end

local function GetEntitiesInCone(self, player)

    local range = 0
    
    local viewCoords = player:GetViewCoords()
    local fireDirection = viewCoords.zAxis
    
    local startPoint = viewCoords.origin + viewCoords.yAxis * kHealCylinderWidth * 0.2
    local lineTrace1 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())
    if (lineTrace1.endPoint - startPoint):GetLength() > range then
        range = (lineTrace1.endPoint - startPoint):GetLength()
    end

    startPoint = viewCoords.origin - viewCoords.yAxis * kHealCylinderWidth * 0.2
    local lineTrace2 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())    
    if (lineTrace2.endPoint - startPoint):GetLength() > range then
        range = (lineTrace2.endPoint - startPoint):GetLength()
    end
    
    startPoint = viewCoords.origin - viewCoords.xAxis * kHealCylinderWidth * 0.2
    local lineTrace3 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())    
    if (lineTrace3.endPoint - startPoint):GetLength() > range then
        range = (lineTrace3.endPoint - startPoint):GetLength()
    end
    
    startPoint = viewCoords.origin + viewCoords.xAxis * kHealCylinderWidth * 0.2
    local lineTrace4 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())
    if (lineTrace4.endPoint - startPoint):GetLength() > range then
        range = (lineTrace4.endPoint - startPoint):GetLength()
    end

    return GetEntitiesInCylinder(self, player, viewCoords, range, kHealCylinderWidth)

end

local function PerformHealSpray(self, player)

    local health = kHealsprayDamage + player:GetMaxHealth() * kHealPlayerPercent / 100.0
    local amountHealed = player:AddHealth(health)
    
    for _, entity in ipairs(GetEntitiesInCone(self, player)) do
    
        if HasMixin(entity, "Team") then
        
            if entity:isa("JetpackMarine")  then
                DrainFuel(self, player, entity)
            end
            
        end
        
    end
    
end

function LerkSprayMixin:OnTag(tagName)

    PROFILE("LerkSprayMixin:OnTag")
   local enoughTimePassed = (Shared.GetTime() - self.lastSecondaryAttackTime) > self:GetSecondaryAttackDelay()
    if self.secondaryAttacking and tagName == "heal"  and enoughTimePassed then
        
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

    local player = self:GetParent()
    if player and self.secondaryAttacking and player:GetEnergy() >= self:GetSecondaryEnergyCost(player) or Shared.GetTime() - self.lastSecondaryAttackTime < 0.5 then
        modelMixin:SetAnimationInput("activity", "secondary")
    end
    
end