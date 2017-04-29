--Kyle 'Avoca' Abent



class 'Imaginator' (ScriptActor) 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
 alienenabled = "boolean",
 marineenabled = "boolean",
}



local function BuildPowerNodes()
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                       if not powerpoint:GetIsSocketed() then powerpoint:SetConstructionComplete()  powerpoint:Kill() end
             end
end
local function Socket()
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                       if not powerpoint:GetIsSocketed() and not GetIsInSiege(powerpoint) then 
                        if not string.find(Shared.GetMapName(), "pl_")  then
                         powerpoint:SetConstructionComplete()
                        local resnodes = GetEntitiesWithinRange( "ResourcePoint", powerpoint:GetOrigin(), 18 )
                         if #resnodes >= 4 then 
                        powerpoint:Kill()
                         end
                       else
                          powerpoint:SocketPowerNode()
                       end
                     end
             end
end
local function ChangeBuiltNodeLightsDiscolulz()
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                    if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then   powerpoint:SetLightMode(kLightMode.MainRoom) end
             end
end
function Imaginator:OnCreate() 
/*
   for i = 1, 4 do
     Print("Imaginator created")
   end
   */
   self.marineenabled = false
   self.alienenabled = false
   self:SetUpdates(true)
end
function Imaginator:GetMarineEnabled()
local boolean = self.marineenabled
Print("Imaginator GetMarineEnabled is %s", boolean)
return boolean

end
function Imaginator:GetAlienEnabled()
local boolean = self.alienenabled
return boolean
end
function Imaginator:OnInitialized()

end
function Imaginator:GetIsMapEntity()
return true
end
function Imaginator:GetIsMarineEnabled()
if self.marineenabled then return true end
return false
end
function Imaginator:OnUpdate(deltatime)
   
   if Server then
                 if not  self.timeLastAutomations or self.timeLastAutomations + math.random(4, 8) <= Shared.GetTime() then
                 self.timeLastAutomations = Shared.GetTime()
        self:Automations()
         end
            if not  self.timeLastImaginations or self.timeLastImaginations + math.random(4,8) <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
        self:Imaginations()
         end
            if not  self.timeLastCystTimer or self.timeLastCystTimer + 1 <= Shared.GetTime() then
            self.timeLastCystTimer = Shared.GetTime()
         self:CystTimer()
         end
         
         
         end
   
end
function Imaginator:OnPreGame()

   for i = 1, 4 do
     Print("Imaginator OnPreGame")
   end
   
   
end
function Imaginator:DelayActivation()
  --local team1Commander = GetGamerules().team2:GetCommander()
  --  local team2Commander = GetGamerules().team2:GetCommander()
  --        self.marineenabled = not team1Commander
  -- self.alienenabled = not team2Commander
  -- return true
  return false
end
function Imaginator:OnRoundStart() 
   for i = 1, 4 do
     Print("Imaginator OnRoundStart")
   end


      self.marineenabled = false
   self.alienenabled = false
  
       self:AddTimedCallback(Imaginator.DelayActivation, 16)
            
end
function Imaginator:SetImagination(boolean, team)



  if team == 1 then
  self.marineenabled = boolean
          --  if boolean == true then
         --       local  BigMac = #GetEntitiesForTeam( "BigMac", 1 )
         --        if not BigMac then  
         --    else
             
         --    end
   
  elseif team == 2 then
  self.alienenabled = boolean
  if self.alienenabled == true then Socket() end --and not GetSandCastle():GetIsFrontOpen() then Socket() end
  end


end
local function GetDisabledPowerPoints()
 local nodes = {}
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                    if powerpoint and  (powerpoint:GetIsDisabled() or ( powerpoint:GetIsSocketed() and not powerpoint:GetIsBuilt() ) )  and not ( not GetSiegeDoorOpen() and GetIsInSiege(powerpoint) ) then
                    table.insert(nodes, powerpoint)
                    end
                    
             end

return nodes

end
local function PowerPointStuff(who, self)
local location = GetLocationForPoint(who:GetOrigin())
local powerpoint =  location and GetPowerPointForLocation(location.name)
  local team1Commander = GetGamerules().team1:GetCommander()
  local team2Commander = GetGamerules().team2:GetCommander()
      if powerpoint ~= nil then 
              if not ( team1Commander and self.marineenabled )  and ( powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() ) then 
                return 1
              end
             if ( not team2Commander and self.alienenabled ) and ( not powerpoint:GetCanTakeDamageOverride() )  then
                  return 2
               end
     end
