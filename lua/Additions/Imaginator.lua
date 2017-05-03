
--Kyle 'Avoca' Abent



class 'Imaginator' (ScriptActor) 
Imaginator.kMapName = "imaginator"


local networkVars = 

{
 alienenabled = "boolean",
 marineenabled = "boolean",
  lastrobo = "private time",
  lastink = "private time",
  lasthealwave = "private time",
  --lastmarineBeacon = "private time",
  --lastWand = "private time",
  setupExtTresScale = "private integer (0 to 20)"
}


local function GetHasActiveObsInRange(where)

            local obs = GetEntitiesForTeamWithinRange("Observatory", 1, where, kScanRadius)
            if #obs == 0 then return false end
            for i = 1, #obs do
             local ent = obs[i]
             if GetIsUnitActive(ent) then return true end
            end
            
            return false  
                
end
local function GetHasPGInRoom(where)

            local pgs = GetEntitiesForTeamWithinRange("PhaseGate", 1, where, 999999)
            if #pgs == 0 then return false end
            for i = 1, #pgs do
             local ent = pgs[i]
              if GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(where) then return true end
            end
            
            return false  
                
end
local function BuildPowerNodes()
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                       if not powerpoint:GetIsSocketed() then powerpoint:SetConstructionComplete()  powerpoint:Kill() end
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
   self.lastrobo = 0
   self.lastink = 0
   self.lasthealwave = 0
   self:SetUpdates(true)
   self.setupExtTresScale = 0
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
                 if not  self.timeLastAutomations or self.timeLastAutomations + 8 <= Shared.GetTime() then
                 self.timeLastAutomations = Shared.GetTime()
        self:Automations()
         end
            if not  self.timeLastImaginations or self.timeLastImaginations + math.random(4,8) <= Shared.GetTime() then
            self.timeLastImaginations = Shared.GetTime()
        self:Imaginations()
         end
            if not  self.timeLastCystTimer or self.timeLastCystTimer + math.random(1,8) <= Shared.GetTime() then
            self.timeLastCystTimer = Shared.GetTime()
         self:CystTimer()
         end
         
         if not  self.timelastOnOffSwitch or self.timelastOnOffSwitch + 2 <= Shared.GetTime() then
           local team1Commander = GetGamerules().team2:GetCommander()
           local team2Commander = GetGamerules().team2:GetCommander()
          self.timelastOnOffSwitch = Shared.GetTime()
          self.marineEnabled = not team1Commander
          self.alienEnabled = not team2Commander
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
      
end
function Imaginator:SetImagination(boolean, team)

  if team == 1 then
  self.marineenabled = boolean
  elseif team == 2 then
  self.alienenabled = boolean
  end


end
local function GetAlienSpawnLocation()
 local places = {}
  local location = nil
  --Fine tuned ;)
            for _, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                    if powerpoint and  (powerpoint:GetIsDisabled() or ( powerpoint:GetIsSocketed() and not powerpoint:GetIsBuilt() ) )  and not ( not GetSiegeDoorOpen() and GetIsInSiege(powerpoint) ) then
                    table.insert(places, powerpoint)
                    end
             end
       if not cystonly then
            for _, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
               if cyst:GetIsBuilt() then
                  --  local location = GetLocationForPoint(cyst:GetOrigin())
                 --   local powerpoint =  location and GetPowerPointForLocation(location.name)
                 --   if powerpoint and not powerpoint:GetIsDisabled() and powerpoint:GetIsBuilt()  then
                     table.insert(places, cyst)
                   -- end
                end
             end
        else
        
             for _, entity in ipairs( GetEntitiesWithMixinForTeam("Construct", 2 ) ) do
               if not entity:GetGameEffectMask(kGameEffect.OnInfestation) then 
                  local location = GetLocationForPoint(entity:GetOrigin())
                  local powerpoint =  location and GetPowerPointForLocation(location.name)
                  if powerpoint and powerpoint:GetIsDisabled() then
                     table.insert(places, entity)
                   end
               end
            end
       
        
        end
 if #places == 0 then return nil end
return table.random(places)

end
local function PowerPointStuff(who, self)
local location = GetLocationForPoint(who:GetOrigin())
local powerpoint =  location and GetPowerPointForLocation(location.name)
      if powerpoint ~= nil then 
              if self.marineenabled   and ( powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() ) then 
                return 1
              end
             if  self.alienenabled  and ( powerpoint:GetIsDisabled() )  then
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
           -- tower:SetConstructionComplete()
            else
               if not tower:GetGameEffectMask(kGameEffect.OnInfestation) then 
               CreateEntity(Clog.kMapName, FindFreeSpace(tower:GetOrigin(), 1, 4) , 2) 
               end
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
    else
          BuildPowerNodes()
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
  
            if gamestarted and self.marineenabled  then 
              self:MarineConstructs()
           end
            
            if gamestarted  and self.alienenabled then
              self:AlienConstructs(false)
           end
           
              return true
