--Kyle 'Avoca' Abent
Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
class 'RoboSiege' (RoboticsFactory)
RoboSiege.kMapName = "robosiege"

local networkVars = 

{
    automaticspawningarc = " boolean",

}
AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
function RoboSiege:OnCreate()
RoboticsFactory.OnCreate(self)
self.automaticspawningarc = false
end

function RoboSiege:OnInitialized()
RoboticsFactory.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
if self:GetTechId() ~= kTechId.ARCRoboticsFactory then self:SetTechId(kTechId.RoboticsFactory) end
end

function RoboSiege:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.RoboticsFactory
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

function RoboSiege:GetTechButtons(techId)

    local techButtons = {  kTechId.None, kTechId.DropMAC, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
        techButtons[5] = kTechId.UpgradeRoboticsFactory
    else
    
     --  if self:GetArcsAmount() <=12 then
       techButtons[1] = kTechId.ARC
      -- end
       
    end           

   
    
       if not  self.automaticspawningarc then 
      techButtons[7] = kTechId.ArcSpawnOn
   elseif self.automaticspawningarc then
      techButtons[7] = kTechId.ArcSpawnOff
    end
    
    return techButtons
    
end

function RoboSiege:GetArcsAmount()
    local arcs = 0
        for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
              if not arc:isa("ARCCredit") then arcs = arcs + 1 end
         end
    return  arcs
end
if Server then


function RoboSiege:ArcSpawnFormula()
      if  self.automaticspawningarc and self:GetTeam():GetTeamResources() >= kARCCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.ARC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetArcsAmount() <= 12 - 1 then
        
            self:OverrideCreateManufactureEntity(kTechId.ARC)
            //self.spawnedFreeMAC = true
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kARCCost )
        end
        return  self.automaticspawningarc == true
end

end
 function RoboSiege:PerformActivation(techId, position, normal, commander)
 
     local success = false
    if techId == kTechId.ArcSpawnOn then
          self.automaticspawningarc = true
          self:ArcSpawnFormula()
            self:AddTimedCallback(RoboSiege.ArcSpawnFormula, 10)
    elseif techId == kTechId.ArcSpawnOff then
              self.automaticspawningarc = false
    end
        return success, true
end
    
    
        function RoboSiege:GetMaxLevel()
    return kDefaultLvl
    end
    function RoboSiege:GetAddXPAmount()
    return kDefaultAddXp
    end
 
Shared.LinkClassToMap("RoboSiege", RoboSiege.kMapName, networkVars)
