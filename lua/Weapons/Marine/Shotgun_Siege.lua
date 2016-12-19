--'Avoca'
Shotgun.kStartOffset = 0
local kBulletSize = 0.016
local kSpreadDistance = 16

local originit = Shotgun.OnInitialized
function Shotgun:OnInitialized()

originit(self)

Shotgun.kSecondarySpreadVectors =  --Sven-Coop !
{
    GetNormalizedVector(Vector(-0.25, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.5, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(-1, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(0.5, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(1, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(-1.25, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(-1.5, 0.02, kSpreadDistance)),
    GetNormalizedVector(Vector(-2, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(1.5, 0.01, kSpreadDistance)),
    GetNormalizedVector(Vector(2, 0.01, kSpreadDistance)),
    

    
}


end



    local origanim = Shotgun.OnUpdateAnimationInput
    function Shotgun:OnUpdateAnimationInput(modelMixin)
    origanim(self, modelMixin)
        local activity = "none"
        if self.secondaryAttacking then
            activity = "primary"
           modelMixin:SetAnimationInput("activity", activity)
         end
    end
    local origprimary = Shotgun.FirePrimary
function Shotgun:FirePrimary(player)
              --Jerry rig so i can have secondary fire acting as primary without firing primary. So I don't have to modify animations :)
  if not self.secondaryAttacking  then
    origprimary(self,player)
  end

end
function Shotgun:GetHasSecondary(player)
    return true
end
function Shotgun:GetSecondaryCanInterruptReload()
    return true
end

function Shotgun:SecondaryHere(player)
  local viewAngles = player:GetViewAngles()

    local shootCoords = viewAngles:GetCoords()

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
    if GetIsVortexed(player) then
        range = 5
    end
    
    local numberBullets = 10
    local startPoint = player:GetEyePos()
    
    self:TriggerEffects("shotgun_attack_sound")
    self:TriggerEffects("shotgun_attack")
    
    for bullet = 1, math.min(numberBullets, #self.kSecondarySpreadVectors) do
    
        if not self.kSecondarySpreadVectors[bullet] then
            break
        end    
    
        local spreadDirection = shootCoords:TransformVector(self.kSecondarySpreadVectors[bullet])

        local endPoint = startPoint + spreadDirection * range
        startPoint = player:GetEyePos() + shootCoords.xAxis * self.kSecondarySpreadVectors[bullet].x * self.kStartOffset + shootCoords.yAxis * self.kSecondarySpreadVectors[bullet].y * self.kStartOffset
        
        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter)
        
        local damage = 0

        HandleHitregAnalysis(player, startPoint, endPoint, trace)        
            
        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = bullet % effectFrequency == 0
        
        local numTargets = #targets
        
        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end
        
        if Client and showTracer then
            TriggerFirstPersonTracer(self, impactPoint)
        end

        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, 17, "", showTracer and i == numTargets)
            
            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, damage)
            end
        
        end
        
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
function Shotgun:OnSecondaryAttack(player)
    local sprintedRecently = (Shared.GetTime() - self.lastTimeSprinted) < kMaxTimeToSprintAfterAttack
    local attackAllowed = not sprintedRecently and (not self:GetIsReloading() or self:GetSecondaryCanInterruptReload()) and (not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame())
    local attackedRecently = (Shared.GetTime() - self.attackLastRequested) < 0.68
    
    
    if self.clip >= 1 and not player:GetIsSprinting() and self:GetIsDeployed() and attackAllowed and not self.primaryAttacking and not attackedRecently then
    
        self.secondaryAttacking = true
        self.attackLastRequested = Shared.GetTime()
          CancelReload(self)
          
          self:SecondaryHere(player)     
          
         -- self.clip = self.clip - 1
    else
        self:OnSecondaryAttackEnd(player)
    end
  
end
