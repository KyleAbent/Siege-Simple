Script.Load("lua/Additions/LevelsMixin.lua")


local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
    
local originit = ArmsLab.OnInitialized
    function ArmsLab:OnInitialized()
         originit(self)
        InitMixin(self, AvocaMixin)
        InitMixin(self, LevelsMixin)
    end
        function ArmsLab:GetTechId()
         return kTechId.ArmsLab
    end
        function ArmsLab:GetMaxLevel()
    return kDefaultLvl
    end
    function ArmsLab:GetAddXPAmount()
    return kDefaultAddXp
    end

Shared.LinkClassToMap("ArmsLab", ArmsLab.kMapName, networkVars)