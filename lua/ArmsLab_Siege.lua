Script.Load("lua/Additions/LevelsMixin.lua")

class 'ArmsLabAvoca' (ArmsLab)
ArmsLabAvoca.kMapName = "armslabavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
    

    function ArmsLabAvoca:OnInitialized()
         ArmsLab.OnInitialized(self)
        InitMixin(self, AvocaMixin)
        InitMixin(self, LevelsMixin)
        self:SetTechId(kTechId.ArmsLab)
    end
        function ArmsLabAvoca:GetTechId()
         return kTechId.ArmsLab
    end
        function ArmsLabAvoca:GetMaxLevel()
    return kDefaultLvl
    end
    function ArmsLabAvoca:GetAddXPAmount()
    return kDefaultAddXp
    end
function ArmsLabAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.ArmsLab
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("ArmsLabAvoca", ArmsLabAvoca.kMapName, networkVars)