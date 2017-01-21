Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")

class 'ShadeAvoca' (Shade)
ShadeAvoca.kMapName = "shadeavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
function ShadeAvoca:GetInfestationRadius()
    return 1
end

    function ShadeAvoca:OnInitialized()
       InitMixin(self, InfestationMixin)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.Shade)
       Shade.OnInitialized(self)
    end
    function ShadeAvoca:OnOrderGiven()
   if self:GetInfestationRadius() ~= 0 then self:SetInfestationRadius(0) end
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