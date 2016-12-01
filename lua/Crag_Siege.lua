--Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")

class 'CragAvoca' (Crag)
CragAvoca.kMapName = "cragavoca"

local networkVars = {}

--AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)

    function CragAvoca:OnInitialized()
     Crag.OnInitialized(self)
       --  InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.Crag)
    end
    
        function CragAvoca:GetTechId()
         return kTechId.Crag
    end
   function CragAvoca:OnGetMapBlipInfo()
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

Shared.LinkClassToMap("CragAvoca", CragAvoca.kMapName, networkVars)


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
