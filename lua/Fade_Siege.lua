Script.Load("lua/Weapons/Alien/AcidRocket.lua")
Script.Load("lua/Weapons/Alien/Rocket.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")

class 'FadeSiege' (Fade)
FadeSiege.kMapName = "fadesiege"

local networkVars = {}
function FadeSiege:OnInitialized() --Simple. I don't want to complicate this right now.
 if Server then  if self:GetHasTwoHives() then  self:GiveItem(AcidRocket.kMapName) end end
end

local origspeed = Fade.GetMaxSpeed

function FadeSiege:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  return not self:GetIsOnFire() and speed * 1.27 or speed
end



Shared.LinkClassToMap("FadeSiege", FadeSiege.kMapName, networkVars)