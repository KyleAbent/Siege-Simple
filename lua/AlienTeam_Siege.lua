--Rewiring to add biomass 10,11,12. .. is messy.

local orig_AlienTeam_GetHasAbilityToRespawn = AlienTeam.GetHasAbilityToRespawn
function AlienTeam:GetHasAbilityToRespawn()
   local orig = orig_AlienTeam_GetHasAbilityToRespawn(self)
   if GetSandCastle():GetSDBoolean() then return false end
   return orig
end

function AlienTeam:GetMaxBioMassLevel()
    return 12
end

local orig_ = AlienTeam.AssignPlayerToEgg
function AlienTeam:AssignPlayerToEgg(player, enemyTeamPosition)
 if GetSandCastle():GetSDBoolean() then return false end
orig_(self, player, enemyTeamPosition)

end
function AlienTeam:GetHive()
    for _, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
        if hive:GetIsBuilt() then
        
           return hive
        end

    end
    return nil
end

local orig_AlienTeam_InitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_AlienTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
 --self.techTree:AddBuildNode(kTechId.CommVortex, kTechId.ShadeHive)
 self.techTree:AddActivation(kTechId.CragUmbra, kTechId.CragHive, kTechId.None) 
 --self.techTree:AddActivation(kTechId.WhipExplode, kTechId.BioMassNine, kTechId.None) 
 self.techTree:AddActivation(kTechId.ShiftEnzyme, kTechId.BioMassNine, kTechId.None) 
 self.techTree:AddActivation(kTechId.ShadeHallucination, kTechId.BioMassNine, kTechId.None) 
 self.techTree:AddTargetedActivation(kTechId.TunnelTeleport, kTechId.ShiftHive, kTechId.None) 
 
     self.techTree:AddActivation(kTechId.ShiftReceive,                kTechId.ShiftHive,          kTechId.None)
    self.techTree:AddActivation(kTechId.ShiftCall,                kTechId.ShiftHive,          kTechId.None)
   
self.techTree:AddBuildNode(kTechId.EggBeacon, kTechId.CragHive)
self.techTree:AddBuildNode(kTechId.CommTunnel, kTechId.None)
self.techTree:AddBuildNode(kTechId.StructureBeacon, kTechId.ShiftHive)
self.techTree:AddPassive(kTechId.PrimalScream,              kTechId.Spores, kTechId.None, kTechId.AllAliens)

--self.techTree:AddPassive(kTechId.OnoGrow,              kTechId.None, kTechId.None, kTechId.AllAliens)

self.techTree:AddPassive(kTechId.AcidRocket, kTechId.Stab, kTechId.None, kTechId.AllAliens) -- though linking 

self.techTree:AddPassive(kTechId.LerkBileBomb, kTechId.Spores, kTechId.None, kTechId.AllAliens)

   
    self.techTree:AddPassive(kTechId.CragHiveTwo, kTechId.CragHive)
  --  self.techTree:AddPassive(kTechId.ShiftHiveTwo, kTechId.ShiftHive)
 self.techTree:AddBuyNode(kTechId.Rebirth, kTechId.Shell, kTechId.None, kTechId.AllAliens)
   self.techTree:AddBuyNode(kTechId.Redemption, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    --self.techTree:AddBuyNode(kTechId.Hunger, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    --self.techTree:AddBuyNode(kTechId.ThickenedSkin, kTechId.Spur, kTechId.None, kTechId.AllAliens)
    --self.techTree:AddBuyNode(kTechId.DamageResistance, kTechId.Spur, kTechId.None, kTechId.AllAliens)
        --self.techTree:AddResearchNode(kTechId.WhipStealFT,  kTechId.BioMassNine) 
--        self.techTree:AddResearchNode(kTechId.ContamEggBeacon,  kTechId.BioMassNine) 
        
        
    self.techTree:AddUpgradeNode(kTechId.DigestComm, kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.SkulkXenoRupture, kTechId.BioMassNine, kTechId.None)
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end


