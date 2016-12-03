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
local function GetSiegeView()
  --Print("GetSiegeView")
local choices = {}
--arc if moving or in siege
--contam
--commandstructure if in combat
--alive power node in combat
--egg or structure beacon
--charging onos

               for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                 if arc.moving then table.insert(choices, arc) break end -- just 1
              end 
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1
              end 
             for index, cs in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
                  if cs:GetIsInCombat() then table.insert(choices, cs) break end
              end 
             for index, powerpoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
                  if ( powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() ) and powerpoint:GetIsInCombat() then table.insert(choices, powerpoint) break end --built and not disabled should be summed up by if in combat?
              end 
         ----    for index, alienbeacon in ientitylist(Shared.GetEntitiesWithClassname("AlienBeacon")) do
          --        if alienbeacon:GetIsAlive() then table.insert(choices, alienbeacon) break end --built and not disabled should be summed up by if in combat?
          ---    end 
             for index, onos in ientitylist(Shared.GetEntitiesWithClassname("Onos")) do
                  if onos.charging  then table.insert(choices, onos ) break end --built and not disabled should be summed up by if in combat?
              end  
              
              local random = table.random(choices)
              return random
end
 local function GetMiddleView()
  --Print("GetMiddleView")
--Beacons
-- <=30% hp constructs in combat
--moving arcs
--contam
local choices = {}
             for index, alienbeacon in ientitylist(Shared.GetEntitiesWithClassname("AlienBeacon")) do
                  if alienbeacon:isa("EggBeacon") or alienbeacon:isa("StructureBeacon") and alienbeacon:GetIsAlive() then table.insert(choices, alienbeacon) break end --built and not disabled should be summed up by if in combat?
              end 
             for index, obs in ientitylist(Shared.GetEntitiesWithClassname("Observatory")) do
                  if obs:GetIsBeaconing() or obs:GetIsAdvancedBeaconing() then table.insert(choices, obs) break end --built and not disabled should be summed up by if in combat?
              end  
      
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1
              end
        
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if construct:GetIsBuilt() and construct:GetHealthScalar() <= .7 and construct:GetIsInCombat() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end     

             for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                  if arc.moving then table.insert(choices, arc) break end --built and not disabled should be summed up by if in combat?
              end          
              
              
              local random = table.random(choices)
              return random

end
local function GetIsBusy(who)
local busy = false
   if who:isa("MAC") then
    busy = true --order is
   elseif who:isa("Drifter") then
   busy = true --order is
    end
return busy
end
local function GetSetupView()
 --Print("GetSetupView")
local choices = {}
--macs, drifters, not built constructs
             for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                  if GetIsBusy(mac) then table.insert(choices, mac) break end --built and not disabled should be summed up by if in combat?
              end     
             for index, drifter in ientitylist(Shared.GetEntitiesWithClassname("Drifter")) do
                  if GetIsBusy(drifter) then table.insert(choices, drifter) break end --built and not disabled should be summed up by if in combat?
              end    
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                  if not construct:isa("PowerPoint") and not construct:GetIsBuilt() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end                  
              

              local random = table.random(choices)
              return random

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
        -- Print("vip is %s", vip:GetClassName())
          if client:GetSpectatorMode() ~= kSpectatorMode.FreeLook then client:SetSpectatorMode(kSpectatorMode.FreeLook)  end
          --client:SelectEntity(vip:GetId()) 
          local viporigin = vip:GetOrigin()
             client:SetOrigin( FindFreeSpace(viporigin, 1, 8))
             local dir = GetNormalizedVector(viporigin - client:GetOrigin())
             local angles = Angles(GetPitchFromVector(dir), GetYawFromVector(dir), 0)
              client:SetDesiredCamera(8.0, {move = true}, client:GetEyePos(), angles, 0)
              self:NotifyGeneric( client, "VIP is %s", true, vip:GetClassName())
        else
             client:SetSpectatorMode(kSpectatorMode.FirstPerson)
         end

end
local function AutoSpectate(self, client)

    Shine.Timer.Create( "AutoSpectate", 8, -1, function() if client and client:isa("Spectator") then ChangeView(self, client) else Shine.Timer.Destroy("AutoSpectate") end  end )
end


function Plugin:ClientConnect(client)
     if client:GetUserId() == 8086089 then
     
     self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s 3", client:GetUserId() ))end
      end)
      
    elseif client:GetUserId() == 22542592 then 
     self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s 3", client:GetUserId() )) local Client = client:GetControllingPlayer() Client:SetSpectatorMode(kSpectatorMode.FirstPerson) AutoSpectate(self, Client) end
      end)
      
      end

end