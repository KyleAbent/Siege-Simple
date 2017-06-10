


if Server then

--local orig_EvolutionChamber_OnResearchComplete = EvolutionChamber.OnResearchComplete
function EvolutionChamber:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
  UpdateAliensWeaponsManually() 
  --return orig_EvolutionChamber_OnResearchComplete(self, researchId) 
end

end
/*
local origbuttons = EvolutionChamber.GetTechButtons
function EvolutionChamber:GetTechButtons(techId)

local buttons = origbuttons(self, techId)
   -- Print("techId is %s", techId)
   if techId == kTechId.SkulkMenu then
      buttons[3] = kTechId.SkulkXenoRupture
   end
   return buttons
   

end
*/