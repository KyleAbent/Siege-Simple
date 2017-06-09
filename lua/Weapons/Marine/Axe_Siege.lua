/*
Script.Load("lua/Weapons/Marine/AxeThrow.lua")
local kPlayerVelocityFraction = .5
local kRocketVelocity = 45
function Axe:ThrowAxeProjectile(player)

    if Server or (Client and Client.GetIsControllingPlayer()) then
        
        local viewAngles = player:GetViewAngles()
        local velocity = player:GetVelocity()
        local viewCoords = viewAngles:GetCoords()
        local scale = 1
--        if player.modelsize > 1 then scale = player.modelsize end 
        local startPoint = player:GetEyePos() + (viewCoords.zAxis * scale)
        local startVelocity = velocity * kPlayerVelocityFraction + viewCoords.zAxis * kRocketVelocity
        
        local rocket = player:CreatePredictedProjectile("AxeThrow", startPoint, startVelocity, 0, 0, 5)
        
    end

end
function Axe:OnPrimaryAttack(player)

        if Server or (Client and Client.GetIsControllingPlayer()) then
            self:ThrowAxeProjectile(player)
           -- self.firingPrimary = true
        end
       -- self.lastPrimaryAttackTime = Shared.GetTime()
        self:TriggerEffects("axe_attack") 
    
end
*/