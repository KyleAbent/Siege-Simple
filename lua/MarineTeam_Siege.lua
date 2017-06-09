local orig_MarineTeam_GetHasAbilityToRespawn = MarineTeam.GetHasAbilityToRespawn

function MarineTeam:GetHasAbilityToRespawn()
   local orig = orig_MarineTeam_GetHasAbilityToRespawn(self)
   if GetSandCastle():GetSDBoolean() then return false end
   return orig
end

local orig_MarineTeam_InitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_MarineTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
    self.techTree:AddBuildNode(kTechId.DropMAC,     kTechId.None, kTechId.None)
     self.techTree:AddBuildNode(kTechId.Wall,     kTechId.None, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropExosuit,     kTechId.ExosuitTech, kTechId.None)
    -- self.techTree:AddResearchNode(kTechId.AdvBeacTech,          kTechId.PhaseTech) 
     self.techTree:AddActivation(kTechId.AdvancedBeacon, kTechId.None) 
    self.techTree:AddActivation(kTechId.MacSpawnOn,                kTechId.RoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.MacSpawnOff,                kTechId.RoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.ArcSpawnOn,                kTechId.ARCRoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.ArcSpawnOff, kTechId.ARCRoboticsFactory, kTechId.None)
    self.techTree:AddBuildNode(kTechId.BackupLight,            kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.DualWelderExosuit, kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddBuyNode(kTechId.DualFlamerExosuit, kTechId.ExosuitTech, kTechId.None)
   self.techTree:AddTargetedBuyNode(kTechId.JumpPack, kTechId.JetpackTech, kTechId.None)
 -- self.techTree:AddTargetedBuyNode(kTechId.ConcGrenade, kTechId.GrenadeTech, kTechId.None)
      self.techTree:AddUpgradeNode(kTechId.ElectrifyStructure,  kTechId.None)
      
       self.techTree:AddActivation(kTechId.SiegeBeacon,           kTechId.Observatory)  
       

    
       self.techTree:AddTargetedBuyNode(kTechId.Resupply,            kTechId.None,         kTechId.None) 
       self.techTree:AddTargetedBuyNode(kTechId.LightArmor,            kTechId.None,         kTechId.None) 
       self.techTree:AddTargetedBuyNode(kTechId.HeavyArmor,            kTechId.None,         kTechId.None) 
       self.techTree:AddTargetedBuyNode(kTechId.FireBullets,            kTechId.None,         kTechId.None) 
       self.techTree:AddTargetedBuyNode(kTechId.RegenArmor,            kTechId.None,         kTechId.None) 
       self.techTree:AddTargetedBuyNode(kTechId.WallWalk,            kTechId.None,         kTechId.None) 
       
       
       
    self.techTree:AddActivation(kTechId.PGchannelOne,           kTechId.None)  
    self.techTree:AddActivation(kTechId.PGchannelTwo,           kTechId.None) 
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end
