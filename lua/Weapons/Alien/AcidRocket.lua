//
// lua\Weapons\Alien\AcidRocket.lua
// Created by:   Dragon

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Rocket.lua")
Script.Load("lua/Weapons/Alien/Blink.lua")

class 'AcidRocket' (Blink)

AcidRocket.kMapName = "acidrocket"

local kPlayerVelocityFraction = .5
local kRocketVelocity = 45

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")

AcidRocket.networkVars =
{
    lastPrimaryAttackTime = "private time"
}

function AcidRocket:OnCreate()

    Blink.OnCreate(self)
    self.lastPrimaryAttackTime = 0
    self.firingPrimary = false
end

function AcidRocket:GetAnimationGraphName()
    return kAnimationGraph
end

function AcidRocket:GetEnergyCost(player)
    return kAcidRocketEnergyCost
end

function AcidRocket:GetPrimaryAttackDelay()
    local parent = self:GetParent()
    local attackSpeed = parent:GetIsEnzymed() and (kAcidRocketFireDelay*0.75) or kAcidRocketFireDelay
    attackSpeed = attackSpeed + ( parent.electrified and (attackSpeed*0.8) or 0 )
    attackSpeed = attackSpeed - ( parent:GetHasPrimalScream() and attackSpeed * 0.7 or 0)
    --Print("attackSpeed is %s", attackSpeed)
    return attackSpeed
end

function AcidRocket:GetDeathIconIndex()
     return kDeathMessageIcon.Babbler
end

function AcidRocket:GetHUDSlot()
    return 4
end

function AcidRocket:OnPrimaryAttack(player)

       if player:GetEnergy() >= self:GetEnergyCost() and Shared.GetTime() > (self.lastPrimaryAttackTime + self:GetPrimaryAttackDelay()) and not self:GetIsBlinking() then
        if Server or (Client and Client.GetIsControllingPlayer()) then
            self:FireRocketProjectile(player)
            self.firingPrimary = true
        end
        self.lastPrimaryAttackTime = Shared.GetTime()
        self:TriggerEffects("acidrocket_attack")
        player:DeductAbilityEnergy(self:GetEnergyCost())
    end  
    
end
function AcidRocket:OnPrimaryAttackEnd(player)

    Ability.OnPrimaryAttackEnd(self, player)
    
    self.firingPrimary = false
    
end
function AcidRocket:GetPrimaryAttackRequiresPress()
    return false
end

function AcidRocket:GetBlinkAllowed()
    return true
end

function AcidRocket:GetSecondaryTechId()
    return kTechId.Blink
end

function AcidRocket:FireRocketProjectile(player)

    if Server or (Client and Client.GetIsControllingPlayer()) then
        
        local viewAngles = player:GetViewAngles()
        local velocity = player:GetVelocity()
        local viewCoords = viewAngles:GetCoords()
        local scale = 1
--        if player.modelsize > 1 then scale = player.modelsize end 
        local startPoint = player:GetEyePos() + (viewCoords.zAxis * scale)
        local startVelocity = velocity * kPlayerVelocityFraction + viewCoords.zAxis * kRocketVelocity
        
        local rocket = player:CreatePredictedProjectile("Rocket", startPoint, startVelocity, 0, 0, 5)
        
    end

end

function AcidRocket:OnUpdateAnimationInput(modelMixin)
    PROFILE("AcidRocket:OnUpdateAnimationInput")   
    local activityString = "none"
    if self.firingPrimary then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)
end

Shared.LinkClassToMap("AcidRocket", AcidRocket.kMapName, AcidRocket.networkVars )
