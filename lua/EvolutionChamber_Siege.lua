if Server then

--local orig_EvolutionChamber_OnResearchComplete = EvolutionChamber.OnResearchComplete
function EvolutionChamber:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
  UpdateAliensWeaponsManually() 
  --return orig_EvolutionChamber_OnResearchComplete(self, researchId) 
end

end