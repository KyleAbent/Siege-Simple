Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    
local originit = PhaseGate.OnInitialized
    function PhaseGate:OnInitialized()
        originit(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
    end
        function PhaseGate:GetTechId()
         return kTechId.PhaseGate
    end
    function PhaseGate:GetMaxLevel()
    return kDefaultLvl
    end
    function PhaseGate:GetAddXPAmount()
    return kDefaultAddXp
    end

Shared.LinkClassToMap("PhaseGate", PhaseGate.kMapName, networkVars)