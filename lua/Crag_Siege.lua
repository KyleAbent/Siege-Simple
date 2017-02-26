--Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
Script.Load("lua/CommAbilities/Alien/CragUmbra.lua")
Script.Load("lua/InfestationMixin.lua")

class 'CragSiege' (Crag)
CragSiege.kMapName = "cragsiege"

local networkVars = {}

--AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
function CragSiege:GetInfestationRadius()
    if self:GetIsACreditStructure() then return 1 else return 0 end
end

    function CragSiege:OnInitialized()
       --  InitMixin(self, LevelsMixin)
         InitMixin(self, InfestationMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.Crag)
           Crag.OnInitialized(self)
    end
    
        function CragSiege:GetTechId()
         return kTechId.Crag
    end
   function CragSiege:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Crag
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

function Crag:GetCragsInRange()
      local crag = GetEntitiesWithinRange("Crag", self:GetOrigin(), Crag.kHealRadius)
           return Clamp(#crag, 0, 3)
end
function Crag:GetBonusAmt()
return (self:GetCragsInRange()/10)
end
function Crag:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Crag (%sS %sB)"), self:GetCragsInRange(), self:GetBonusAmt() )
return unitName
end
local origbuttons = Crag.GetTechButtons
function CragSiege:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[3] = kTechId.CragUmbra
 
 return table

end
local origact = Crag.PerformActivation
function CragSiege:PerformActivation(techId, position, normal, commander)
origact(self, techId, position, normal, commander)

local success  = false
   if  techId == kTechId.CragUmbra then
    success = self:TriggerUmbra()
end

return success, true

end



function CragSiege:TriggerUmbra()

    local umbra = CreateEntity(CragUmbra.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    umbra:SetTravelDestination(self:GetOrigin() + Vector(0, 2, 0) )
    self:TriggerEffects("crag_trigger_umbra")
    return true
end



function CragSiege:TryHeal(target)

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
function CragSiege:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Minigun") then
    
        damageTable.damage = damageTable.damage * 0.9
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end

function CragSiege:OnOrderGiven()
   if self:GetInfestationRadius() ~= 0 then self:SetInfestationRadius(0) end
end
Shared.LinkClassToMap("CragSiege", CragSiege.kMapName, networkVars)



