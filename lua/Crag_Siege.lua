Script.Load("lua/Additions/DigestCommMixin.lua")
Script.Load("lua/Additions/SaltMixin.lua")
Script.Load("lua/InfestationMixin.lua")
local networkVars = {}
AddMixinNetworkVars(DigestCommMixin, networkVars)
AddMixinNetworkVars(SaltMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)

local origcreate = Crag.OnCreate
function Crag:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
        InitMixin(self, SaltMixin)
 end
 local originit = Crag.OnInitialized
function Crag:OnInitialized()
originit(self)
InitMixin(self, InfestationMixin)
end
   function Crag:GetInfestationRadius()
    if self:GetIsACreditStructure() then
    return 1
    else
    return 0
    end
end
function Crag:GetCragsInRange()
      local crag = GetEntitiesWithinRange("Crag", self:GetOrigin(), Crag.kHealRadius)
           return Clamp(#crag, 0, 7)
end
function Crag:GetBonusAmt()
return (self:GetCragsInRange()/10)
end
function Crag:GetMinRangeAC()
return CragAutoCCMR 
end
function Crag:GetCanShiftCallRec()
 return self:GetIsBuilt()
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
 table[8] = kTechId.DigestComm
 
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

local origsppeed = Crag.GetMaxSpeed
function Crag:GetMaxSpeed()
    local speed = origsppeed(self)
         -- Print("1 speed is %s", speed)
      --    speed = Clamp( (speed * kALienCragWhipShadeShiftDynamicSpeedBpdB) * GetRoundLengthToSiege(), speed, speed * kALienCragWhipShadeShiftDynamicSpeedBpdB)   --- buff when siege is open
          --Print("2 speed is %s", speed)
    return speed * 1.25
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




Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)