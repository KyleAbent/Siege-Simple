Script.Load("lua/Additions/FireGrenade.lua")
function Flamethrower:GetHasSecondary(player)
    return true
end

function Flamethrower:GetSecondaryCanInterruptReload()
return true
end
function Flamethrower:SecondaryHere(player)
     if Server or (Client and Client.GetIsControllingPlayer()) then
        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis, 0.2, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis
        
        if startPointTrace.fraction ~= 1 then
            direction = GetNormalizedVector(direction:GetProjection(startPointTrace.normal))
        end
               local grenade = player:CreatePredictedProjectile("FireGrenade", startPoint, direction * 14, 1, 0.75, 8)
               self.clip = self.clip - 15
               self:OnSecondaryAttackEnd(player)
    end

end
local function CancelReload(self)

    if self:GetIsReloading() then
    
        self.reloading = false
        if Client then
            self:TriggerEffects("reload_cancel")
        end
        if Server then
            self:TriggerEffects("reload_cancel")
        end
    end
    
end
function Flamethrower:OnSecondaryAttack(player)

    local sprintedRecently = (Shared.GetTime() - self.lastTimeSprinted) < kMaxTimeToSprintAfterAttack
    local attackAllowed = not sprintedRecently and (not self:GetIsReloading() or self:GetSecondaryCanInterruptReload()) and (not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame())
    local attackedRecently = (Shared.GetTime() - self.attackLastRequested) < 1
    
    
    if not player:GetIsSprinting() and self:GetIsDeployed() and attackAllowed and not self.primaryAttacking and not attackedRecently then
    
        self.secondaryAttacking = true
        self.attackLastRequested = Shared.GetTime()
          CancelReload(self)
         if self.clip >= 15 then self:SecondaryHere(player) end       
    else
        self:OnSecondaryAttackEnd(player)
    end
    
  
  
end