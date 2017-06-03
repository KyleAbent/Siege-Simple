-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\LerkBileBomb.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Additions/LerkBomb.lua")
Script.Load("lua/Additions/LerkSprayMixin.lua")

class 'LerkBileBomb' (Ability)

LerkBileBomb.kMapName = "lerkbilebomb"

-- part of the players velocity is use for the bomb
local kPlayerVelocityFraction = 1
local kBombVelocity = 1

local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge_view.animation_graph")

local kBbombViewEffect = PrecacheAsset("cinematics/alien/gorge/bbomb_1p.cinematic")

local networkVars =
{
    firingPrimary = "boolean"
}

AddMixinNetworkVars(LerkSprayMixin, networkVars)

function LerkBileBomb:OnCreate()

    Ability.OnCreate(self)
    
    self.firingPrimary = false
    self.timeLastLerkBileBomb = 0
    
    InitMixin(self, LerkSprayMixin)
    
end

function LerkBileBomb:GetAnimationGraphName()
    return kAnimationGraph
end

function LerkBileBomb:GetEnergyCost(player)
    return kBileBombEnergyCost
end

function LerkBileBomb:GetHUDSlot()
    return 4
end

function LerkBileBomb:GetSecondaryTechId()
    return kTechId.Spray
end

local function CreateBombProjectile( self, player )
    
    if not Predict then
        
        -- little bit of a hack to prevent exploitey behavior.  Prevent gorges from bile bombing
        -- through clogs they are trapped inside.
        local startPoint = nil
        local startVelocity = nil
        if GetIsPointInsideClogs(player:GetEyePos()) then
            startPoint = player:GetEyePos()
            startVelocity = Vector(0,0,0)
        else
            local viewCoords = player:GetViewAngles():GetCoords()
            startPoint = player:GetAttachPointOrigin("fxnode_bilebomb")
            startVelocity = viewCoords.zAxis * kBombVelocity
            
            local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
            
            startPoint = startPointTrace.endPoint
        end

        player:CreatePredictedProjectile( "LerkBomb", startPoint, startVelocity)
        
    end
    
end

function LerkBileBomb:OnTag(tagName)

    PROFILE("LerkBileBomb:OnTag")

    if self.firingPrimary and tagName == "shoot" then
    
        local player = self:GetParent()
        
        if player then
        
            if Server or (Client and Client.GetIsControllingPlayer()) then
                CreateBombProjectile(self, player)
            end
            
            player:DeductAbilityEnergy(self:GetEnergyCost())            
            self.timeLastLerkBileBomb = Shared.GetTime()
            
            self:TriggerEffects("LerkBileBomb_attack")
            
            if Client then
            
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kBbombViewEffect)
                
            end
            
        end
    
    end
    
end

function LerkBileBomb:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
    
        self.firingPrimary = true
        
    else
        self.firingPrimary = false
    end  
    
end

function LerkBileBomb:OnPrimaryAttackEnd(player)

    Ability.OnPrimaryAttackEnd(self, player)
    
    self.firingPrimary = false
    
end

function LerkBileBomb:GetTimeLastBomb()
    return self.timeLastLerkBileBomb
end

function LerkBileBomb:OnUpdateAnimationInput(modelMixin)

    PROFILE("LerkBileBomb:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "bomb")
    
    local activityString = "none"
    if self.firingPrimary then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("LerkBileBomb", LerkBileBomb.kMapName, networkVars)