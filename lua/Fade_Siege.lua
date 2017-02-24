Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/Weapons/Alien/AcidRocket.lua")
Script.Load("lua/PhaseGateUserMixin.lua")


Fade.XZExtents = 0.4
Fade.YExtents = 1.05

local networkVars = {}



AddMixinNetworkVars(PhaseGateUserMixin, networkVars)

local origspeed = Fade.GetMaxSpeed
local origcreate = Fade.OnCreate
function Fade:OnCreate()
origcreate(self)

InitMixin(self, PredictedProjectileShooterMixin)
InitMixin(self, PhaseGateUserMixin)

end
function Fade:GetRebirthLength()
return 5
end
function Fade:GetRedemptionCoolDown()
return 35
end
function Fade:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.25 or speed
end
function Fade:GetCanMetabolizeHealth()
    return GetHasTech(self, kTechId.MetabolizeHealth)
end

if Server then

function Fade:GetTierFourTechId()
    return kTechId.AcidRocket
end

end

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars) 