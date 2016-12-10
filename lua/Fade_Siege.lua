Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/Weapons/Alien/AcidRocket.lua")
Script.Load("lua/PhaseGateUserMixin.lua")


Fade.XZExtents = 0.4
Fade.YExtents = 1.05

class 'FadeAvoca' (Fade)
FadeAvoca.kMapName = "fadeavoca"

local networkVars = {


}

AddMixinNetworkVars(PhaseGateUserMixin, networkVars)

local origspeed = Fade.GetMaxSpeed

function FadeAvoca:OnCreate()
Fade.OnCreate(self)

InitMixin(self, PredictedProjectileShooterMixin)
InitMixin(self, PhaseGateUserMixin)

end
function FadeAvoca:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.25 or speed
end
        function FadeAvoca:GetTechId()
         return kTechId.Fade
    end
function FadeAvoca:GetCanMetabolizeHealth()
    return GetHasTech(self, kTechId.MetabolizeHealth)
end

   function FadeAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shade
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function FadeAvoca:GetPlayerStatusDesc()

    local status = kPlayerStatus.Void
    
    if (self:GetIsAlive() == false) then
        status = kPlayerStatus.Dead
    else
        if (self:isa("Embryo")) then
            if self.gestationTypeTechId == kTechId.Fade then
                status = kPlayerStatus.FadeEgg
             end
        else
            status = kPlayerStatus.Fade
        end
    end
    
    return status

end
if Server then

function FadeAvoca:GetTierFourTechId()
    return kTechId.AcidRocket
end

end

Shared.LinkClassToMap("FadeAvoca", FadeAvoca.kMapName, networkVars) 