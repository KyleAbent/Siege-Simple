--Kyle 'Avoca' Abent
Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/SaltMixin.lua")

RoboticsFactory.kRolloutLength = 1

local networkVars = 

{
    automaticspawningmac = " boolean",
    automaticspawningarc = " boolean",

}
AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(SaltMixin, networkVars)
local origcreate = RoboticsFactory.OnCreate
function RoboticsFactory:OnCreate()
origcreate(self)
self.automaticspawningarc = false
self.automaticspawningmac = false
end
local originit = RoboticsFactory.OnInitialized
function RoboticsFactory:OnInitialized()
        InitMixin(self, LevelsMixin)
        InitMixin(self, SaltMixin)
originit(self)
end

function RoboticsFactory:GetMinRangeAC()
return RoboAutoCCMR    
end

function RoboticsFactory:GetTechButtons(techId)

    local techButtons = {  kTechId.None, kTechId.None, kTechId.DropMAC, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
         
       if self:GetMacsAmount() <=12 then
       techButtons[2] = kTechId.MAC
       end
      
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
        techButtons[5] = kTechId.UpgradeRoboticsFactory
    else
    
     --  if self:GetArcsAmount() <=12 then
       techButtons[1] = kTechId.ARC
      -- end
       
    end           

   
    
   if not self.automaticspawningmac and not self.automaticspawningarc then 
      techButtons[6] = kTechId.MacSpawnOn
   elseif self.automaticspawningmac then
      techButtons[6] = kTechId.MacSpawnOff
end
       if not  self.automaticspawningarc then 
      techButtons[7] = kTechId.ArcSpawnOn
   elseif self.automaticspawningarc then
      techButtons[7] = kTechId.ArcSpawnOff
    end
    
    return techButtons
    
end

function RoboticsFactory:GetArcsAmount()
    local arcs = 0
        for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
              if not arc:isa("ARCCredit") then arcs = arcs + 1 end
         end
    return  arcs
end
function RoboticsFactory:GetMacsAmount()
    local macs = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                if not mac:isa("MACCredit") then macs = macs + 1 end
         end
    return  macs
end
if Server then

function RoboticsFactory:MacSpawnFormula()

      if self.automaticspawningmac == true and self:GetTeam():GetTeamResources() >= kMACCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.MAC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetMacsAmount() <= 11 then
            self:OverrideCreateManufactureEntity(kTechId.MAC)
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kMACCost )
        end
        
        return self.automaticspawningmac == true

end
function RoboticsFactory:ArcSpawnFormula()
      if  self.automaticspawningarc and self:GetTeam():GetTeamResources() >= kARCCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.ARC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetArcsAmount() <= 12 - 1 then
        
            self:OverrideCreateManufactureEntity(kTechId.ARC)
            //self.spawnedFreeMAC = true
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kARCCost )
        end
        return  self.automaticspawningarc == true
end

end
 function RoboticsFactory:PerformActivation(techId, position, normal, commander)
 
     local success = false
    if techId == kTechId.MacSpawnOn then
     self:MacSpawnFormula()
            self.automaticspawningmac = true
    self:AddTimedCallback(RoboticsFactory.MacSpawnFormula, 10)
    elseif techId == kTechId.MacSpawnOff then
       self.automaticspawningmac = false
    end
    if techId == kTechId.ArcSpawnOn then
          self.automaticspawningarc = true
          self:ArcSpawnFormula()
            self:AddTimedCallback(RoboticsFactory.ArcSpawnFormula, 10)
    elseif techId == kTechId.ArcSpawnOff then
              self.automaticspawningarc = false
    end
        return success, true
end
    
    
        function RoboticsFactory:GetMaxLevel()
    return kDefaultLvl
    end
    function RoboticsFactory:GetAddXPAmount()
    return kDefaultAddXp
    end
 
Shared.LinkClassToMap("RoboticsFactory", RoboticsFactory.kMapName, networkVars)
