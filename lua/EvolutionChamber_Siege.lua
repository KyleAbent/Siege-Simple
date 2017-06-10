


if Server then

--local orig_EvolutionChamber_OnResearchComplete = EvolutionChamber.OnResearchComplete
function EvolutionChamber:OnResearchComplete(researchId)
--Print("HiveOnResearchComplete")
  UpdateAliensWeaponsManually() 
  --return orig_EvolutionChamber_OnResearchComplete(self, researchId) 
end

end
EvolutionChamber.kUpgradeButtons ={                            
    [kTechId.SkulkMenu] = { kTechId.Leap, kTechId.Xenocide, kTechId.SkulkXenoRupture, kTechId.None,
                                kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                             
    [kTechId.GorgeMenu] = { kTechId.BileBomb, kTechId.WebTech, kTechId.None, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                                 
    [kTechId.LerkMenu] = { kTechId.Umbra, kTechId.Spores, kTechId.None, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                                 
    [kTechId.FadeMenu] = { kTechId.MetabolizeEnergy, kTechId.MetabolizeHealth, kTechId.Stab, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                                 
    [kTechId.OnosMenu] = { kTechId.Charge, kTechId.BoneShield, kTechId.Stomp, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None }
}

function EvolutionChamber:GetTechButtons(techId)

    local techButtons = { kTechId.SkulkMenu, kTechId.GorgeMenu, kTechId.LerkMenu, kTechId.FadeMenu,
                                kTechId.OnosMenu, kTechId.None, kTechId.None, kTechId.None }
    
    local returnButton = kTechId.Return
    if self.kUpgradeButtons[techId] then
        techButtons = self.kUpgradeButtons[techId]
        returnButton = kTechId.RootMenu
    end
    
	techButtons[8] = returnButton
	
    if self:GetIsResearching() then
        techButtons[7] = kTechId.Cancel
    else
        techButtons[7] = kTechId.None
    end
    
    return techButtons
    
end