if Server then

function Lerk:CheckForPrimal()
 if self:GetWeaponInHUDSlot(3) ~= nil then  self:GiveItem(Primal.kMapName) self:SetActiveWeapon(LerkBite.kMapName) end
  return false
end

local orig = Lerk.InitWeapons
function Lerk:InitWeapons()
orig(self)
       self:AddTimedCallback(function()  self:CheckForPrimal() end, 0.06)

end


end

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