end
function Imaginator:CystTimer()
  local gamestarted = false 
   if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
              if gamestarted  and self.alienenabled then --and not team2Commander) then
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
    if entity:isa("Alien") and entity:GetIsAlive() and isPathable( entity:GetOrigin() ) then return FindFreeSpace(entity:GetOrigin(), math.random(2, 4), math.random(8,24), true) end
    elseif teamnum == 1 then
    if entity:isa("Marine") and entity:GetIsAlive() and isPathable( entity:GetOrigin() ) then return FindFreeSpace(entity:GetOrigin(), math.random(2,4), math.random(8,24), false ) end
    end 
  end
return origin
  
end
local function changeColorsBack()
      for _, light in ipairs(GetLightsForLocation(location.name)) do
         light:SetColor(light.originalColor)
    end
end

local function FindPosition(location, searchEnt, teamnum)
  if #location == 0  then return end
  local origin = nil
  local where = {}
    for i = 1, #location do
    local location = location[i]   
      local ents = location:GetEntitiesInTrigger()
      local potential = InsideLocation(ents, teamnum)
      if potential ~= nil then  table.insert(where, potential) end 
  end
     for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Construct", teamnum, searchEnt:GetOrigin(), 24) ) do
       if  GetLocationForPoint(entity:GetOrigin()) ==  GetLocationForPoint(searchEnt:GetOrigin()) then
          table.insert(where, entity:GetOrigin())
       end
     end
  if #where == 0 then return nil end
  return table.random(where)

end
local function GetRange(who, where)
    local ArcFormula = (where - who:GetOrigin()):GetLength() -- include Y
    return ArcFormula
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
local function GetAlienCostScalar(self,cost)
  if not cost then cost = math.random(4,8) end
  if GetSetupConcluded() then
    local toReturn =  cost / 1.85 --(self.setupExtTresScale / self:GetMarineExtCount())
    return math.min(toReturn, cost)--Don't punish for more.
  else
  return cost / 2
  end
  
end
local function GetMarineCostScalar(self,cost)
  if not cost then cost = math.random(4,12) end
  if GetSetupConcluded() then
    local toReturn =  cost / 1.85 --(self.setupExtTresScale / self:GetMarineExtCount())
    return math.min(toReturn, cost)--Don't punish for more.
  else
  return cost / 2
  end
  
end
local function OrganizedIPCheck(who, self)

