function Lerk:OnAdjustModelCoords(modelCoords)
    local scale = .8
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scale
    coords.yAxis = coords.yAxis * scale
    coords.zAxis = coords.zAxis * scale
      
    return coords
    
end
local origspeed = Lerk.GetMaxSpeed

function Lerk:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.10 or speed
end