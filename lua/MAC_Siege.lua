Script.Load("lua/Additions/LevelsMixin.lua")
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
InitMixin(self, LevelsMixin)
end
        function MACSiege:GetTechId()
         return kTechId.MAC
end
    function MACSiege:GetMaxLevel()
    return kMacMaxLevel
    end
    function MACSiege:GetAddXPAmount()
    return 0.05 * 0.05
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


function MACSiege:OnUpdate(deltaTime)

MAC.OnUpdate(self, deltaTime)

if self.welding or self.constructing then self:AddXP(self:GetAddXPAmount()) end

end

---techbuttons im not sure if i have to add recycle manually. Because the mixin does that?
    
    
    
 
Shared.LinkClassToMap("MACSiege", MACSiege.kMapName, networkVars)