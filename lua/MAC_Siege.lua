Script.Load("lua/MAC.lua")
Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")

--Kyle 'Avoca' Abent
class 'MACSiege' (MAC)
MACSiege.kMapName = "macsiege"

local networkVars = 

{


}

MAC.kWeldRate = 1

AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
function MACSiege:OnCreate()
MAC.OnCreate(self)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
end
function MAC:GetIsBuilt()
 return self:GetIsAlive()
end
function MACSiege:OnInitialized()
self:SetTechId(kTechId.MAC)
InitMixin(self, LevelsMixin)
if Server then ExploitCheck(self) end
MAC.OnInitialized(self)
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




 
Shared.LinkClassToMap("MACSiege", MACSiege.kMapName, networkVars)
class 'DropMAC' (MAC)
DropMAC.kMapName = "dropmac"

local networkVars = 

{


}
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
function DropMAC:OnCreate()
MAC.OnCreate(self)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
end

function DropMAC:OnInitialized()
MAC.OnInitialized(self)
self:SetTechId(kTechId.MAC)
InitMixin(self, LevelsMixin)
if Server then ExploitCheck(self) end
end
        function DropMAC:GetTechId()
         return kTechId.MAC
end
    function DropMAC:GetMaxLevel()
    return kMacMaxLevel
    end
    function DropMAC:GetAddXPAmount()
    return 0.05 * 0.05
    end

function DropMAC:OnGetMapBlipInfo()
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


function DropMAC:GetCurrentOrder()
 if not self:GetIsBuilt() then return end --Print ("Not Built") return end
return OrdersMixin.GetCurrentOrder(self)
end



function DropMAC:OnUpdate(deltaTime)
MAC.OnUpdate(self, deltaTime)

if self.welding or self.constructing then self:AddXP(self:GetAddXPAmount()) end

end

    function DropMAC:GetTotalConstructionTime()
    local value =  ConditionalValue(GetIsInSiege(self), 1, 2)
    return value
    end
    --Because I want to get rid of it not welding while under attack. I know there's better ways to do this :P
    function DropMAC:GetTimeLastDamageTaken()
    return 0
end

function DropMAC:OnUpdateAnimationInput(modelMixin)
 if not self:GetIsBuilt() then return end
 MAC.OnUpdateAnimationInput(self, modelMixin)

end

---techbuttons im not sure if i have to add recycle manually. Because the mixin does that?
    
    
    
 
Shared.LinkClassToMap("DropMAC", DropMAC.kMapName, networkVars)