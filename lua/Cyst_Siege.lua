function Cyst:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Minigun") then
    
        damageTable.damage = damageTable.damage * 0.7
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end

local origone = Cyst.GetCystParentRange
function Cyst:GetCystParentRange()
return GetImaginator():GetAlienEnabled() and 999 or origone(self)
end
local origtwo = Cyst.GetCystParentRange
function Cyst:GetCystParentRange()
return GetImaginator():GetAlienEnabled() and 999 or origtwo(self)
end

function Cyst:GetMinRangeAC()
return  kCystRedeployRange     
end

if Server then

local origthree = Cyst.GetIsActuallyConnected
   function Cyst:GetIsActuallyConnected()
     return GetImaginator():GetAlienEnabled() and true or origthree(self)
   end
  local origfour = Cyst.GetCanAutoBuild 
  function Cyst:GetCanAutoBuild()
     return GetImaginator():GetAlienEnabled() and true or origfour(self)
   end
    
end