Script.Load("lua/ConstructMixin.lua")


class 'ARCCredit' (ARC)
ARCCredit.kMapName = "arccredit"


local networkVars = {} --fuckbitchz
AddMixinNetworkVars(ConstructMixin, networkVars)

local origarc  = ARC.OnCreate
function ARCCredit:OnCreate()


origarc(self)
InitMixin(self, ConstructMixin)

end

function ARCCredit:OnConstructionComplete()
self:GiveOrder(kTechId.ARCDeploy, self:GetId(), self:GetOrigin(), nil, false, false)
CreateEntity(Scan.kMapName, self:GetOrigin(), 1)
 end
 function ARCCredit:GetDamageType()
return kDamageType.StructuresOnly
end
 function ARCCredit:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.ARC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
  
    Shared.LinkClassToMap("ARCCredit", ARCCredit.kMapName, networkVars)