Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
class 'InfantryPortalAvoca' (InfantryPortal)
InfantryPortalAvoca.kMapName = "infantryportalavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function InfantryPortalAvoca:OnInitialized()
         InfantryPortal.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.InfantryPortal)
    end
        function InfantryPortalAvoca:GetTechId()
         return kTechId.InfantryPortal
    end
        function InfantryPortalAvoca:GetMaxLevel()
    return kDefaultLvl
    end
    function InfantryPortalAvoca:GetAddXPAmount()
    return kDefaultAddXp
    end
    

function InfantryPortalAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.InfantryPortal
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
Shared.LinkClassToMap("InfantryPortalAvoca", InfantryPortalAvoca.kMapName, networkVars)