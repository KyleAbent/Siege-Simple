/*
function Onos:PreUpdateMove(input, runningPrediction)
end
*/
/*
local origspeed = Onos.GetMaxSpeed

function Onos:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.10 or speed
end
*/

Onos.kMaxSpeed = 8
Onos.kChargeSpeed = 13.7

function Onos:GetHasMovementSpecial()
    return GetHasTech(self, kTechId.Charge)
end
