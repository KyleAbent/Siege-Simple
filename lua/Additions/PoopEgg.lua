Script.Load("lua/Egg.lua")
Script.Load("lua/InfestationMixin.lua")

class 'PoopEgg' (Egg)

PoopEgg.kMapName = "poopegg"

local networkVars = { }
AddMixinNetworkVars(InfestationMixin, networkVars)

    function PoopEgg:OnInitialized()
         Egg.OnInitialized(self)
          InitMixin(self, InfestationMixin)
        self:SetTechId(kTechId.Egg)
    end
            function PoopEgg:GetTechId()
         return kTechId.Egg
    end
      function PoopEgg:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("PoopEgg"))
return unitName
end 
    function PoopEgg:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Egg
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function PoopEgg:GetInfestationRadius()
    return 1
end
Shared.LinkClassToMap("PoopEgg", PoopEgg.kMapName, networkVars)

class 'SaltyEgg' (PoopEgg)

SaltyEgg.kMapName = "saltyegg"

function SaltyEgg:OnInitialized()
    PoopEgg.OnInitialized(self)
    self:SetOrigin(self:GetOrigin() + Vector(0, .25, 0) ) 
end
      function SaltyEgg:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("SaltyEgg"))
return unitName
end 
Shared.LinkClassToMap("SaltyEgg", SaltyEgg.kMapName, networkVars)

