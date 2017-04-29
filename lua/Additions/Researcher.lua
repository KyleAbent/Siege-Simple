--Kyle 'Avoca' Abent

class 'Researcher' (Entity) 
Researcher.kMapName = "researcher"


local networkVars = 
{
  marineenabled = "boolean",
  alienenabled = "boolean",
}
local function TresCheck(team, cost)
if team == 1 then
if GetGamerules().team1:GetTeamResources() >= cost then return true end
elseif team == 2 then
if GetGamerules().team2:GetTeamResources() >= cost then return true end
end

return false
end
function Researcher:GetIsMapEntity()
return true
end
function Researcher:OnCreate() 

   for i = 1, 4 do
     Print("Researcher created")
   end
   
   self.marineenabled = false
   self.alienenabled = false
   self:SetUpdates(true)
end
function Researcher:SetAlienEnabled(boolean)

self.alienenabled = boolean
local team2Commander = GetGamerules().team2:GetCommander() 
         if boolean == true and not team2Commander then
                 for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                      UpdateTypeOfHive(hive)
                      hive.bioMassLevel = 3
               end
          end

end
local function NotBeingResearched(techId, who)   

 if techId ==  kTechId.AdvancedArmoryUpgrade or techId == kTechId.UpgradeRoboticsFactory then return true end
  
for _, structure in ientitylist(Shared.GetEntitiesWithClassname( string.format("%s", who:GetClassName()) )) do
         if structure:GetIsResearching() and structure:GetClassName() == who:GetClassName() and structure:GetResearchingId() == techId then return false end
     end
    return true
end
--help from commanderbrain.lua
local function ResearchEachTechButton(who)
local techIds = who:GetTechButtons() or {}
                       for _, techId in ipairs(techIds) do
                     if techId ~= kTechId.None then
                        if who:GetCanResearch(techId) then
                          local tree = GetTechTree(who:GetTeamNumber())
                         local techNode = tree:GetTechNode(techId)
                          assert(techNode ~= nil)
                          
                            if tree:GetTechAvailable(techId) then
                             local cost = 0--LookupTechData(techId, kTechDataCostKey) * 
                                if  NotBeingResearched(techId, who) and TresCheck(1,cost) then 
                                  who:SetResearching(techNode, who)
                                  break -- Because having 2 armslabs research at same time voids without break. So lower timer 16 to 4
                                --  who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
                                 end
                             end
                         end
                      end
                  end
end
function Researcher:DelayedActivation() 

            
    -- local team1Commander = GetGamerules().team1:GetCommander()
     self.marineenabled = false --not team1Commander
    -- local team2Commander = GetGamerules().team1:GetCommander()
     self.alienenabled = false --not team2Commander
     
       
return false 

end
function Researcher:GetMarineEnabled()
return self.marineenabled
end
function Researcher:GetAlienEnabled()
return self.alienenabled
end
function Researcher:OnRoundStart() 

   for i = 1, 4 do
     Print("Researche Begin")
   end
   
              if Server then
              self:AddTimedCallback(Researcher.DelayedActivation, 16)
            end
         
end
function Researcher:OnUpdate(deltatime)
 if Server then
   if not self.timeLastAutomations or self.timeLastAutomations + math.random(4,8) <= Shared.GetTime() then
     local gamestarted = GetGamerules():GetGameState() == kGameState.Started 
     local team1Commander = GetGamerules().team1:GetCommander()
      
               if gamestarted  and self.marineenabled and not team1Commander then
                   for _, researchable in ipairs(GetEntitiesWithMixinForTeam("Research", 1)) do
                      if not researchable:isa("RoboticsFactory") then ResearchEachTechButton(researchable)  end
                   end
                end
                
                
              local team2Commander = GetGamerules().team2:GetCommander()
              if gamestarted and self.alienenabled and not team2Commander then  self:UpdateHivesManually()  end 
             self.timeLastAutomations = Shared.GetTime()
             return true
              end          
  end       
end

function Researcher:SetResearchification(boolean, team)

  if team == 1 then
  self.marineenabled = boolean
  end


end
local function HiveResearch(who)
if not who or GetGameInfoEntity():GetWarmUpActive() then return true end
if who:GetIsResearching() then return true end
local tree = who:GetTeam():GetTechTree()
local technodes = {}

    for _, node in pairs(tree.nodeList) do
           local canRes = tree:GetHasTech(node:GetPrereq1()) and tree:GetHasTech(node:GetPrereq2())
           local cost = math.random(1,4) --node.cost
         if canRes and TresCheck(2, cost) and node:GetIsResearch() and node:GetCanResearch() then
                who:GetTeam():SetTeamResources(who:GetTeam():GetTeamResources() - cost)
                node:SetResearched(true)
                tree:SetTechNodeChanged(node, string.format("hasTech = %s", ToString(true)))
         end
    
    end              
                  return true


end
function Researcher:UpdateHivesManually()
       local  hivecount = 0
       local isSetup = not GetSetupConcluded()
       local hasOneBuilt = false
                 for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                  
                     if hive:GetIsBuilt() then 
                         hivecount = hivecount + 1 
                         hasOneBuilt = true
                         if not isSetup or hivecount == 3 then
                         HiveResearch(hive) 
                         end
                     end
               end
          
          
      if  hasOneBuilt and hivecount < 3 and TresCheck(2,40) then
          for _, techpoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
             if techpoint:GetAttached() == nil then 
               local hive =  techpoint:SpawnCommandStructure(2) 
                  if hive then hive:GetTeam():SetTeamResources(hive:GetTeam():GetTeamResources() - 40) break end
             end
          end
     end
     return true
end

Shared.LinkClassToMap("Researcher", Researcher.kMapName, networkVars)