-- One entity at a time
local count = 0
local ips = GetEntitiesForTeamWithinRange("InfantryPortal", 1, who:GetOrigin(), kInfantryPortalAttachRange)
 --ADd in getisactive
      --Add in arms lab because having these spread through the map is a bit odd.
      local armscost = GetMarineCostScalar(self,LookupTechData(kTechId.ArmsLab, kTechDataCostKey))
      local  ArmsLabs = GetEntitiesForTeam( "ArmsLab", 1 )
      local labs = #ArmsLabs or 0
      if #ArmsLabs >= 1 then 

      
      for i = 1, #ArmsLabs do
          local ent = ArmsLabs[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
          labs = labs - 1
          end
      end
      
      end
      
      if labs < 2 and TresCheck(1, armscost) then
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
           local cost = GetMarineCostScalar(self,20)
               if TresCheck(1, cost) then 
                local where = who:GetOrigin()
               local origin = FindFreeSpace(where, 4, kInfantryPortalAttachRange)
                 if origin ~= where then
                 local ip = CreateEntity(InfantryPortal.kMapName, origin,  1)
                ip:GetTeam():SetTeamResources(ip:GetTeam():GetTeamResources() - cost)
                end
           end
           
              
           
end
local function HaveCCsCheckIps(self)
   local CommandStations = GetEntitiesForTeam( "CommandStation", 1 )
       if not CommandStations then return end
        OrganizedIPCheck(table.random(CommandStations), self)
end
local function GetMarineSpawnList(self)
local tospawn = {}
local canafford = {}
local cost = 1 
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true HaveCCsCheckIps(self) end
--Horrible for performance, right? Not precaching ++ local variables ++ table && for loops !!! 

 local  PhaseGates = GetEntitiesForTeam( "PhaseGate", 1 )
 local pgcount = #PhaseGates
 
      if #PhaseGates >= 1 then 
      for i = 1, #PhaseGates do
          local ent = PhaseGates[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
          pgcount = pgcount - 1
          end
      end
      
      end
      
      if pgcount <= 7 then
      table.insert(tospawn, kTechId.PhaseGate)
      end
     
     
      local  Armory = GetEntitiesForTeam( "Armory", 1 )
      local acount = #Armory
      if acount >= 1 then 
      
      for i = 1, #Armory do
          local ent = Armory[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
          acount = acount - 1
          end
      end
      
      end
      
      if acount <= 7 then
      table.insert(tospawn, kTechId.Armory)
      end
      
      
      local  RoboticsFactory = GetEntitiesForTeam( "RoboticsFactory", 1 )
      local rcount = #RoboticsFactory 
      if rcount >= 1 then 
      
      for i = 1, #RoboticsFactory do
          local ent = RoboticsFactory[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
         rcount = rcount -1
          end
      end
      
      end
      
      if rcount <= 11 then
      table.insert(tospawn, kTechId.RoboticsFactory)
      end
      
      
      local  Observatory = GetEntitiesForTeam( "Observatory", 1 )
      local ocount = #Observatory
      if ocount >= 1 then 
      
      for i = 1, ocount do
          local ent = Observatory[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
          ocount = ocount - 1
          end
      end
      
      end
      
      if ocount <= 08 then
      table.insert(tospawn, kTechId.Observatory)
      end
      
       
       
      local  PrototypeLab = GetEntitiesForTeam( "PrototypeLab", 1 )
      local pcount = #PrototypeLab
      if pcount >= 1 then 
      
      for i = 1, #PrototypeLab do
          local ent = PrototypeLab[i]
          if ( ent:GetIsBuilt() and not ent:GetIsPowered() ) then
          pcount = pcount - 1
          end
      end
      
      end
      
     --if pcount <= 08 then
      --table.insert(tospawn, kTechId.PrototypeLab)
      --end
      

      --table.insert(tospawn, kTechId.Scan)
      
     
          if GetHasAdvancedArmory()  and pcount < 9 then
           table.insert(tospawn, kTechId.PrototypeLab)
         end
      
       local  Sentry = GetEntitiesForTeam( "Sentry", 1 )
       local sentrycount = #Sentry 
      if #Sentry >= 1 then 
      
      for i = 1, #Sentry do
          local ent = Sentry[i]
          if ( ent:GetIsBuilt() and not ent.attachedToBattery ) then
          sentrycount = sentrycount - 1
          end
      end
      
      end
      
      if sentrycount <= 18 then
      table.insert(tospawn, kTechId.Sentry)
      end
      
     
      
      
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
      finalcost = GetMarineCostScalar(self, LookupTechData(finalchoice, kTechDataCostKey))
      finalcost = ConditionalValue (finalchoice == kTechId.PrototypeLab, 5, finalcost)
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

local function BuildNotificationMessage(where, self, mapname)

end

local function  isPayload(where, who)

            if not GetFrontDoorOpen() and string.find(Shared.GetMapName(), "pl_") then 
             return GetIsPointInMarineBase(where)
            end
            
      local nearestmarine = GetNearest(who:GetOrigin(), "Marine", 1,  function(ent) return   GetLocationForPoint(who:GetOrigin()) ==  GetLocationForPoint(ent:GetOrigin())  end )
      local nearby = false
      
      if not GetFrontDoorOpen() then
        nearby = not who:isa("PowerPoint")
      end
      
      if not nearby and nearestmarine then
        nearby = true
      end
      
            return nearby
            
    
end
local function IsBeingGrown(self, target)

    if target.hasDrifterEnzyme then
        return true
    end

    for _, drifter in ipairs(GetEntitiesForTeam("Drifter", target:GetTeamNumber())) do
    
        if self ~= drifter then
        
            local order = drifter:GetCurrentOrder()
            if order and order:GetType() == kTechId.Grow then
            
                local growTarget = Shared.GetEntity(order:GetParam())
                if growTarget == target then
                    return true
                end
            
            end
        
        end
    
    end

    return false

end
local function GetDrifterBuff()
 local buffs = {}
 if GetHasShadeHive()  then table.insert(buffs,kTechId.Hallucinate) end
 if GetHasCragHive()  then table.insert(buffs,kTechId.MucousMembrane) end
  if GetHasShiftHive()  then table.insert(buffs,kTechId.EnzymeCloud) end
    return table.random(buffs)
end
local function GiveDrifterOrder(who, where)

local structure =  GetNearestMixin(who:GetOrigin(), "Construct", 2, function(ent) return not ent:GetIsBuilt() and not IsBeingGrown(who, ent) and (not ent.GetCanAutoBuild or ent:GetCanAutoBuild()) and not (GetIsInSiege(ent) and not GetSiegeDoorOpen() )  end)
local player =  GetNearest(who:GetOrigin(), "Alien", 2, function(ent) return ent:GetIsInCombat() and ent:GetIsAlive() end) 
    
    local target = nil
    
    if structure then
      target = structure
    end
    
    
    if GetFrontDoorOpen() and player then
        local chance = math.random(1,100)
        local boolean = chance >= 70
        if boolean then
        who:GiveOrder(GetDrifterBuff(), player:GetId(), player:GetOrigin(), nil, false, false)
        return
        end
    end
    
        if  structure then      
    
            who:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
            return  
      
        end
        
end
local function ManageDrifters()
local hive = nil

   for index, hivey in ipairs(GetEntitiesForTeam("Hive", 2)) do
       hive = hivey
       break
   end
   
   if hive then
     local where = hive:GetOrigin()
     local Drifters = GetEntitiesForTeamWithinRange("Drifter", 2, where, 9999)
           if not #Drifters or #Drifters <=3 then
            CreateEntity(Drifter.kMapName, FindFreeSpace(where), 2)
           end
   
   if #Drifters >= 1 then
   
     for i = 1, #Drifters do
        local drifter = Drifters[i]
           if not drifter:GetHasOrder() then
          GiveDrifterOrder(drifter, drifter:GetOrigin())
          end
     end
   
   end
   
   end
   
end

local function GiveConstructOrder(who, where)

local random = {}
    for _, ent in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct",1, where, 999999)) do
      if  isPayload(ent:GetOrigin(), ent) and not ent:GetIsBuilt() and ent:GetCanConstruct(who) and who:CheckTarget(ent:GetOrigin()) and not (GetIsInSiege(ent) and not GetSiegeDoorOpen() ) then
        table.insert(random, ent)
        end
    end
    
 
       local constructable = table.random(random)
               if constructable then
                    local target = constructable
                    local orderType = kTechId.Construct
                    local where = target:GetOrigin()
                   return who:GiveOrder(orderType, target:GetId(), where, nil, false, false)   
                end
end
local function ManageMacs()
local cc = nil

   for index, chair in ipairs(GetEntitiesForTeam("CommandStation", 1)) do
       cc = chair 
       break
   end
   
   if cc then
     local where = cc:GetOrigin()
     local MACS = GetEntitiesForTeamWithinRange("MAC", 1, where, 9999)
           if not GetSetupConcluded() and not #MACS or #MACS <=3 then
            CreateEntity(MAC.kMapName, FindFreeSpace(where), 1)
           end
   
   if #MACS >= 1 then
   
     for i = 1, #MACS do
        local mac = MACS[i]
           if not mac:GetHasOrder() then
          GiveConstructOrder(mac, mac:GetOrigin())
          end
     end
   
   end
   
   end
   
end

local function ManageArcs(self)

     -- if GetIsTimeUp(self.lastWand, math.random(8, 16) ) then
              for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
             arc:Instruct()
              end
     -- self.lastWand = Shared.GetTime()
    --  end
 
end
local function ManageRoboticFactories(self)
      local  ARCS = {}
      local ARCRobo = {} --ugh
      local robos = GetEntitiesForTeam("RoboticsFactory", 1)
      local MACS = 0
      local chanceSpawn = math.random(1,2)
      
           for index, mac in ipairs(GetEntitiesForTeam("MAC", 1)) do
               if not mac:isa("MACCredit") then MACS = MACS + 1 end
     end
     if #robos >= 1 then 
     if chanceSpawn == 1 and MACS <= 11 and TresCheck(1, kMACCost ) then
      local single = table.random(robos)
      local maccost = GetMarineCostScalar(self, kMACCost)
       if GetIsTimeUp(self.lastrobo, math.random(4, 12)) and GetIsUnitActive(single) and not single:GetIsResearching() then
      single:GetTeam():SetTeamResources(single:GetTeam():GetTeamResources() - maccost)
      single:OverrideCreateManufactureEntity(kTechId.MAC)
      self.lastrobo = Shared.GetTime()
      end
     end
     end
      
       for i = 1, #robos do
        local robo = robos[i]
       if  robo:GetTechId() ~= kTechId.ARCRoboticsFactory and robo:GetIsBuilt() and not robo:GetIsResearching() then
           local techid = kTechId.UpgradeRoboticsFactory
           local techNode = robo:GetTeam():GetTechTree():GetTechNode( techid ) 
            robo:SetResearching(techNode, robo)
       end
              if robo:GetTechId() == kTechId.ARCRoboticsFactory then table.insert(ARCRobo, robo) end --ugh
     end
     
     
     if ( not GetHasThreeChairs() and not GetFrontDoorOpen() ) then return end
        
          if  table.count(ARCRobo) == 0 then return end
          
                    ARCRobo = table.random(ARCRobo)
        
     for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
       if not arc:isa("ARCCredit") then table.insert(ARCS,arc) end
     end
          
          --Not avoca arc because we want these changed to siegearcs when siege is open
     local ArcCount = table.count(ARCS) 
     
     
      if ArcCount < 12 and TresCheck(1, kARCCost) then
         local arccost = GetMarineCostScalar(self, kARCCost)
         if ( GetIsTimeUp(self.lastrobo, math.random(4, 12)) or GetSiegeDoorOpen() )   and GetIsUnitActive(ARCRobo) and not ARCRobo.open then
         ARCRobo:GetTeam():SetTeamResources(ARCRobo:GetTeam():GetTeamResources() - arccost)
         ARCRobo:OverrideCreateManufactureEntity(kTechId.ARC)
         self.lastrobo = Shared.GetTime()
         end
      end

      --if string.find(Shared.GetMapName(), "pl_") then return end


      if GetSetupConcluded() and ArcCount>= 1 and TresCheck(1,3) then --because if they scan, they stop :x and fire
      local randomarc = table.random(ARCS)
      --   if not GetHasActiveObsInRange(randomarc:GetOrigin()) then
          randomarc:CreateScan()
          randomarc:GetTeam():SetTeamResources(randomarc:GetTeam():GetTeamResources() - 3)
       -- end
      end
      



end
/*
local function GetRequirements(ent, where)
local boolean_one = ent:GetTechId() == tospawn
local boolean_two = ( ent:GetTechId() == kTechId.AdvancedArmory and tospawn == kTechId.Armory)
local boolean_three = ( ent:GetTechId() == kTechId.ARCRoboticsFactory and tospawn == kTechId.RoboticsFactory)
--local boolean_four =  ( HasMixin(ent, "PowerConsumer") and not ent:GetIsPowered() )  or not ent:GetIsBuilt()
--local boolean_five = ( ent:GetTechId() == kTechId.Sentry and GetCheckSentryLimit(kTechId.Sentry, where) )
return boolean_one or (boolean_two or boolean_three) --or boolean_four  --and not boolean_five
end
*/


function Imaginator:ActualFormulaMarine()


      
--Print("AutoBuildConstructs")
local randomspawn = nil
local tospawn, cost, gamestarted = GetMarineSpawnList(self)
 ManageMacs() 
if gamestarted and not string.find(Shared.GetMapName(), "pl_") then ManageRoboticFactories(self)  ManageArcs(self) end
local powerpoint = GetRandomActivePower()
local success = false
local entity = nil
            if powerpoint and tospawn then
                 local potential = FindPosition(GetAllLocationsWithSameName(powerpoint:GetOrigin()), powerpoint, 1)
                 if potential == nil then local roll = math.random(1,3) if roll == 3 then self:ActualFormulaMarine() return else return end end
                 randomspawn = FindFreeSpace(potential, 2.5)
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 1, function(ent) return ent:GetTechId() == tospawn or ( ent:GetTechId() == kTechId.AdvancedArmory and tospawn == kTechId.Armory)  or ( ent:GetTechId() == kTechId.ARCRoboticsFactory and tospawn == kTechId.RoboticsFactory) end)
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                  --    Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange = nearestof:GetMinRangeAC()
                          if tospawn == kTechId.Scan and GetHasActiveObsInRange(randomspawn) then return end
                          if tospawn == kTechId.PhaseGate and GetHasPGInRoom(randomspawn) then return end
                          
                          if range >=  minrange  then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 1)
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                               --BuildNotificationMessage(randomspawn, self, tospawn)
                               success = true
                          end --
                     else -- it tonly takes 1!
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
local function IsInRangeOfHive(who)
      local hives = GetEntitiesWithinRange("Hive", who:GetOrigin(), Shade.kCloakRadius)
   if #hives >=1 then return true end
   return false
end
local function IsInRangeOfARC(who)
      local arc = GetEntitiesWithinRange("ARC", who:GetOrigin(), Shade.kCloakRadius)
   if #arc >=1 then return true end
   return false
end
local function GetArcsDeployedSiege()

  for index, arc in ipairs(GetEntitiesForTeam("ARC", 1)) do
    if GetIsInSiege(arc) then
    return true
    end
  end
  
  return false
  
end
local function HasTeamInNeed(who)
    for _, entity in ipairs(GetEntitiesWithinRange("Live", who:GetOrigin(), who.kHealRadius)) do
                     if entity:GetIsAlive() and not entity:isa("Commander") then //marine:GetClient():GetIsVirtual(
                       if entity:GetIsInCombat() and entity:GetHealthScalar() <= 0.91  then
                          return true
                        end
                     end
    end
end
local function AllNearByHealWave(who)
    for _, crag in ipairs(GetEntitiesWithinRange("Crag", who:GetOrigin(), who.kHealRadius)) do
         if not crag:GetIsOnFire() and  GetIsUnitActive(crag) then
            crag:TriggerHealWave()
         end
    end
end
local function GetAlienSpawnList(self, cystonly)

local tospawn = {}
local canafford = {}
local gamestarted = false
if GetGamerules():GetGameState() == kGameState.Started then gamestarted = true end
      
      
      local  Shade = GetEntitiesForTeam( "Shade", 2 )
      
      if #Shade <= 14 then
      table.insert(tospawn, kTechId.Shade)
      end
      
      --ShadeInk
      --Spawn here if in range of arc or if in radius of hive during siege (and delay passed) if delay passed and keep track of delay
      --Not written with server perf. in mind ;)
      if #Shade >= 1 and cystonly then
          for i = 1, #Shade do
            local ent = Shade[i]
             local cost = LookupTechData(kTechId.ShadeInk, kTechDataCostKey)
             local siegeopen = GetSiegeDoorOpen()
             if GetHasShadeHive() and GetFrontDoorOpen() and TresCheck(2,cost) and not ent:GetIsOnFire() and 
             GetIsUnitActive(ent) and GetIsTimeUp(self.lastink, kShadeInkCooldown) and 
             ( ( IsInRangeOfARC(ent) and not GetSiegeDoorOpen() ) or ( IsInRangeOfHive(ent) and GetSiegeDoorOpen() ) ) then --and GetArcsDeployedSiege() ) ) then
             --It stil spawns shadeink outside of hive radius. Why not move closer?
             if Server then CreateEntity(ShadeInk.kMapName, ent:GetOrigin() + Vector(0, 0.2, 0), 2) end
              ent:TriggerEffects("shade_ink")
              self.lastink = Shared.GetTime()
              ent:GetTeam():SetTeamResources(ent:GetTeam():GetTeamResources() - cost) 
              break
             end
          end
      end
     
      local  Shift = #GetEntitiesForTeam( "Shift", 2 )
      
      if Shift <= 14 then
      table.insert(tospawn, kTechId.Shift)
      end 
      
      local  Whip = #GetEntitiesForTeam( "Whip", 2 )
      if Whip <= 18 then
      table.insert(tospawn, kTechId.Whip)
      end 
      
      local  Crag = GetEntitiesForTeam( "Crag", 2 )
      if #Crag <= 18 then
      table.insert(tospawn, kTechId.Crag)
      end 
      
      --HealWave
      if #Crag >= 1 and cystonly then
          for i = 1, #Crag do
            local ent = Crag[i]
             local cost = LookupTechData(kTechId.HealWave, kTechDataCostKey)
                 
             if GetFrontDoorOpen() and TresCheck(2,cost) and not ent:GetIsOnFire() and 
             GetIsUnitActive(ent) and GetIsTimeUp(self.lasthealwave, kHealWaveCooldown) and 
             ( HasTeamInNeed(ent) or ( IsInRangeOfHive(ent) and GetSiegeDoorOpen() and GetArcsDeployedSiege() ) ) then
             
              AllNearByHealWave(ent)
              self.lasthealwave = Shared.GetTime()
              ent:GetTeam():SetTeamResources(ent:GetTeam():GetTeamResources() - cost) 
              
              break
             end
          end
      end
      
      
      --table.insert(tospawn, kTechId.NutrientMist)
      
      
      
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
local function ThreatMarineBase(where)
local cc = GetNearest(where, "CommandStation", 1,  function(ent) return   ent:GetIsBuilt()  end )
    if cc then
     CreatePheromone(kTechId.ThreatMarker,cc:GetOrigin(), 2) 
     end
