
--Script.Load("lua/Additions/LevelsMixin.lua")

local networkVars =
{

}

--AddMixinNetworkVars(LevelsMixin, networkVars)


local originit = PowerPoint.OnInitialized
function PowerPoint:OnInitialized()
        originit(self)
        --InitMixin(self, LevelsMixin)
end  

local orig = PowerPoint.CanBeCompletedByScriptActor
function PowerPoint:CanBeCompletedByScriptActor( player )
         local imagination = GetImaginator()
           if imagination:GetMarineEnabled() then
           
           return true
           
           end
    return orig(self, player)
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