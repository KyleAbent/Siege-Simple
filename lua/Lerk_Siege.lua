
Script.Load("lua/ADditions/LerkBomb.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")

local kBallFlagAttachPoint = "fxnode_bilebomb"

local origcreate = Lerk.OnCreate

function Lerk:OnCreate()
     origcreate(self)
    InitMixin(self, PredictedProjectileShooterMixin)
end
if Server then

function Lerk:GetTierFourTechId()
    return kTechId.PrimalScream
end

function Lerk:GetTierFiveTechId()
    return kTechId.LerkBileBomb
end

end

function Lerk:OnAdjustModelCoords(modelCoords)
    local scale = .75
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scale
    coords.yAxis = coords.yAxis * scale
    coords.zAxis = coords.zAxis * scale
      
    return coords
    
end
function Lerk:GetBallFlagAttatchPoint(player)
       return kBallFlagAttachPoint
end
function Lerk:GetRebirthLength()
return 4
end
function Lerk:GetRedemptionCoolDown()
return 15
end
local origspeed = Lerk.GetMaxSpeed

function Lerk:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.10 or speed
end
