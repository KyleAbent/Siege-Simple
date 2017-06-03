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
    return kHealsprayFireDelay
end

function LerkUmbraMixin:GetSecondaryEnergyCost(player)
    return kHealsprayEnergyCost
end

function LerkUmbraMixin:GetDeathIconIndex()
    return kDeathMessageIcon.Spray 
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

        if player then  
            
            if Server then
                if player:GetEnergy() >= self:GetEnergyCost() then
                    self:TriggerEffects("umbra_attack")
                    CreateUmbraCloud(self, player)
                    player:DeductAbilityEnergy(self:GetEnergyCost())
                end
            end
            
        end
    
end

function LerkUmbraMixin:PerformSecondaryAttack(player)
    self.secondaryAttacking = true
end

function LerkUmbraMixin:OnSecondaryAttackEnd(player)

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

function LerkUmbraMixin:GetDamageType()
    return kHealsprayDamageType
end

function LerkUmbraMixin:OnPrimaryAttack()
    self.lastSprayAttacked = false
end

function LerkUmbraMixin:GetWasSprayAttack()
    return self.lastSprayAttacked
end

local function DrainFuel(self, player, targetEntity)

    targetEntity:SetFuel( targetEntity:GetFuel() - 0.15  )
    

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

function LerkUmbraMixin:OnTag(tagName)

    PROFILE("LerkUmbraMixin:OnTag")
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

function LerkUmbraMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("LerkUmbraMixin:OnUpdateAnimationInput")
    

    
        
        local activityString = "none"
        if self.primaryAttacking or self.secondaryAttacking then
            activityString = "primary"
        end
        
        modelMixin:SetAnimationInput("activity", activityString)
    
    
end
    
