function Crag:GetCragsInRange()
      local crag = GetEntitiesWithinRange("Crag", self:GetOrigin(), Crag.kHealRadius)
           return Clamp(#crag, 0, 3)
end
function Crag:GetBonusAmt()
return (self:GetCragsInRange()/10)
end
function Crag:GetMinRangeAC()
return CragAutoCCMR 
end
function Crag:GetUnitNameOverride(viewer) --Triggerhappy stoner
    local unitName = GetDisplayName(self)   
    --unitName = string.format(Locale.ResolveString("Crag (+%sS 0%)"), self:GetCragsInRange()) --, self:GetBonusAmt() )
    unitName = "Crag (+"..self:GetCragsInRange().."0% heal)" --, self:GetBonusAmt() )
return unitName
end
local origbuttons = Crag.GetTechButtons
function Crag:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[4] = kTechId.CragUmbra
 
 return table

end
local origact = Crag.PerformActivation
function Crag:PerformActivation(techId, position, normal, commander)
origact(self, techId, position, normal, commander)

local success  = false
   if  techId == kTechId.CragUmbra then
    success = self:TriggerUmbra()
end

return success, true

end



function Crag:TriggerUmbra()

    local umbra = CreateEntity(CragUmbra.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    umbra:SetTravelDestination(self:GetOrigin() + Vector(0, 2, 0) )
    self:TriggerEffects("crag_trigger_umbra")
    return true
end



function Crag:TryHeal(target)

    local unclampedHeal = target:GetMaxHealth() * Crag.kHealPercentage
    local heal = Clamp(unclampedHeal, Crag.kMinHeal, Crag.kMaxHeal) 
       
    if self.healWaveActive then
        heal = heal * Crag.kHealWaveMultiplier
    end
    
    --heal = heal * self:GetCragsInRange()/3 + heal
    if self:GetCragsInRange() >= 1 then
    heal = heal * self:GetBonusAmt() + heal
    end
    
   -- if self:GetIsSiege() and self:IsInRangeOfHive() and target:isa("Hive") or target:isa("Crag") then
   --    heal = heal * kCragSiegeBonus
   -- end
    
    if target:GetHealthScalar() ~= 1 and (not target.timeLastCragHeal or target.timeLastCragHeal + Crag.kHealInterval <= Shared.GetTime()) then
       local amountHealed = target:AddHealth(heal)
       target.timeLastCragHeal = Shared.GetTime()
       
       return amountHealed
    else
        return 0
    end
   
end
-------- Hmmm?? does this even do anything? a 10% dmg discount from minigun? I have no idea.
function Crag:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Minigun") then
    
        damageTable.damage = damageTable.damage * 0.9
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end




