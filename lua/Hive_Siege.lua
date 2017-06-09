
function Hive:GetCanBeHealedOverride()
    return not GetSandCastle():GetSDBoolean() and self:GetIsAlive()
end
function Hive:GetAddConstructHealth()
return not  GetSandCastle():GetSDBoolean()
end
local orighive = Hive.GetTechAllowed
function Hive:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player) 
    if techId == kTechId.ResearchBioMassThree then
           allowed = allowed and self.bioMassLevel == 3
           return allowed, canAfford
    end
    return orighive(self, techId, techNode, player)
    
end

local origbuttons = Hive.GetTechButtons
function Hive:GetTechButtons(techId)

local buttons = origbuttons(self, techId)

    if self.bioMassLevel == 3 then
        buttons[2] = kTechId.ResearchBioMassThree
    end
    
     buttons[3] = kTechId.WhipStealFT
    return buttons
end

if Server then


local orig_Hive_OnConstructionComplete = Hive.OnConstructionComplete
function Hive:OnConstructionComplete()


   if GetImaginator():GetAlienEnabled() then
   self.bioMassLevel = 3
   UpdateTypeOfHive(self)
   else
   self.bioMassLevel = 1
    end
   
end


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
        alien:UpdateHealthAmountManual(self.bioMassLevel)
    end

end

local orig_Hive_OnResearchComplete = Hive.OnResearchComplete
function Hive:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
  UpdateAliensWeaponsManually() 
    if researchId == kTechId.UpgradeToCragHive or researchId == kTechId.UpgradeToShadeHive or researchId ==  kTechId.UpgradeToShiftHive then
        self:AddTimedCallback(Hive.CheckForDoubleUpG, 4) 
      --  Print("Started Callback Hive CheckForDoubleUpG")
     end   
   --for now just updtate alien hp on all research completes b/c i dont feel like filtering the biomass -.-
       IfBioMassThenAdjustHp(self)
  return orig_Hive_OnResearchComplete(self, researchId) 
end

end