Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/Weapons/Alien/AcidRocket.lua")
--Script.Load("lua/PhaseGateUserMixin.lua")


Fade.XZExtents = 0.4
Fade.YExtents = 1.05

local networkVars = {}

local kBallFlagAttachPoint = "babbler_attach4"


--AddMixinNetworkVars(PhaseGateUserMixin, networkVars)

local origspeed = Fade.GetMaxSpeed
local origcreate = Fade.OnCreate
function Fade:OnCreate()
origcreate(self)

InitMixin(self, PredictedProjectileShooterMixin)
--InitMixin(self, PhaseGateUserMixin)

end

/*

function Fade:GetRebirthLength()
return 4
end
function Fade:GetRedemptionCoolDown()
return 20
end

*/




function Fade:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * kFadeBlinkSpeedBuff or speed
end
function Fade:GetCanMetabolizeHealth()
    return GetHasTech(self, kTechId.MetabolizeHealth)
end

local kBlinkSpeed = 14 * kFadeBlinkSpeedBuff
local kBlinkAcceleration = 40 * kFadeBlinkSpeedBuff
local kBlinkAddAcceleration = 1

function Fade:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsBlinking() then
        local wishDir = self:GetViewCoords().zAxis
        local maxSpeedTable = { maxSpeed = kBlinkSpeed }
        self:ModifyMaxSpeed(maxSpeedTable, input)  
        local prevSpeed = velocity:GetLength()
        local maxSpeed = math.max(prevSpeed, maxSpeedTable.maxSpeed)
        local maxSpeed = math.min(25, maxSpeed)      

       -- Print("maxSpeed is %s", maxSpeed)    
        velocity:Add(wishDir * kBlinkAcceleration * deltaTime)
        
        if velocity:GetLength() > maxSpeed then

            velocity:Normalize()
            velocity:Scale(maxSpeed)
            
        end 
        
        -- additional acceleration when holding down blink to exceed max speed
        velocity:Add(wishDir * kBlinkAddAcceleration * deltaTime)
        
    end

end




if Server then

function Fade:GetTierFourTechId()
    return kTechId.AcidRocket
end

function Fade:GetTierFiveTechId()
    return kTechId.None
end

end

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars) 