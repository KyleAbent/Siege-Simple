local origspeed = Skulk.GetMaxSpeed

function Skulk:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.20 or speed
end