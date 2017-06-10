
--Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/ResearchMixin.lua")

local networkVars =
{

}

AddMixinNetworkVars(ResearchMixin, networkVars)

--AddMixinNetworkVars(LevelsMixin, networkVars)


local originit = PowerPoint.OnCreate
function PowerPoint:OnCreate()
        originit(self)
         InitMixin(self, ResearchMixin)
end  

   
local originit = PowerPoint.OnInitialized
function PowerPoint:OnInitialized()
        originit(self)
        --InitMixin(self, LevelsMixin)
end  
function PowerPoint:GetHasTier(number)

return self:GetMaxHealth() >= kPowerPointHealth * number

end
function PowerPoint:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    if techId == kTechId.PowerPointHPUPG2 then allowed = self:GetHasTier(1.10) end
    if techId == kTechId.PowerPointHPUPG3 then allowed = self:GetHasTier(1.20) end
    
    return allowed, canAfford
    
end
local orig = PowerPoint.CanBeCompletedByScriptActor
function PowerPoint:CanBeCompletedByScriptActor( player )
         local imagination = GetImaginator()
           if imagination:GetMarineEnabled() then
           
           return true
           
           end
    return orig(self, player)
end
local origbuttons = PowerPoint.GetTechButtons
function PowerPoint:GetTechButtons(techId)

local buttons = origbuttons(self, techId)
    if self:GetIsBuilt() then
       if not self:GetHasTier(1.10) then
     buttons[1] = kTechId.PowerPointHPUPG1
     end
     if not self:GetHasTier(1.20) then
     buttons[2] = kTechId.PowerPointHPUPG2
     end
    if not self:GetHasTier(1.30) then
     buttons[3] = kTechId.PowerPointHPUPG3
     end
       end
    return buttons
end
if Server then

function PowerPoint:OnResearchComplete(researchId)
local adj = 1
   if researchId == kTechId.PowerPointHPUPG1 then
     adj = 1.10
   elseif researchId== kTechId.PowerPointHPUPG2 then
    adj = 1.20
   elseif researchId == kTechId.PowerPointHPUPG3 then
    adj = 1.30
   end
   
   self:AdjustMaxHealth(kPowerPointHealth * adj)

end

end

/*
    function PowerPoint:GetMaxLevel()
    return 30
    end
    function PowerPoint:GetAddXPAmount()
    return 0.30
    end

function PowerPoint:TimedHPUPG()
    local orig = kPowerPointHealth
    local bySiege = orig * 1.30
    local val = Clamp(bySiege * GetRoundLengthToSiege(), orig, bySiege)
    self.level = self:GetMaxLevel() * GetRoundLengthToSiege()
    self:AdjustMaxHealth(val) --like a song
    --return val
end 

local update = PowerPoint.OnUpdate
function PowerPoint:OnUpdate(deltaTime)

    update(self, deltaTime)
    if not self.lastCheck or GetIsTimeUp(self.lastCheck, math.random(4, 12)) then
      self:TimedHPUPG()
      self.lastCheck = Shared.GetTime()
    end
    
end
*/
Shared.LinkClassToMap("PowerPoint", PowerPoint.kMapName, networkVars)