end
local function ThreatNearestNode(where)
if  GetSiegeDoorOpen() then return ThreatMarineBase(where) end
local nearestnode = GetNearest(where, "PowerPoint", 1,  function(ent) return   ent:GetIsBuilt() and not ent:GetIsDisabled() and GetLocationForPoint(where) ==  GetLocationForPoint(ent:GetOrigin())  end )
    if nearestnode then
     CreatePheromone(kTechId.ThreatMarker,nearestnode:GetOrigin(), 2) 
    else
     CreatePheromone(kTechId.ExpandingMarker,where, 2) 
    end

end
local function ChanceRandomContamination(who) --messy
    --  Print("ChanceRandomContamination")
     gamestarted =  not GetGameInfoEntity():GetWarmUpActive() 
     local chance = GetSiegeDoorOpen() and 50 or 30
     local randomchance = math.random(1, 100)
     if (not gamestarted or TresCheck( 2, 5 ) ) and randomchance <= chance then
     
     local inSiege = GetSiegeDoorOpen() and math.random(1,2) == 1 
     
           local where = nil
           if not inSiege  then
           
               local stirItUp = math.random(1,2)
               if stirItUp == 1 then
                where = GetLocationWithMostMixedPlayers()
               end
               if stirItUp == 2 or where == nil then
               where = GetRandomActivePower()
                end
                
           else
           where = GetSiegePowerOrig()
           end
           
             
           if where then 
           where = where:GetOrigin() 
           where = FindFreeSpace(where, 2, 24)
               local contamination = CreateEntityForTeam(kTechId.Contamination, FindFreeSpace(where, 4, 8), 2)
                   
                      ThreatNearestNode(contamination:GetOrigin())
                    contamination:StartBeaconTimer()
            if gamestarted then contamination:GetTeam():SetTeamResources(contamination:GetTeam():GetTeamResources() - 5) end
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
if not gamestarted then return true end     
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
local function GetHive()
 local hivey = nil
            for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
               hivey = hive
               break   
             end


