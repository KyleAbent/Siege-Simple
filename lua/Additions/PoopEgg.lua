Script.Load("lua/Egg.lua")

class 'PoopEgg' (Egg)

PoopEgg.kMapName = "poopegg"

local networkVars = { }

    function PoopEgg:OnInitialized()
         Egg.OnInitialized(self)
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

Shared.LinkClassToMap("PoopEgg", PoopEgg.kMapName, networkVars)