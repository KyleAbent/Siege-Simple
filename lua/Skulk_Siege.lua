local origspeed = Skulk.GetMaxSpeed

function Skulk:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.20 or speed
end

if Server then

function Skulk:GetTierFourTechId()
    return kTechId.None
end


end