return hivey

end
function Imaginator:ClearAttached()
return 
end
function Imaginator:DoBetterUpgs()
local tospawn, cost, gamestarted = UpgChambers()
local success = false
local randomspawn = nil
local hive = GetHive()
     if hive and tospawn then             
                 randomspawn = FindFreeSpace( hive:GetOrigin(), 4, 24, true)
            if randomspawn then
                   local entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                    if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
            end
  end
    
  return success
end
function GetGoodPoints(origin)
    
    PROFILE("Cyst:GetCystPoints")

    local path, parent = FindPathToClosestParent(origin)

    local normals = {}
    
    local maxDistance = kCystMaxParentRange - 1.5
    local minDistance = kCystRedeployRange - 1
    
    local pathLength = GetPointDistance(path)
    
    -- number of cysts needed for the new path, including the new child (at cursor) cyst, but not
    -- including the already existing parent cyst.
    local requiredCystCount = math.ceil(pathLength / maxDistance)
    
    -- a nice, even distance to spread the cysts out.  This is more desirable as opposed to having
    -- every cyst its maximum distance from its parent until the very end of the chain.
    local evenDistance = pathLength / requiredCystCount
    
    if parent then

        
        local fromPoint = Vector(parent:GetOrigin())
        local currentDistance = 0
        
        local currentCystIndex = 1 -- first cyst to be placed.

        for i = 1, #path do
       
            local point = path[i]
            currentDistance = currentDistance + (point - fromPoint):GetLength()       
            
            if currentCystIndex == requiredCystCount then
                
                local groundTrace = Shared.TraceRay(origin + Vector(0, 0.25, 0), origin + Vector(0, -5, 0), CollisionRep.Default, PhysicsMask.CystBuild, EntityFilterAllButIsa("TechPoint"))
                if groundTrace.fraction == 1 then                        
                    return {}, nil                        
                end
                
                table.insert(normals, groundTrace.normal)
                
                break
                
            elseif currentDistance > evenDistance then
            
                local groundTrace = Shared.TraceRay(path[i] + Vector(0, 0.25, 0), path[i] + Vector(0, -5, 0), CollisionRep.Default, PhysicsMask.CystBuild, EntityFilterAllButIsa("TechPoint"))
                if groundTrace.fraction == 1 then                        
                    return {}, nil                        
                end
                
                table.insert(normals, groundTrace.normal)
                
                currentDistance = (path[i] - point):GetLength()
                
                currentCystIndex = currentCystIndex + 1
                
            end
            
            fromPoint = point
        
        end
    
    end
    
    return normals
    
