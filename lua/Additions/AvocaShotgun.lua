--'Avoca'
local kViewModels = GenerateMarineViewModelPaths("shotgun")
local kBulletSize = 0.016
local kNanoshieldMaterial = PrecacheAsset("Glow/green/green.material")

class 'AvocaShotgun' (Shotgun)
AvocaShotgun.kMapName = "avocashotgun"

local networkVars = {}



    local origanim = Shotgun.OnUpdateAnimationInput
    function Shotgun:OnUpdateAnimationInput(modelMixin)
    origanim(self, modelMixin)
        local activity = "none"
     --   if self.secondaryAttacking then
       --     activity = "primary"
        --   modelMixin:SetAnimationInput("activity", activity)
        -- end
    end
    local origprimary = Shotgun.FirePrimary
function AvocaShotgun:FirePrimary(player)
              --Jerry rig so i can have secondary fire acting as primary without firing primary. So I don't have to modify animations :)
  if not self.secondaryAttacking  then
    origprimary(self,player)
  end

end
function AvocaShotgun:GetHasSecondary(player)
    return true
end
function AvocaShotgun:GetSecondaryCanInterruptReload()
    return true
end
function AvocaShotgun:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end
function AvocaShotgun:SecondaryHere(player)
 local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2

    local shootCoords = viewAngles:GetCoords()

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
    if GetIsVortexed(player) then
        range = 5
    end
    
    local numberBullets = self:GetBulletsPerShot()
    local startPoint = player:GetEyePos()
    
    self:TriggerEffects("shotgun_attack_sound")
    self:TriggerEffects("shotgun_attack")
    
    for bullet = 1, math.min(numberBullets, #self.kSpreadVectors) do
    
        if not self.kSpreadVectors[bullet] then
            break
        end    
    
        local spreadDirection = shootCoords:TransformVector(self.kSpreadVectors[bullet])

        local endPoint = startPoint + spreadDirection * range
        startPoint = player:GetEyePos() + shootCoords.xAxis * self.kSpreadVectors[bullet].x * self.kStartOffset + shootCoords.yAxis * self.kSpreadVectors[bullet].y * self.kStartOffset
        
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

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, kShotgunDamage, "", showTracer and i == numTargets)
            
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
function AvocaShotgun:OnSecondaryAttack(player)
    local attackAllowed = (not self:GetIsReloading() or self:GetSecondaryCanInterruptReload()) and (not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame())
    
    
    if self:GetIsDeployed() and attackAllowed and not self.primaryAttacking  then
    
        self.secondaryAttacking = true
        self.attackLastRequested = Shared.GetTime()
          CancelReload(self)
          
          self:SecondaryHere(player)     
          
          --self.clip = self.clip - 1
    else
        self:OnSecondaryAttackEnd(player)
    end
  
end

if Client then

    function AvocaShotgun:OnUpdateRender()
          local showMaterial = true --not self:GetInAttackMode()
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client
Shared.LinkClassToMap("AvocaShotgun", AvocaShotgun.kMapName, networkVars)