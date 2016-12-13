 /*
local orig_MarineTeam_Initialize = MarineTeam.Initialize
function MarineTeam:Initialize(teamName, teamNumber)
orig_MarineTeam_Initialize(self, teamName, teamNumber)
   self.respawnEntity = MarineAvoca.kMapName
end
*/

local orig_MarineTeam_InitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_MarineTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
    self.techTree:AddTargetedActivation(kTechId.DropExosuit,     kTechId.ExosuitTech, kTechId.None)
    -- self.techTree:AddTargetedBuyNode(kTechId.JumpPack,            kTechId.JetpackTech,         kTechId.None)
     self.techTree:AddResearchNode(kTechId.AdvBeacTech,          kTechId.PhaseTech) 
     self.techTree:AddActivation(kTechId.AdvancedBeacon, kTechId.AdvBeacTech) 
    self.techTree:AddActivation(kTechId.MacSpawnOn,                kTechId.RoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.MacSpawnOff,                kTechId.RoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.ArcSpawnOn,                kTechId.ARCRoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.ArcSpawnOff, kTechId.ARCRoboticsFactory, kTechId.None)
    self.techTree:AddBuildNode(kTechId.BackupLight,            kTechId.None,                kTechId.None)
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end