end
/*
local function CystChain(where) 
--Better than painting with brush, use player to fill in the gap between distance left blank
    local normals = GetGoodPoints(where)
    for i = 1, #normals do
       local point = normals[i]
        local cyst = GetEntitiesWithinRange("Cyst",where, kCystMaxParentRange)
        if not (#cyst >=1) then
        entity = CreateEntityForTeam(kTechId.where, point, 2)
        Print("Cyst chain cyst spawn really?")
        end
    end
end
*/
local function FakeCyst(where) 
         local cyst = GetEntitiesWithinRange("Cyst",where, kCystRedeployRange)
         local cost = not GetSetupConcluded() and 1 or 0
        if not (#cyst >=1) and TresCheck(2, cost) then
        where = FindFreeSpace(where, 1, 8, false)
        entity = CreateEntityForTeam(kTechId.Cyst, where, 2)
        entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost)
        end
end
function Imaginator:ActualAlienFormula(cystonly)
--Print("AutoBuildConstructs")
ManageDrifters() 
local  hivecount = #GetEntitiesForTeam( "Hive", 2 )
if hivecount < 3 then return end -- build hives first ya newb
local randomspawn = nil
local spawnArea = GetAlienSpawnLocation() 
local tospawn, cost, gamestarted = GetAlienSpawnList(self, cystonly)
local success = false
local entity = nil

     if spawnArea and tospawn then     
                 local potential = FindPosition(GetAllLocationsWithSameName(spawnArea:GetOrigin(), tospawn == kTechId.Clog), spawnArea, 2)
                 if potential == nil then local roll = math.random(1,3) if roll == 3 then self:ActualAlienFormula() return else return end  end              
                 randomspawn = FindFreeSpace(potential, math.random(2.5, 4) , math.random(8, 16), not tospawn == kTechId.Cyst )
            if randomspawn then
                local nearestof = GetNearestMixin(randomspawn, "Construct", 2, function(ent) return ent:GetTechId() == tospawn end)
                if tospawn == kTechId.Clog then  nearestof = GetNearest(randomspawn, "Clog", 2) end
                      if nearestof then
                      local range = GetRange(nearestof, randomspawn) --6.28 -- improved formula?
                      --Print("tospawn is %s, location is %s, range between is %s", tospawn, GetLocationForPoint(randomspawn).name, range)
                          local minrange =  nearestof:GetMinRangeAC()
                         -- if tospawn == kTechId.NutrientMist then minrange = NutrientMist.kSearchRange end
                          if range >=  minrange then
                            entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                            --cost = GetAlienCostScalar(self, cost)
                          if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                          end
                          success = true
                     else -- it tonly takes 1!
                         entity = CreateEntityForTeam(tospawn, randomspawn, 2)
                       -- if entity:isa("Cyst") then CystChain(entity:GetOrigin()) end
                           if not entity:isa("Cyst") then FakeCyst(entity:GetOrigin()) end
                        if gamestarted then entity:GetTeam():SetTeamResources(entity:GetTeam():GetTeamResources() - cost) end
                        success = true
                     end 
            end
  end
   -- if success and entity then self:AdditionalSpawns(entity) end
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

