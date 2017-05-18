local networkVars =
{
   noComm = "private boolean",
}
function Cyst:CheckYoselfFoo()
self.noComm = GetImaginator():GetAlienEnabled() 
return true
end
local origcreate = Cyst.OnCreate
function Cyst:OnCreate()
origcreate(self)
self.noComm = false
  if Server then
  self:CheckYoselfFoo()
 self:AddTimedCallback(function() self:CheckYoselfFoo() end, 4)
 end
 



end
function Cyst:GetInfestationGrowthRate()
    local rate = 0.2
          rate = math.abs(0.8 * GetRoundLengthToSiege())
          --Print("Cyst infest rate is %s", rate)
          --Note also adjust max mature hp throughout siege?
    return rate
end
function Cyst:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Minigun") then
    
        damageTable.damage = damageTable.damage * 0.7
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end

local origone = Cyst.GetCystParentRange
function Cyst:GetCystParentRange()
return self.noComm and 999 or origone(self)
end
local origtwo = Cyst.GetCystParentRange
function Cyst:GetCystParentRange()
return self.noComm and 999 or origtwo(self)
end

function Cyst:GetMinRangeAC()
return  kCystRedeployRange + 1    
end

if Server then

local origthree = Cyst.GetIsActuallyConnected
   function Cyst:GetIsActuallyConnected()
     return self.noComm and true or origthree(self)
   end
  local origfour = Cyst.GetCanAutoBuild 
  function Cyst:GetCanAutoBuild()
     return self.noComm and true or origfour(self)
   end
    
end