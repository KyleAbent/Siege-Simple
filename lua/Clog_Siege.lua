Script.Load("lua/InfestationMixin.lua")

local networkVars = {}
AddMixinNetworkVars(InfestationMixin, networkVars)

function Clog:GetMinRangeAC()
return  kCystRedeployRange * .7      
end

function Clog:GetIsSighted()
return true    
end

local originit = Clog.OnInitialized
function Clog:OnInitialized()
     originit(self)
  InitMixin(self, InfestationMixin)
end

function Clog:GetInfestationRadius()
  local frontdoor = GetEntitiesWithinRange("FrontDoor", self:GetOrigin(), 7)
   if #frontdoor >=1 then return 0
   else
    return 3.5
   end
end
function Clog:GetInfestationGrowthRate()
 return 0.5
end
function Clog:GetAttached()
return false
end




local origonkill = Clog.PreOnKill
function Clog:PreOnKill(attacker, doer, point, direction)
    self:SetDesiredInfestationRadius(0)
    
      for _, structure in ipairs(GetEntitiesWithMixinForTeamWithinRange("InfestationTracker", 1, self:GetOrigin(), 8)) do
      structure:AddTimedCallback(function() structure:SetGameEffectMask(kGameEffect.OnInfestation, false) end, 1)
      end
      
      end
      
      if Server and origonkill ~= nil  then origonkill(self, attacker, doer, point, direction) end

Shared.LinkClassToMap("Clog", Clog.kMapName, networkVars)