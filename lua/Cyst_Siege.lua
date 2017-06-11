Script.Load("lua/Additions/LevelsMixin.lua")
local networkVars =
{
   noComm = "private boolean",
   builtTime = "time",
}

AddMixinNetworkVars(LevelsMixin, networkVars)

local kModelSizeGrowth = 1.3

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
  self.builtTime = Shared.GetTime() --though not built oncreate
end
local originit = Cyst.OnInitialized
function Cyst:OnInitialized()
        originit(self)
        InitMixin(self, LevelsMixin)
end  
function Cyst:GetInfestationGrowthRate()
    local rate = 0.2
          rate = Clamp(math.abs(0.8 * GetRoundLengthToSiege()), 0.2, 0.8)
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
function Cyst:GetLevelPercentage()
return self.level / self:GetMaxLevel() * kModelSizeGrowth
end
    function Cyst:GetMaxLevel()
    return 100
    end
    function Cyst:GetAddXPAmount()
    return 0.30
    end


function Cyst:GetMinRangeAC()
return  kCystRedeployRange + 1    
end

--local origmathp = Cyst.GetMatureMaxHealth
function Cyst:GetMax()

    local orig = kMatureCystHealth
    local bySiege = orig * 2
    local val = Clamp(orig * (GetRoundLengthToSiege()/1) + orig, orig, bySiege)
    self.level = self:GetMaxLevel() * GetRoundLengthToSiege()
 --  self.level = self.level * 
 
    local byFive = val * 2
    local builttime = Clamp(Shared.GetTime() -  self.builtTime, 0, 300)
    val = Clamp(val * (builttime/300) + val, val, byFive)
    --self.level = (self.level * 2) * builttime
     --Print("builttime is %s, val is %s", builttime, val)
    return val

end 

--local origmatarm = Cyst.GetMatureMaxArmor
function Cyst:GetMaxA()
    local orig = kMatureCystArmor
    local bySiege = orig * 2
    return Clamp(bySiege * GetRoundLengthToSiege(), orig, bySiege)
end 
function Cyst:ArtificialLeveling()
  if Server and GetIsTimeUp(self.timeMaturityLastUpdate, 8 )  and self:GetIsBuilt() then
   self:AdjustMaxHealth(self:GetMax())
   self:AdjustMaxArmor(self:GetMaxA())
   end
end
function Cyst:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
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

Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)