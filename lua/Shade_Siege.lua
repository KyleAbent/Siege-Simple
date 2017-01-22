Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
function Shade:GetInfestationRadius()
    return 1
end
local originit = Shade.OnInitialized
    function Shade:OnInitialized()
    originit(self)
       InitMixin(self, InfestationMixin)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
    end
    function Shade:OnOrderGiven()
   if self:GetInfestationRadius() ~= 0 then self:SetInfestationRadius(0) end
end
    function Shade:GetMaxLevel()
    return kAlienDefaultLvl
    end
    function Shade:GetAddXPAmount()
    return kAlienDefaultAddXp
    end
    
Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)