function Imaginator:AdditionalSpawns(who)
local where = who:GetOrigin()
local contamchance = math.random(1, 100) 

local mistchance = math.random(1, 100)

local rupturechance = math.random(1, 100)

local tospawn ={}

if contamchance <= 10 then

table.insert(tospawn, kTechId.Contamination) 

end  

if mistchance <= 70 then --Require unbuilt struct or egg



   for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("Construct", 2, where, 8)) do
      if not entity:GetIsBuilt() then
      table.insert(tospawn, kTechId.NutrientMist) 
      break
      end
    end
        

end


    
if rupturechance <= 70 then -- Require player to blind

    for _, player in ipairs(GetEntitiesForTeamWithinRange("Player", 1, where, 8)) do
                     if player:GetIsAlive() and not player:isa("Commander") then 
                       table.insert(tospawn, kTechId.Rupture)
                       break
                     end
    end
    


end

if  table.count(tospawn) == 0 then return end


local randomlychosen = table.random(tospawn)



local cost = LookupTechData(randomlychosen, kTechDataCostKey)

TresSpawn(who, cost, randomlychosen)


end
local function GiveMarineDefend(who)
    for _, marine in ipairs(GetEntitiesWithinRange("Marine", who:GetOrigin(), 9999)) do
                     if marine:GetIsAlive() and not marine:isa("Commander") then //marine:GetClient():GetIsVirtual()
                       if ( marine.GetHasOrder and not  marine:GetHasOrder() ) then
                       marine:GiveOrder(kTechId.Attack, who:GetId(), who:GetOrigin(), nil, true, true)
                        end
                     end
    end
    return true
