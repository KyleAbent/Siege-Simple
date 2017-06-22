Script.Load("lua/Egg.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/Additions/SandMixin.lua")

class 'PoopEgg' (Egg)

PoopEgg.kMapName = "poopegg"

local networkVars = { sandy = "private boolean" }
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(SandMixin, networkVars)

    function PoopEgg:OnInitialized()
         Egg.OnInitialized(self)
          InitMixin(self, InfestationMixin)
        self:SetTechId(kTechId.Egg)
        self.sandy = false
        InitMixin(self, SandMixin)
    end
            function PoopEgg:GetTechId()
         return kTechId.Egg
    end
     function PoopEgg:SetSandy()
         self.sandy = true
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
    return 0.5
end
Shared.LinkClassToMap("PoopEgg", PoopEgg.kMapName, networkVars)


