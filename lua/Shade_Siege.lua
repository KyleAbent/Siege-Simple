Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")

class 'ShadeAvoca' (Shade)
ShadeAvoca.kMapName = "shadeavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)

    function ShadeAvoca:OnInitialized()
     Shade.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.Shade)
    end
    
        function ShadeAvoca:GetTechId()
         return kTechId.Shade
    end
   function ShadeAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shade
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
    function ShadeAvoca:GetMaxLevel()
    return kAlienDefaultLvl
    end
    function ShadeAvoca:GetAddXPAmount()
    return kAlienDefaultAddXp
    end
    
Shared.LinkClassToMap("ShadeAvoca", ShadeAvoca.kMapName, networkVars)