end
function Imaginator:HandleIntrepid(who)
  --if GetSiegeDoorOpen() and self.marineenabled then
  -- GiveMarineDefend(who)
  -- end
    --Too advantagous ?
  --end
  
  --Still gotta add shadeink management for regular shades in arc radius along with during siege time. 
  --Still WIP braindead but good footage :P

local tospawn = {}
      local  StructureBeacon = #GetEntitiesForTeam( "StructureBeacon", who:GetCurrentInfestationRadius() )
      local  EggBeacon = #GetEntitiesForTeam( "EggBeacon", who:GetCurrentInfestationRadius() )
      local CommVortex = #GetEntitiesForTeam( "CommVortex", who:GetCurrentInfestationRadius() )
      local BoneWall = #GetEntitiesForTeam( "BoneWall", who:GetCurrentInfestationRadius() )
     --local ShadeInk =  #GetEntitiesWithinRange( "ShadeInk", who:GetOrigin(), 18 )
     -- local ARC = #GetEntitiesWithinRange( "ARC", who:GetOrigin(), 18 )
      local Whip = #GetEntitiesWithinRange( "Whip", who:GetOrigin(),  who:GetCurrentInfestationRadius() )
      --Rupture
      --Mist
      --DrifterAvoca
      --10% xhance of contam
   
--if ARC >= 1 and ShadeInk <1  then table.insert(tospawn, kTechId.ShadeInk) end

if Whip <=3  then table.insert(tospawn, kTechId.Whip) end
   
if StructureBeacon < 1 and GetHasShiftHive() then table.insert(tospawn, kTechId.StructureBeacon) end

if EggBeacon < 1 and  GetHasCragHive() then table.insert(tospawn, kTechId.EggBeacon) end


if CommVortex < 1 and  GetHasShadeHive() then table.insert(tospawn, kTechId.CommVortex) end

if BoneWall < 1 then table.insert(tospawn, kTechId.BoneWall) end

if  table.count(tospawn) == 0 then return end

local randomlychosen = table.random(tospawn)

local cost = LookupTechData(randomlychosen, kTechDataCostKey)

TresSpawn(who, cost, randomlychosen)
self:AdditionalSpawns(who)



return who:GetIsAlive() and not who:GetIsDestroyed()

end
function Imaginator:suchasShades()
--Cache would be nice

local hive = nil

   for index, hivey in ipairs(GetEntitiesForTeam("Hive", 2)) do
       hive = hivey
       break
   end
   
 if not hive then return end
 
   local shades = GetEntitiesWithinRange( "Shade", hive:GetOrigin(), 18 )
   
   if #shades <= 2 then 
        local cost = LookupTechData(kTechId.Shade, kTechDataCostKey)
        if TresCheck(2, cost) then
               local origin = FindFreeSpace(hive:GetOrigin(), 2, 14) --not too far else shadeink not hit hive!
               local shade = CreateEntity(Shade.kMapName, origin,  2)
               shade:GetTeam():SetTeamResources(shade:GetTeam():GetTeamResources() - cost)
               --Global tres reduct function?
        end
   end
   
   
return false
end
function Imaginator:EnsureSiegeWall()
local delay = math.random(4,16)

   self:AddTimedCallback(Imaginator.suchasShades, delay)


return true
end
function Imaginator:GetMarineExtCount()
 return #GetEntitiesForTeam( "Extractor", 1 )
end
function Imaginator:OnFrontOpen()

            for _, extractor in ientitylist(Shared.GetEntitiesWithClassname("Extractor")) do
                       if  extractor:GetIsBuilt() and GetIsUnitActive(extractor) then
                       self.setupExtTresScale = self.setupExtTresScale + 1
                       end
             end
             
end
 
function Imaginator:OnSiegeOpen()

   self:AddTimedCallback(Imaginator.EnsureSiegeWall, 8)

end 
--

Shared.LinkClassToMap("Imaginator", Imaginator.kMapName, networkVars)