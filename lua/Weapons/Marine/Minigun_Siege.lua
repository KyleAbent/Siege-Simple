--11.19 - slightly longer shoot time, more dmg torwards oni.

local kHeatUpRate = 0.25
local kCoolDownRate = 0.4
local kMinigunRange = 400
local kBulletSize = 0.03
local kMinigunSpread = Math.Radians(5)
local kOverheatedSoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/overheated")
local function UpdateOverheated(self, player)

    if not self.overheated and self.heatAmount == 1 then
    
        self.overheated = true
        self:OnPrimaryAttackEnd(player)
        
        if self:GetIsLeftSlot() then
            player:TriggerEffects("minigun_overheated_left")
        elseif self:GetIsRightSlot() then    
            player:TriggerEffects("minigun_overheated_right")
        end    
        
        StartSoundEffectForPlayer(kOverheatedSoundName, player)
        
    end
    
    if self.overheated and self.heatAmount == 0 then
        self.overheated = false
    end
    
end
function Minigun:ProcessMoveOnWeapon(player, input)

    local dt = input.time
    local addAmount = self.shooting and (dt * kHeatUpRate) or -(dt * kCoolDownRate)
    self.heatAmount = math.min(1, math.max(0, self.heatAmount + addAmount))
    
    UpdateOverheated(self, player)  
    
    if Client and not Shared.GetIsRunningPrediction() then
    
        local spinSound = Shared.GetEntity(self.spinSoundId)
        spinSound:SetParameter("heat", self.heatAmount, 1)
        
        if player:GetIsLocalPlayer() then
        
            local heatUISound = Shared.GetEntity(self.heatUISoundId)
            heatUISound:SetParameter("heat", self.heatAmount, 1)
            
        end
        
    end
    
end

-- TODO: we should use clip weapons provided functionality here (or create a more general solution which distincts between melee, hitscan and projectile only)!
local function Shoot(self, leftSide)

    local player = self:GetParent()
    -- We can get a shoot tag even when the clip is empty if the frame rate is low
    -- and the animation loops before we have time to change the state.
    if self.minigunAttacking and player then
    
        if Server and not self.spinSound:GetIsPlaying() then
            self.spinSound:Start()
        end    
    
        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        -- Filter ourself out of the trace so that we don't hit ourselves.
        local filter = EntityFilterTwo(player, self)
        local startPoint = player:GetEyePos()
        
        local spreadDirection = CalculateSpread(shootCoords, kMinigunSpread, NetworkRandom)
        
        local range = kMinigunRange
        if GetIsVortexed(player) then
            range = 5
        end
        
        local endPoint = startPoint + spreadDirection * range
        
        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter) 
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local surfaceName = trace.surface
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
        
        local numTargets = #targets
        
        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end
        
        if Client and showTracer then
            TriggerFirstPersonTracer(self, trace.endPoint)
        end
        
        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]
            local damage = ConditionalValue(target and not target:isa("Onos"), kMinigunDamage, kMinigunDamage+ 4)
            Print("minigun damage is %s", damage)
            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)
            
            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, damage)
            end
        
        end
        
        self.shooting = true
        
    end
    
end
function Minigun:OnTag(tagName)

    PROFILE("Minigun:OnTag")
    
    if self:GetIsLeftSlot() and tagName == "l_shoot" then
        Shoot(self, true)
    elseif not self:GetIsLeftSlot() and tagName == "r_shoot" then
        Shoot(self, false)
    end
    
end