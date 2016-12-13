Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")

class 'ShiftAvoca' (Shift)
ShiftAvoca.kMapName = "shiftavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
function ShiftAvoca:GetInfestationRadius()
    return 1
end
    function ShiftAvoca:OnInitialized()
     Shift.OnInitialized(self)
       InitMixin(self, InfestationMixin)
         InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.Shift)
    end
    function ShiftAvoca:OnOrderGiven()
   if self:GetInfestationRadius() ~= 0 then self:SetInfestationRadius(0) end
end
        function ShiftAvoca:GetTechId()
         return kTechId.Shift
    end
   function ShiftAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shift
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
    function ShiftAvoca:GetMaxLevel()
    return kAlienDefaultLvl
    end
    function ShiftAvoca:GetAddXPAmount()
    return kAlienDefaultAddXp
    end
function ShiftAvoca:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Minigun") then
    
        damageTable.damage = damageTable.damage * 0.9
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end
Shared.LinkClassToMap("ShiftAvoca", ShiftAvoca.kMapName, networkVars)