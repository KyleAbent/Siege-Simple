Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/SaltMixin.lua")

local networkVars = 

{
    channel = "float (1 to 3 by 1)",
}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(SaltMixin, networkVars)
    
  local origcreate = PhaseGate.OnCreate
  function PhaseGate:OnCreate()
      origcreate(self)
      self.channel = 1
  end
local originit = PhaseGate.OnInitialized
    function PhaseGate:OnInitialized()
        originit(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, SaltMixin)
    end

local origbuttons = PhaseGate.GetTechButtons
function PhaseGate:GetTechButtons(techId)
local table = {}

 table = origbuttons(self, techId)

 table[1] = kTechId.PGchannelOne
 table[2] = kTechId.PGchannelTwo
 
 return table
end
 function PhaseGate:PerformActivation(techId, position, normal, commander)
 
    if techId == kTechId.PGchannelOne then
       self.channel = 1
   elseif kTechId.PGchannelTwo then
       self.channel = 2
   elseif kTechId.PGchannelThree then
       self.channel = 3
  end
  return true
  
end
  function PhaseGate:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("PhaseGate(Ch. %s)"), self.channel)
return unitName
end 
    function PhaseGate:GetMinRangeAC()
    return math.random(PGAutoCCMRMax, PGAutoCCMRMin) 
      end
    function PhaseGate:GetMaxLevel()
    return kDefaultLvl
    end
    function PhaseGate:GetAddXPAmount()
    return kDefaultAddXp
    end

Shared.LinkClassToMap("PhaseGate", PhaseGate.kMapName, networkVars)