end
local function WhoIsQualified(who, self)
   return PowerPointStuff(who, self)
end
local function Touch(who, where, what, number)
 local tower = CreateEntityForTeam(what, where, number, nil)
         if tower then
            who:SetAttached(tower)
            if number == 1 then
            tower:SetConstructionComplete()
            end
            return tower
         end
end
local function Envision(self,who, which)
   if which == 1 and self.marineenabled then
     Touch(who, who:GetOrigin(), kTechId.Extractor, 1)
   elseif which == 2 and self.alienenabled then
     Touch(who, who:GetOrigin(), kTechId.Harvester, 2)
    end
end
local function AutoDrop(self,who)
  local which = WhoIsQualified(who, self)
  if which ~= 0 then Envision(self,who, which) end
end
function Imaginator:Automations() 
  local gamestarted = not GetGameInfoEntity():GetWarmUpActive() 
   
     if gamestarted then
              self:AutoBuildResTowers()
                                         --Flaw in killing extract to instantly respawn w. power on.
                                        --Useful in that this method allows extract/harv built instantly. 
                                         --Allowing tres being spending on other stuff unless rewritten in a way to spawn resTower by adding GeatNearest empty Res node within FindPlayer (optional delay after killed)
                                        --and matching the location.
   -- else
   --       BuildPowerNodes()
       --   ChangeBuiltNodeLightsDiscolulz()
      end
      
              return true
end
function Imaginator:GetMarineEnabled()
return self.marineenabled
end
function Imaginator:GetAlienEnabled()
return self.alienenabled
end
function Imaginator:Imaginations() 
  local gamestarted = not  GetGameInfoEntity():GetWarmUpActive()
  local team1Commander = GetGamerules().team1:GetCommander()
  local team2Commander = GetGamerules().team2:GetCommander()
  
            if gamestarted and self.marineenabled and not team1Commander then 
              self:MarineConstructs()
           end
            
            if gamestarted  and self.alienenabled and not team2Commander then
              self:AlienConstructs(false)
           end
           
              return true
end
function Imaginator:CystTimer()
  local gamestarted = GetGamerules():GetGameState() == kGameState.Started
  local team2Commander = GetGamerules().team2:GetCommander()
  
          if gamestarted  and self.alienenabled and not team2Commander then
              self:AlienConstructs(true)
           end
              return true
end
local function InsideLocation(ents, teamnum)
local origin = nil
  if #ents == 0  then return origin end
  for i = 1, #ents do
    local entity = ents[i]   
      if teamnum == 2 then
    if entity:isa("Alien") and entity:GetIsAlive() and (entity:GetGameEffectMask(kGameEffect.OnInfestation) ) then return FindFreeSpace(entity:GetOrigin()) end
    elseif teamnum == 1 then
    if entity:isa("Marine") and entity:GetIsAlive() then return FindFreeSpace(entity:GetOrigin()) end
    end 
  end
return origin
  
end
local function changeColorsBack()
      for _, light in ipairs(GetLightsForLocation(location.name)) do
         light:SetColor(light.originalColor)
    end
end

local function FindPosition(location, powerpoint, teamnum)
  if #location == 0  then return nil end
  local origin = nil
  
    for i = 1, #location do
    local location = location[i]   
      local ents = location:GetEntitiesInTrigger()
      local potential = InsideLocation(ents, teamnum)
      if potential ~= nil then origin = potential  return origin end 
  end
  
  //else
  
    //  for _, light in ipairs(GetLightsForLocation(location.name)) do
    //  return light.originalCoords.origin 
    //end
   -- self:AddTimedCallback(function() changeColorsBack(location) end, math.random(4,8) )

    return origin   
 
end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLengthXZ()
    return ArcFormula
end


local function GetSentryMinRangeReq(where)
local count = 0
            local ents = GetEntitiesForTeamWithinRange("Sentry", 1, where, 16)
            for index, ent in ipairs(ents) do
                  count = count + 1
           end
           
           count = Clamp(count, 1, 4)
           
           return count*8
                
end
local function GetWhipMinRangeReq(where)
local count = 0
            local ents = GetEntitiesForTeamWithinRange("Whip", 1, where, 16)
            for index, ent in ipairs(ents) do
                  count = count + 1
           end
           
           count = Clamp(count, 1, 4)
           
           return count*16
                
