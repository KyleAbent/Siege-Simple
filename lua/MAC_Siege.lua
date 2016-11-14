Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")

--Kyle 'Avoca' Abent
class 'MACSiege' (MAC)
MACSiege.kMapName = "macsiege"

local networkVars = 

{


}
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
function MACSiege:OnCreate()
MAC.OnCreate(self)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
end

function MACSiege:OnInitialized()
MAC.OnInitialized(self)
self:SetTechId(kTechId.MAC)
end
        function MACSiege:GetTechId()
         return kTechId.MAC
end
function MACSiege:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.MAC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

---techbuttons im not sure if i have to add recycle manually. Because the mixin does that?
    
    
    
 
Shared.LinkClassToMap("MACSiege", MACSiege.kMapName, networkVars)