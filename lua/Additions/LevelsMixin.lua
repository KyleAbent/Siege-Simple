--Kyle 'Avoca' Abent
LevelsMixin = CreateMixin(LevelsMixin)
LevelsMixin.type = "Levels"


LevelsMixin.networkVars =
{
    level = "float (0 to " .. 100 .. " by .1)",
}

LevelsMixin.expectedMixins =
{
}

LevelsMixin.expectedCallbacks = 
{
    GetMaxLevel = "",
    GetAddXPAmount = "",
}
function LevelsMixin:__initmixin()

self.level = 0
    
end
    function LevelsMixin:GetMaxLevel()
    return 50
    end
    function LevelsMixin:GetAddXPAmount()
    return 0.25
    end

  function LevelsMixin:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
   unitName = string.format(Locale.ResolveString("%s (%s)"),self:GetClassName(),  self:GetLevel())
return unitName
end 

function LevelsMixin:OnHealSpray(gorge) 
      local oldlevel = self.level
      self:AddXP(self:GetAddXPAmount()) --missing score for player
      if oldlevel ~= self.level then  gorge:AddScore(0.05) end --hm?
end

function LevelsMixin:AddXP(amount)
    --Print("add xp triggered")
     if self.OnAddXp then self:OnAddXp(amount) end
     if self.GetIsBuilt and not self:GetIsBuilt() then return end
    local xpReward = 0
        xpReward = math.min(amount, self:GetMaxLevel() - self.level)
        self.level = self.level + xpReward
        
     if self:GetTeamNumber() == 1 then
       if Server then
        local defaultarmor = LookupTechData(self:GetTechId(), kTechDataMaxArmor) or 200
        self:AdjustMaxArmor(defaultarmor * (self.level/100) +  defaultarmor) 
       end
     end
      
    return xpReward
    
end
function LevelsMixin:GetLevel()
        return Round(self.level, 2)
end