end
local function GetHasAdvancedArmory()
    for index, armory in ipairs(GetEntitiesForTeam("Armory", 1)) do
       if armory:GetTechId() == kTechId.AdvancedArmory then return true end
    end
    return false
end
local function GetHasThreeChairs()
local CommandStations = #GetEntitiesForTeam( "CommandStation", 1 )

if CommandStations >= 3 then return true end

return false
end
local function GetIsACreditStructure(who)
local boolean = who.GetIsACreditStructure and who:GetIsACreditStructure() or false
--Print("isacredit structure is %s", boolean)
return boolean

end
local function OrganizedIPCheck(who)

-- One entity at a time
local count = 0
local ips = GetEntitiesForTeamWithinRange("InfantryPortal", 1, who:GetOrigin(), kInfantryPortalAttachRange)
 --ADd in getisactive
      --Add in arms lab because having these spread through the map is a bit odd.
      local armscost = LookupTechData(kTechId.ArmsLab, kTechDataCostKey)
      local  ArmsLabs = GetEntitiesForTeam( "ArmsLab", 1 )
      
      if #ArmsLabs >= 1 then 
      
      for i = 1, #ArmsLabs do
          local ent = ArmsLabs[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
          table.remove(ArmsLabs, ent)
          end
      end
      
      end
      
      if #ArmsLabs < 2 and TresCheck(1, armscost) then
               local origin = FindFreeSpace(who:GetOrigin(), 1, kInfantryPortalAttachRange)
               local armslab = CreateEntity(ArmsLab.kMapName, origin,  1)
              armslab:GetTeam():SetTeamResources(armslab:GetTeam():GetTeamResources() - armscost)
              return --one at a time
      end
      

            for index, ent in ipairs(ips) do
              if ent:GetIsPowered() and not GetIsACreditStructure(ent) then
                  count = count + 1
               end   
           end
           
           if count >= 2 then return end
           
         --  for i = 1, math.abs( 2 - count ) do --one at a time
           local cost = 20
               if TresCheck(1, cost) then 
               local origin = FindFreeSpace(who:GetOrigin(), 1, kInfantryPortalAttachRange)
               local ip = CreateEntity(InfantryPortal.kMapName, origin,  1)
              ip:GetTeam():SetTeamResources(ip:GetTeam():GetTeamResources() - cost)
            --  end
           end
           
              
           
end
local function HaveCCsCheckIps()
   local CommandStations = GetEntitiesForTeam( "CommandStation", 1 )
       if not CommandStations then return end
        OrganizedIPCheck(table.random(CommandStations))
end
local function GetMarineSpawnList()
local tospawn = {}
local canafford = {}
local cost = 1 
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true HaveCCsCheckIps() end
      table.insert(tospawn, kTechId.PhaseGate)
      table.insert(tospawn, kTechId.Armory)
      table.insert(tospawn, kTechId.Observatory)
     -- table.insert(tospawn, kTechId.Scan)
      table.insert(tospawn, kTechId.RoboticsFactory)
      table.insert(tospawn, kTechId.Observatory)
      
   -- local  AdvancedArmory = #GetEntitiesForTeam( "AdvancedArmory", 1 )
     
        --  if AdvancedArmory => 1 then
            --if GetHasAdvancedArmory() then
            table.insert(tospawn, kTechId.PrototypeLab)
           -- end
    --  end
      

      table.insert(tospawn, kTechId.Sentry)
      
      
      --local  InfantryPortal = #GetEntitiesForTeam( "InfantryPortal", 1 )
      local  CommandStation = #GetEntitiesForTeam( "CommandStation", 1 )
      


      
      --if InfantryPortal < 4 then
      --table.insert(tospawn, kTechId.InfantryPortal)
      --end
      
      if CommandStation < 3 then
      table.insert(tospawn, kTechId.CommandStation)
      end
      
    
       for _, techid in pairs(tospawn) do
       local cost = Clamp(LookupTechData(techid, kTechDataCostKey), 1, 10)
         --if techid == kTechId.CommandStation then cost = cost * .5 end
           if not gamestarted or TresCheck(1,cost) then
             table.insert(canafford, techid)
           end
    end
     
     --if TresCheck(4) then
     --table.insert(tospawn, SentryBattery.kMapName)
     -- end
                                                                            --Extra weight to help prioritize without rewriting much
      local finalchoice = table.random(canafford) 

     if table.find(canafford, kTechId.CommandStation) and math.random(1,100) <= 30  then
        finalchoice = kTechId.CommandStation
     end

      local finalcost = not gamestarted and 0
      finalcost = LookupTechData(finalchoice, kTechDataCostKey) 
      --Print("GetMarineSpawnList() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost, gamestarted
end
--local function BuildArcsMacs()

--end
function Imaginator:MarineConstructs()
       for i = 1, 2 do
         local success = self:ActualFormulaMarine()
         if success == true then return true end
       end
       
    --   BuildArcsMacs()

return true
end
function Imaginator:TriggerNotification(locationId, techId)

    local message = BuildCommanderNotificationMessage(locationId, techId)
    
    -- send the message only to Marines (that implies that they are alive and have a hud to display the notification
    
    for index, marine in ipairs(GetEntitiesForTeam("Player", 1)) do
        Server.SendNetworkMessage(marine, "CommanderNotification", message, true) 
    end

end
local function GetTechId(mapname)
      local thehardway = GetEntitiesWithMixinForTeam("Construct", 1) 
      
      for i = 1, #thehardway do
        local ent = thehardway[i]
         if ent:GetMapName() == mapname then return ent:GetTechId() end
      end
      return nil
end
local function GetActiveAirLock()
  local airlocks = {}
  for _, location in ientitylist(Shared.GetEntitiesWithClassname("Location")) do
        if location:GetIsAirLock() then table.insert(airlocks,location) end
    end
    return table.random(airlocks) 
end
local function GetScanMinRangeReq(where)

            local obs = #GetEntitiesForTeamWithinRange("Observatory", 1, where, kScanRadius)
            
            for i = 1, obs do
             if GetIsUnitActive(obs) then return 999 end
            end
            
            return kScanRadius  
                
end
local function BuildNotificationMessage(where, self, mapname)

end

local function InstructSiegeArcs(self)
             for index, siegearc in ipairs(GetEntitiesForTeam("SiegeArc", 1)) do
                 siegearc:Instruct()
             end
end
local function ManageArcs()
local arc = GetNonBusyArc()
local powerpoints = {}

   for index, powerpoint in ipairs(GetEntitiesForTeam("PowerPoint", 1)) do
       if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() then
           table.insert(powerpoints, powerpoint)
       end
   end
 if arc then
        local where = FindFreeSpace(table.random(powerpoints):GetOrigin(), 4, 8)
        arc:GiveOrder(kTechId.Move, nil, where, nil, true, true)
 end
 
end
local function ManageRoboticFactories()
      local  ARCS = {}
      local ARCRobo = {} --ugh
      
          --Because researcher will spawn macs.
        for index, robo in ipairs(GetEntitiesForTeam("RoboticsFactory", 1)) do
       if  robo:GetTechId() ~= kTechId.ARCRoboticsFactory and robo:GetIsBuilt() and not robo:GetIsResearching() then
           local techid = kTechId.UpgradeRoboticsFactory
          local techNode = robo:GetTeam():GetTechTree():GetTechNode( techid ) 
            robo:SetResearching(techNode, robo)
       end
       if robo:GetTechId() == kTechId.ARCRoboticsFactory then table.insert(ARCRobo, robo) end --ugh
          if robo.open then return true end
     end
     
     
     if ( not GetHasThreeChairs() and not GetFrontDoorOpen() ) then return end
        
          if  table.count(ARCRobo) == 0 then return end
          
                    ARCRobo = table.random(ARCRobo)
      
     local siegearcs = 0
     
     for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
       if not arc:isa("ARCCredit") and not arc:isa("SiegeArc") then table.insert(ARCS,arc) end
       if arc:isa("SiegeArc") then siegearcs = siegearcs + 1 end 
     end
          
          --Not avoca arc because we want these changed to siegearcs when siege is open
     local ArcCount = table.count(ARCS) 
     
     
      if siegearcs < 12 and ArcCount < 12 and TresCheck(1, kARCCost) then
      ARCRobo:GetTeam():SetTeamResources(ARCRobo:GetTeam():GetTeamResources() - kARCCost)
      ARCRobo:OverrideCreateManufactureEntity(kTechId.ARC)
      end

      if string.find(Shared.GetMapName(), "pl_") then
      
      return 
      
      end

      if GetSandCastle():GetIsSiegeOpen() then 

                  --change arcs to siege
                  for index, ent in ipairs(ARCS) do
                   ChangeArcTo(ent, SiegeArc.kMapName)
                   end
                   InstructSiegeArcs(self) 

      return -- Dont want new AvocaArcs during siege
      end

      
      
     local  AvoArc = GetEntitiesForTeam("AvocaArc", 1)
     local AACount = table.count(AvoArc)
     
      if ArcCount  >= 8 and AACount < 4 then

                    local victim = table.random(ARCS)
                    ChangeArcTo(victim, AvocaArc.kMapName)
      
      end
      
   AvoArc = GetEntitiesForTeam("AvocaArc", 1)
   AACount = table.count(AvoArc)
   local chance = math.random(1,4)
   
   if chance == 4 then
   
    if  AACount >= 1 then 
      if  TresCheck(1,3) then --because if they scan, they stop :x and fire
      local randomarc = table.random(AvoArc)
      local origin = randomarc:GetOrigin()
        local scan = CreateEntity(Scan.kMapName, origin, 1)
        randomarc:GetTeam():SetTeamResources(randomarc:GetTeam():GetTeamResources() - 3)
      end
    end
    
  end
      
--yes its funny to delete and create entities on the fly mid game such as this
-- I dont feel like writing enums with seperate modes. Maybe this can be optimized, if fun.

end
local function GetRequirements(tospawn, ent, where)
local boolean_one = ent:GetTechId() == tospawn
local boolean_two = ( ent:GetTechId() == kTechId.AdvancedArmory and tospawn == kTechId.Armory)
local boolean_three = ( ent:GetTechId() == kTechId.ARCRoboticsFactory and tospawn == kTechId.RoboticsFactory)
local boolean_four =  ( HasMixin(ent, "PowerConsumer") and not ent:GetIsPowered() )  or not ent:GetIsBuilt()
local boolean_five = ( ent:GetTechId() == kTechId.Sentry and GetCheckSentryLimit(kTechId.Sentry, where) )
return boolean_one or boolean_two or boolean_three and boolean_four and not boolean_five
end
function Imaginator:ActualFormulaMarine()

      
--Print("ActualFormulaMarine")
local randomspawn = nil
local tospawn, cost, gamestarted = GetMarineSpawnList()
if gamestarted and not string.find(Shared.GetMapName(), "pl_") then ManageRoboticFactories() end ManageArcs() end
local airlock = GetActiveAirLock()
local success = false
local entity = nil
            if airlock and tospawn then
                local powerpoint = GetPowerPointForLocation(airlock.name)
             if powerpoint then
                 local potential = FindPosition(GetAllLocationsWithSameName(airlock:GetOrigin()), powerpoint, 1)
                 if potential == nil then 
                     local roll = math.random(1,3) 
                     if roll == 3 then self:ActualFormulaMarine() return end
                 end
                 randomspawn = FindFreeSpace(potential, math.random(2.5, 8) )
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return GetRequirements(tospawn, ent, randomspawn) end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = nearestof:GetMinRangeAC()
                          if tospawn == kTechId.Scan then minrange = kScanRadius end
                          if range >= minrange  then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                               --BuildNotificationMessage(randomspawn, self, tospawn)
                               success = true
                          end --
                     else -- it tonly takes 1!
                      Print("Nearest not found")
                       entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
                     end
               end   
            end

  return success
  
end
/*
local function HasThreeUpgFor()
GetGamerules().team2
end
*/
local function GetAlienSpawnList(cystonly)

local tospawn = {}
local canafford = {}
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
      
      table.insert(tospawn, kTechId.Shade)
      table.insert(tospawn, kTechId.Shift)
      table.insert(tospawn, kTechId.Whip)
      table.insert(tospawn, kTechId.Crag)
      table.insert(tospawn, kTechId.NutrientMist)
      
      
      
      if cystonly then
      return kTechId.Cyst, 1, gamestarted
      end
      
       for _, techid in pairs(tospawn) do
          local cost = LookupTechData(techid, kTechDataCostKey)
           if not gamestarted or TresCheck(2,cost) then
             table.insert(canafford, techid)   
           end
    end

      local finalchoice = table.random(canafford)
      local finalcost = LookupTechData(finalchoice, kTechDataCostKey)
      finalcost = not gamestarted and 0 or finalcost
      --Print("GetAlienSpawnList() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost, gamestarted
      
end
local function GetBioMassLevel()
           local teamInfo = GetTeamInfoEntity(2)
           local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           return bioMass
end
local function FindPoorVictim()
local airlock = GetActiveAirLock()
local spawnpoint = airlock and airlock:GetRandomMarine() or nil
       return spawnpoint
end
local function IntrepidLocation(airlock)
    local random = math.random(1,2)
    if random == 1 then
     return GetPowerPointForLocation(airlock.name):GetOrigin()
    else
         local marineloc = airlock:GetRandomMarine()
         if marineloc == nil then return GetPowerPointForLocation(airlock.name) else return marineloc end
    end
end
local function ChanceRandomContamination(who) --messy
    --  Print("ChanceRandomContamination")
     gamestarted =  not GetGameInfoEntity():GetWarmUpActive() 
     local chance = GetSiegeDoorOpen() and 50 or math.random(10,30)
     local cost = math.random(3, 5)
     local randomchance = math.random(1, 100)
     if (not gamestarted or TresCheck( 2, cost ) ) and randomchance <= chance then
     local airlock = GetActiveAirLock()
     if not airlock then return end 
       local where = IntrepidLocation(airlock)
             where = FindFreeSpace(where, 4, 24)
           if where then 
               local contamination = CreateEntityForTeam(kTechId.Contamination, FindFreeSpace(where, 4, 8), 2)
                    -- CreatePheromone(kTechId.ExpandingMarker,contamination:GetOrigin(), 2) 
                    contamination:StartBeaconTimer()
            if gamestarted then contamination:GetTeam():SetTeamResources(contamination:GetTeam():GetTeamResources() - cost) end
                        --     Print("nearestbuiltnode is %s", contamination)
           end--
         end--
end--
function Imaginator:AlienConstructs(cystonly)


       if not cystonly then
       
       if GetFrontDoorOpen() and GetBioMassLevel() >= 9 then
         ChanceRandomContamination(self)
       
       end
       
       end
       
       self:DoBetterUpgs()
       
       for i = 1, 2 do
         local success = self:ActualAlienFormula(cystonly)
                  if success == true then return true end
       end
       
      

return true

end
local function UpgChambers()
           local gamestarted = not GetGameInfoEntity():GetWarmUpActive()   
if not gamestarted then return nil end     
 local tospawn = {}
local canafford = {}    

      local hasshade = false
local hasecrag = false
local hasshift = false

             for index, hive in ipairs(GetEntitiesForTeam("Hive", 2)) do
               if hive:GetIsAlive() and hive:GetIsBuilt() then 
                  if hive:GetTechId() ==  kTechId.CragHive then
                  hasecrag = true
                  elseif hive:GetTechId() ==  kTechId.ShadeHive then
                  hasshade = true
                  elseif hive:GetTechId() ==  kTechId.ShiftHive then
                  hasshift = true
                  end
                end
             end

           
        if hasshift then  
              local  Spur = #GetEntitiesForTeam( "Spur", 2 )
              if Spur < 3 then table.insert(tospawn, kTechId.Spur) end
       end

        if hasecrag  then  
              local  Shell = #GetEntitiesForTeam( "Shell", 2 )
              if Shell < 3 then table.insert(tospawn, kTechId.Shell) end
       end
        if hasshade then  
                local  Veil = #GetEntitiesForTeam( "Veil", 2 )
              if Veil < 3 then table.insert(tospawn, kTechId.Veil) end
       end
       
             
       for _, techid in pairs(tospawn) do
          local cost = LookupTechData(techid, kTechDataCostKey)
           if not gamestarted or TresCheck(2,cost) then
             table.insert(canafford, techid)   
           end
    end
       
      local finalchoice = table.random(canafford)
      local finalcost = LookupTechData(finalchoice, kTechDataCostKey)
      finalcost = not gamestarted and 0 or finalcost
      --Print("GetAlienSpawnList() return finalchoice %s, finalcost %s", finalchoice, finalcost)
      return finalchoice, finalcost, gamestarted
       
end
local function GetHivePowerPoint()
 local hivey = nil
            for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
               hivey = hive
               break   
             end
local node = GetNearest(hivey:GetOrigin(), "PowerPoint", 1, function(ent) return GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(hivey:GetOrigin())  end)

if node then return node end

return nil

end
function Imaginator:ClearAttached()
return 
end
function Imaginator:DoBetterUpgs()
local tospawn, cost, gamestarted = UpgChambers()
local success = false
local randomspawn = nil
local hivepower = GetHivePowerPoint()
     if hivepower and tospawn then             
                 randomspawn = FindFreeSpace(hivepower:GetOrigin())
            if randomspawn then
                   local entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                    if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
            end
  end
    
  return success
end
function Imaginator:ActualAlienFormula(cystonly)
--Print("AutoBuildConstructs")
local  hivecount = #GetEntitiesForTeam( "Hive", 2 )
if hivecount < 3 then return end -- build hives first ya newb
local randomspawn = nil
local powerPoints = GetDisabledPowerPoints()
local tospawn, cost, gamestarted = GetAlienSpawnList(cystonly)
local success = false
local entity = nil

     if powerPoints and tospawn then
                local powerpoint = table.random(powerPoints)
             if powerpoint then       
                 local potential = FindPosition(GetAllLocationsWithSameName(powerpoint:GetOrigin(), tospawn == kTechId.Clog), powerpoint, 2)
                 if potential == nil then 
                     local roll = math.random(1,3) 
                     if roll == 3 then self:ActualAlienFormula() return end
                 end        
                 randomspawn = FindFreeSpace(potential, math.random(2.5, 8) )
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetTechId() == tospawn end)
                if tospawn == kTechId.Clog then  nearestof = GetNearest(randomspawn, "Clog", 2) end
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange =  nearestof:GetMinRangeAC() or 12
                          if tospawn == kTechId.NutrientMist then minrange = NutrientMist.kSearchRange end
                          if range >=  minrange then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                          if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                          end
                          success = true
                     else -- it tonly takes 1!
                         entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
                     end
               end   
            end
  end
    
  return success
 end
function Imaginator:AutoBuildResTowers()
  for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        if not respoint:GetAttached() then AutoDrop(self, respoint) end
    end
end



--Contam

--Better than hanging out in contamination_siege.lua
local function TresSpawn(who, cost, randomlychosen)

 if TresCheck(2, cost) then 

local entity = CreateEntityForTeam(randomlychosen, FindFreeSpace(who:GetOrigin(), 1, 8), 2)
  if entity:isa("EggBeacon") or entity:isa("StructureBeacon") then local chance = math.random(1,100) if chance <= 10 then entity:SetConstructionComplete() end end
 entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
end

end

local function AdditionalSpawns(who)

local contamchance = math.random(1, 100) 

local mistchance = math.random(1, 100)

local rupturechance = math.random(1, 100)

local tospawn ={}

if contamchance <= 10 then

table.insert(tospawn, kTechId.Contamination) 

end  

if mistchance <= 15 then

table.insert(tospawn, kTechId.NutrientMist) 

end


if rupturechance <= 50 then

table.insert(tospawn, kTechId.Rupture)

end

if  table.count(tospawn) == 0 then return end


local randomlychosen = table.random(tospawn)



local cost = LookupTechData(randomlychosen, kTechDataCostKey)

TresSpawn(who, cost, randomlychosen)


end

function Imaginator:HandleIntrepid(who)
local tospawn = {}
      local  StructureBeacon = #GetEntitiesForTeam( "StructureBeacon", 2 )
      local  EggBeacon = #GetEntitiesForTeam( "EggBeacon", 2 )
      local CommVortex = #GetEntitiesForTeam( "CommVortex", 2 )
      local BoneWall = #GetEntitiesForTeam( "BoneWall", 2 )
      --Rupture
      --Mist
      --DrifterAvoca
      --10% xhance of contam
      
if StructureBeacon < 1 and GetHasShiftHive() then table.insert(tospawn, kTechId.StructureBeacon) end

if EggBeacon < 1 and  GetHasCragHive() then table.insert(tospawn, kTechId.EggBeacon) end


if CommVortex < 1 and  GetHasShadeHive() then table.insert(tospawn, kTechId.CommVortex) end

if BoneWall < 1 then table.insert(tospawn, kTechId.BoneWall) end

if  table.count(tospawn) == 0 then return end

local randomlychosen = table.random(tospawn)

local cost = LookupTechData(randomlychosen, kTechDataCostKey)

TresSpawn(who, cost, randomlychosen)
AdditionalSpawns(who)



return who:GetIsAlive() and not who:GetIsDestroyed()

end

--

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)