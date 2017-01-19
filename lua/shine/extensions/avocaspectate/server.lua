--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin



Plugin.Version = "1.0"

function Plugin:Initialise()
self.Enabled = true
return true
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Spectate]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifySalt( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[+0.1 Salt][Director]",  255, 0, 0, String, Format, ... )
end
local function GetPregameView()
local choices = {}
 
              
                   for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                  if not player:isa("Spectator") and not player:isa("Commander") and player:GetIsOnGround() then table.insert(choices, player) break end
              end 
            
              local random = table.random(choices)
              return random
              

end
local function GetLocationWithMostMixedPlayers()

local team1avgorigin = Vector(0, 0, 0)
local marines = 1
local team2avgorigin = Vector(0, 0, 0)
local aliens = 1
local neutralavgorigin = Vector(0, 0, 0)

            for _, marine in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
            if marine:GetIsAlive() and not marine:isa("Commander") then marines = marines + 1 team1avgorigin = team1avgorigin + marine:GetOrigin() end
             end
             
           for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do
            if alien:GetIsAlive() and not alien:isa("Commander") then aliens = aliens + 1 team2avgorigin = team2avgorigin + alien:GetOrigin() end 
             end
             --v1.23 added check to make sure room isnt empty
         neutralavgorigin =  team1avgorigin + team2avgorigin
         neutralavgorigin =  neutralavgorigin / (marines+aliens) --better as a table i know
     //    Print("neutralavgorigin is %s", neutralavgorigin)
     local nearest = GetNearestMixin(neutralavgorigin, "Combat", nil, function(ent)  return ent:isa("Player") and ent:GetIsInCombat() end)
    if nearest then
   // Print("nearest is %s", nearest.name)
        return nearest
    end

end
local function GetSiegeView()


if not GetGamerules():GetGameStarted() then return GetPregameView() end

  --Print("GetSiegeView")
local choices = {}
--arc if moving or in siege
--contam
--commandstructure if in combat
--alive power node in combat
--egg or structure beacon
local interesting = GetLocationWithMostMixedPlayers()
if interesting ~= nil then table.insert(choices,interesting) end
               
               for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                    local order = arc:GetCurrentOrder()
                      if order then
                 if order:GetType() == kTechId.Move then table.insert(choices, arc) break end -- just 1
                     end
              end 
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1xx
              end 
             for index, cs in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
                  if cs:GetIsInCombat() then table.insert(choices, cs) break end
              end 
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if not construct:isa("Hydra") and construct:GetIsAlive() and construct:GetHealthScalar() <= .5 and construct:GetIsInCombat() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end  

              
          --   for index, alienbeacon in ientitylist(Shared.GetEntitiesWithClassname("AlienBeacon")) do
           --       if alienbeacon:GetIsAlive() then table.insert(choices, alienbeacon) break end --built and not disabled should be summed up by if in combat?
         --     end   
              
              local random = table.random(choices)
              return random
end
 local function GetMiddleView()

local choices = {}
local interesting = GetLocationWithMostMixedPlayers()
if interesting ~= nil then table.insert(choices,interesting) end
             
 
             for index, obs in ientitylist(Shared.GetEntitiesWithClassname("Observatory")) do
                  if obs:GetIsBeaconing() or obs:GetIsAdvancedBeaconing() then table.insert(choices, obs) break end --built and not disabled should be summed up by if in combat?
              end  
              
             for index, breakabledoor in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do
              if breakabledoor:GetHealthScalar() <= .7 and not breakabledoor:GetHealth() == 0 and  breakabledoor:GetIsInCombat() then
                     local player =  GetNearest(breakabledoor:GetOrigin(), "Player", nil, function(ent) return not ent:isa("Commander") end)
                     if player then
                     table.insert(choices, player) 
                     break  -- just 1
                     end
                end
              end  
      
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1
              end
        
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if construct:GetIsBuilt() and construct:GetHealthScalar() <= .3 and construct:GetIsInCombat() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end     

             for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                 local order = arc:GetCurrentOrder()
                  if order then
                 if order:GetType() == kTechId.Move then table.insert(choices, arc) break end -- just 1
                 end
              end          
              
              
              local random = table.random(choices)
              return random

end
local function GetIsBusy(who)
  local order = who:GetCurrentOrder()
local busy = false
   if order then
   busy = true
   end
  -- if who:isa("MAC") then
 --  elseif who:isa("Drifter") then
   -- end
return busy
end
local function GetSetupView()
 --Print("GetSetupView")
local choices = {}
--macs, drifters, not built constructs
--front door
             for index, frontdoor in ientitylist(Shared.GetEntitiesWithClassname("FrontDoor")) do
                     local player =  GetNearest(frontdoor:GetOrigin(), "Player", nil, function(ent) return not ent:isa("Commander") end)
                     if player then
                     table.insert(choices, player) 
                     break  -- just 1
                     end
              end 
              
             for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                  if GetIsBusy(mac) then table.insert(choices, mac) break end 
              end     
             for index, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
                  if not cyst:GetIsBuilt() then table.insert(choices, cyst) break end 
              end  
             for index, drifter in ientitylist(Shared.GetEntitiesWithClassname("Drifter")) do
                  if GetIsBusy(drifter) then table.insert(choices, drifter) break end 
              end    
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if not construct:isa("PowerPoint") and not GetIsInSiege(construct) and not construct:GetIsBuilt() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end    
              
              local random = table.random(choices)
              return random

end
local function GetLocationName(who)
        local location = GetLocationForPoint(who:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
local function FindEntNear(where)
                  local entity =  GetNearestMixin(where, "Combat", nil, function(ent) return ent:GetIsInCombat() and not ent:isa("Commander") end)
                    if entity then
                    return FindFreeSpace(entity:GetOrigin())
            end
            return where
end


local function GetTween()
local random = {}
table.insert(random, kTweeningFunctions.easein)
table.insert(random, kTweeningFunctions.linear)
table.insert(random, kTweeningFunctions.easein)
table.insert(random, kTweeningFunctions.easein3)
table.insert(random, kTweeningFunctions.easeout3)
table.insert(random, kTweeningFunctions.easein5)
table.insert(random, kTweeningFunctions.easeout5)
table.insert(random, kTweeningFunctions.easein7)
table.insert(random, kTweeningFunctions.easeout7)
table.insert(random, kTweeningFunctions.easeout)

 random = table.random(random)
return random

end
local function SaltNearby(self, client)

if not GetGamerules():GetGameStarted()  then return end

   for _, player in ipairs(GetEntitiesWithinRange("Player", client:GetOrigin(), 4)) do
    local  userid = player:GetClient():GetUserId()
        if player ~= client and userid ~= nil then
         Shared.ConsoleCommand(string.format("sh_addsalt %s 0.1 false", userid ) )
         self:NotifySalt( player, "You have been visited!!!!", true ) 
        self:NotifySalt( client, "Added Salt to %s", true, player:GetName() ) 
         end
  
   end
  
end
local function SwitchToOverHead(client, self, where)
        local height = math.random(4,16)
        self:NotifyGeneric( client, "Overhead mode nearby otherwise inside entity origin. Height is %s", true, height)
        if client.specMode ~= kSpectatorMode.Overhead  then client:SetSpectatorMode(kSpectatorMode.Overhead)  end
        client:SetOrigin(where)
        client.overheadModeHeight =  height

end
local function ChangeView(self, client)
 -- Print("ChangeView")
      -- client.SendNetworkMessage("SwitchFromFirstPersonSpectate", { mode = kSpectatorMode.Following })
        
        if not client then return end
       local vip = nil
       
        if GetSiegeDoorOpen() then
         --  Print("ChangeView Siege Open")
           vip = GetSiegeView()
        elseif GetSetupConcluded() then
         --  Print("ChangeView Setup Concluded")
           vip = GetMiddleView()
        else
          -- Print("ChangeView Setup In Progress")
           vip = GetSetupView()
        end
       
        if vip ~= nil then 
          client:SetDesiredCameraDistance(0)
        -- Print("vip is %s", vip:GetClassName())
          if client:GetSpectatorMode() ~= kSpectatorMode.FreeLook then client:SetSpectatorMode(kSpectatorMode.FreeLook)  end
          local viporigin = vip:GetOrigin()
          local findfreespace = FindFreeSpace(viporigin, 1, 8)
          if findfreespace ==  viporigin then SwitchToOverHead(client, self, viporigin) return end
             client:SetOrigin(findfreespace)
             local dir = GetNormalizedVector(viporigin - client:GetOrigin())
             local angles = Angles(GetPitchFromVector(dir), GetYawFromVector(dir), 0)
             local tween = nil
             local random = math.random (1,10)
             local static = false
             local wall = GetWallBetween(client:GetOrigin(), viporigin, vip)
               tween = GetTween()
              client:SetDesiredCamera(8.0, {move = true, tweening = tween }, client:GetEyePos(), angles, 0)
              client:SetIsVisible(true)
            --  SaltNearby(self, client)
              self:NotifyGeneric( client, "VIP is %s, location is %s, tween is (%s),  wall between is %s", true, vip:GetClassName(), GetLocationName(client), tween, wall )
              
        else
             client:SetSpectatorMode(kSpectatorMode.FirstPerson)
              --client:SelectEntity(GetEligableTopScorer()) 
         end

end
local function AutoSpectate(self, client)

    Shine.Timer.Create( "AutoSpectate", 8, -1, function() if client and client:isa("AvocaSpectator") then ChangeView(self, client) else Shine.Timer.Destroy("AutoSpectate") end  end )
end


function Plugin:ClientConnect(client)
     if client:GetUserId() == 8086089 or client:GetUserId() == 2962389  then 
     self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s 3", client:GetUserId() )  )end
      end)
      end
      
    if client:GetUserId() == 388510592 then --or client:GetUserId() == 22542592 then --388510592 then 
     self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s 3", client:GetUserId())) client:GetControllingPlayer():Replace(AvocaSpectator.kMapName)  local Client = client:GetControllingPlayer() Client:SetSpectatorMode(kSpectatorMode.FirstPerson) AutoSpectate(self, Client) end
      end)
      
      end

end
function Plugin:SetGameState( Gamerules, State, OldState )

     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
          -- Shine:GetClient(388510592)
            self:SimpleTimer( 12, function() 
            local client =  Shine:GetClient(388510592) 
                  if client then 
                    Shared.ConsoleCommand(string.format("sh_setteam %s 3", client:GetUserId())) 
                    client:GetControllingPlayer():Replace(AvocaSpectator.kMapName) 
                    local Client = client:GetControllingPlayer() Client:SetSpectatorMode(kSpectatorMode.FirstPerson) AutoSpectate(self, Client) 
                  end 
            end)
        end 
end
     