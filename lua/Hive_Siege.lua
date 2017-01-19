local orighive = Hive.GetTechAllowed
function Hive:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player) 
    if techId == kTechId.ResearchBioMassThree then
           allowed = allowed and self.bioMassLevel == 3
           return allowed, canAfford
    end
    return orighive(self, techId, techNode, player)
    
end




if Server then

function Hive:CheckForDoubleUpG()  --CONSTANT issue of Double hives. Meaning no upgs. Ruining games after time spent seeding server.
 
--Print("Hive:CheckForDoubleUpG()")

for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do 
        --  Print("FoundHive")
        if hive ~= self and self:GetTechId() ~= kTechId.Hive and hive:GetTechId() == self:GetTechId() then
         self:SetTechId(kTechId.Hive)
       --  Print("Found DBL UPG hive and set tech id to hive")
         break
        end
end

end
/*
local orig_Hive_OnKill = Hive.OnKill
function Hive:OnKill(attacker, doer, point, direction)
    orig_Hive_OnKill(self, attacker, doer, point, direction)
UpdateAliensWeaponsManually()
end
*/
local function IfBioMassThenAdjustHp(self)


    local shellLevel = GetShellLevel(self:GetTeamNumber())  
    for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
        alien:UpdateArmorAmountManual(shellLevel)
        alien:UpdateHealthAmountManual(math.min(12, self.bioMassLevel), self.maxBioMassLevel)
    end

end

local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
 self:AddTimedCallback(function() UpdateAliensWeaponsManually()  end, .8) 
    if researchId == kTechId.UpgradeToCragHive or researchId == kTechId.UpgradeToShadeHive or researchId ==  kTechId.UpgradeToShiftHive then
        self:AddTimedCallback(Hive.CheckForDoubleUpG, 4) 
      --  Print("Started Callback Hive CheckForDoubleUpG")
     end   
   --for now just updtate alien hp on all research completes b/c i dont feel like filtering the biomass -.-
       IfBioMassThenAdjustHp(self)
  return orig_Hive_OnResearchComplete(self, researchId) 
end

end