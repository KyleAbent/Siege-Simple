--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin



local OldUpdateBatteryState

local function NewUpdateBatteryState( self )
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 0.5) then
        
           local location = GetLocationForPoint(self:GetOrigin())
           local powerpoint = location ~= nil and GetPowerPointForLocation(location:GetName())   
            self.attachedToBattery = false
           if powerpoint then 
            self.attachedToBattery = powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled() 
            end
            self.lastBatteryCheckTime = time
        end
end

OldUpdateBatteryState = Shine.Hook.ReplaceLocalFunction( Sentry.OnUpdate, "UpdateBatteryState", NewUpdateBatteryState )




Plugin.Version = "1.0"

function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
return true
end

function Plugin:MapPostLoad()

      Server.CreateEntity(SandCastle.kMapName)
end

local function GetSandCastle() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SandCastle")
    if entityList:GetSize() > 0 then
                 local sandcastle = entityList:GetEntityAtIndex(0) 
                 return sandcastle
    end    
    return nil
end

function Plugin:ClientConnect(client)
     if client:GetUserId() == 22542592 or client:GetUserId() == 8086089 then
     

     self:SimpleTimer( 4, function() 
     if client then Shared.ConsoleCommand(string.format("sh_setteam %s 3", client:GetUserId() )) end
      end)
      end

end
local function AddFrontTimer(who)
    local Client = who
    local NowToFront = GetSandCastle():GetFrontLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
    Shine.ScreenText.Add( 1, {X = 0.40, Y = 0.75,Text = "Front Doors open in %s",Duration = FrontLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end
local function AddSiegeTimer(who)
    local Client = who
    local NowToSiege = GetSandCastle():GetSiegeLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local SiegeLength =  math.ceil( Shared.GetTime() + NowToSiege - Shared.GetTime() )
    Shine.ScreenText.Add( 2, {X = 0.40, Y = 0.95,Text = "Siege Doors open in %s",Duration = SiegeLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end
local function AddSideTimer(who)
    local Client = who
    local NowToSide = GetSandCastle():GetSideLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local SideLength =  math.ceil( Shared.GetTime() + NowToSide - Shared.GetTime() )
    Shine.ScreenText.Add( 3, {X = 0.40, Y = 0.65,Text = "Side Doors open in %s",Duration = SideLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end
local function GiveTimersToAll()
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddFrontTimer(Player)
                  AddSiegeTimer(Player) --Downside is the 30 min expiration date. Upside is no timer goes beyond 20.
                  AddSideTimer(Player)
                  end
end
end
function Plugin:SendMessageToMods(string)
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Shine:GetUserImmunity(Player:GetClient()) >= 10 then --isamod 
                  self:NotifyMods( Player, "%s", true, string)
                  end
               end
end
function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end

                   self:SimpleTimer( 4, function() 
                  if not Client then return end
                   Shine.ScreenText.Add( 27, {X = 0.80, Y = 0.20,Text = "Server Rules:",Duration = 30,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 2,FadeIn = 0,}, Client )
                 end)
                   self:SimpleTimer( 8, function() 
                  if not Client then return end
 Shine.ScreenText.Add( 28, {X = 0.80, Y = 0.25,Text = "No Exploiting",Duration = 24,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 2,FadeIn = 0,}, Client )
                   end)
                   self:SimpleTimer( 12, function() 
                  if not Client then return end
 Shine.ScreenText.Add( 29, {X = 0.80, Y = 0.30,Text = "No Bullying",Duration = 16,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 2,FadeIn = 0,}, Client )
                 end)
 
 
      
if GetGamerules():GetGameStarted() then

--local frontlength = GetSandCastle():GetFrontLength()
--local siegelength = GetSandCastle:GetSiegeLength()
if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kFrontTimer then
     AddFrontTimer(Client)
   end
   
 if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSiegeTimer then
         AddSiegeTimer(Client)
   end
   
    if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSideTimer then
         AddSideTimer(Client)
   end
   
   


end

end

function Plugin:SetGameState( Gamerules, State, OldState )

 if State == kGameState.Started then 
    GiveTimersToAll()
  else
 Shine.ScreenText.End(1) 
 Shine.ScreenText.End(2)
 Shine.ScreenText.End(3)
  end 
  
           if State == kGameState.Countdown then
             GetSandCastle():OnRoundStart()
       elseif State == kGameState.NotStarted then
             GetSandCastle():OnPreGame()
          end
          
    
end

function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyMods( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Moderator Chat]",  255, 0, 0, String, Format, ... )
end
function Plugin:GiveCyst(Player)
            local ent = CreateEntity(CystAvoca.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  
             ent:SetConstructionComplete()
end


function Plugin:CreateCommands()


local function Slap( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           self:NotifyGeneric( nil, "slapping %s for %s seconds", true, Player:GetName(), Number)
            self:CreateTimer( 13, 1, Number, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists(13) then self:DestroyTimer( 13 ) return end
            Player:SetVelocity(  Player:GetVelocity() + Vector(math.random(-900,900),math.random(-900,900),math.random(-900,900)  ) )
            end )
end
end
end
local SlapCommand = self:BindCommand( "sh_slap", "slap", Slap)
SlapCommand:Help ("sh_slap <player> <time> Slaps the player once per second random strength")
SlapCommand:AddParam{ Type = "clients" }
SlapCommand:AddParam{ Type = "number" }
/*

local function Gravity( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("Commander") and Player:isa("Alien") or Player:isa("Marine") or Player:isa("ReadyRoomTeam") then
              self:NotifyGeneric( nil, "Adjusted %s 's gravity to %s", true, Player:GetName(), Number)
              Player.gravity = Number
             end
//Glitchy way. There's resistance in the first person camera, to this. Perhaps try hooking with shine and changing that way, instead.
     end
end
local GravityCommand = self:BindCommand( "sh_gravity", "playergravity", Gravity )
GravityCommand:AddParam{ Type = "clients" }
GravityCommand:AddParam{ Type = "number" }
GravityCommand:Help( "sh_gravity <player> <number> works differently than ns1. kinda glitchy. respawn to reset." )

*/
local function Bury( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           Player:SetOrigin(Player:GetOrigin() - Vector(0, .5, 0))
         self:NotifyGeneric( nil, "Burying %s for %s seconds", true, Player:GetName(), Number)
            self:CreateTimer( 14, Number, 1, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists(14) then self:DestroyTimer( 14 ) return end
            Player:SetOrigin(Player:GetOrigin() + Vector(0, .5, 0))
            end )
end
end
end

local BuryCommand = self:BindCommand( "sh_bury", "bury", Bury)
BuryCommand:Help ("sh_bury <player> <time> Buries the player for the given time")
BuryCommand:AddParam{ Type = "clients" }
BuryCommand:AddParam{ Type = "number" }

local function Destroy( Client, String  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  self:NotifyGeneric( nil, "destroyed %s in %s", true, entity:GetMapName(), entity:GetLocationName())
                  DestroyEntity(entity)
             end
         end
end
local DestroyCommand = self:BindCommand( "sh_destroy", "destroy", Destroy )
DestroyCommand:AddParam{ Type = "string" }
DestroyCommand:Help( "Destroy <string> Destroys all entities with this name within 8 radius" )

/*
local function ModelSize( Client, Targets, Number, Boolean )
  if Number > 10 then return end
    self:NotifyGeneric( nil, "Adjusted %s players size to %s percent. HP/ARMOR bonus boolean set to: %s", true, #Targets, Number * 100)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("Commander") and not Player:isa("Spectator") and Player.modelsize and Player:GetIsAlive() then
             //  if not ( Player:isa("Exo") or Player:isa("Onos") and Number >= 2 ) or Number ~= 1 then Player:SetCameraDistance(Number) end
                Player.modelsize = Number
               local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
              if Boolean == true then  Player:AdjustMaxHealth(defaulthealth * Number) end
               if Boolean == true then Player:AdjustMaxArmor(Player:GetMaxArmor() * Number) end
             --   self.playersize[Player:GetClient()] = Number
             end
     end
end
local ModelSizeCommand = self:BindCommand( "sh_modelsize", "modelsize", ModelSize )
ModelSizeCommand:AddParam{ Type = "clients" }
ModelSizeCommand:AddParam{ Type = "number" }
ModelSizeCommand:Help( "sh_modelsize <player> <size> <true/false for health armor bonus>" )
ModelSizeCommand:AddParam{ Type = "boolean", optional = true }
*/
local function Give( Client, Targets, String, Number )
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Player and Player:GetIsAlive() and String ~= "alien" and not (Player:isa("Alien") and String == "armory") and not (Player:isa"ReadyRoomTeam" and String == "CommandStation" or String == "Hive") and not Player:isa("Commander") then
/*
Player:GiveItem(String)
        for index, target in ipairs(GetEntitiesWithMixinWithinRangeAreVisible("Construct", Player:GetOrigin(), 3, true )) do
              if not target:GetIsBuilt() then target:SetConstructionComplete() end
          end
 */
           
 local teamnum = Number and Number or Player:GetTeamNumber()
 local ent = CreateEntity(String, Player:GetOrigin(), teamnum)  
if HasMixin(ent, "Construct") then  ent:SetConstructionComplete() end
             Shine:CommandNotify( Client, "gave %s an %s", true,
			 Player:GetName() or "<unknown>", String )  
end
end
end
local GiveCommand = self:BindCommand( "sh_give", "give", Give )
GiveCommand:AddParam{ Type = "clients" }
GiveCommand:AddParam{ Type = "string" }
GiveCommand:AddParam{ Type = "number", optional = true }
GiveCommand:Help( "<player> Give item to player(s)" )


local function Chat( Client, String )
           
      self:SendMessageToMods(String)
end
local ChatCommand = self:BindCommand( "sh_chat", "chat", Chat )
ChatCommand:AddParam{ Type = "string" }
ChatCommand:Help( "for mods to talk in private. Only mods can see and use this chat." )


local function OpenSiegeDoors()
   for index, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
              sandcastle:OpenSiegeDoors(true)
      end 
end
local function Cyst( Client, Targets )
     for i = 1, #Targets do
     local Player = Targets[ i ]:GetControllingPlayer()
         if Player and Player:GetIsAlive() and Player:isa("Alien") and not Player:isa("Commander") then
             self:GiveCyst(Player)
           self:NotifyGeneric( nil, "Gave %s an Cyst", true, Player:GetName())
          end
     end
end
local CystCommand = self:BindCommand( "sh_cyst", "cyst", Cyst )
CystCommand:AddParam{ Type = "clients" }
CystCommand:Help( "<player> Give cyst to player(s)" )
local function OpenFrontDoors()
           for index, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
                sandcastle:OpenFrontDoors() 
                end

end
local function OpenSideDoors()
           for index, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
                sandcastle:OpenSideDoors() 
                end

end
local function Open( Client, String )
local Gamerules = GetGamerules()
     if String == "Front" or String == "front" then
       OpenFrontDoors()
        Shine.ScreenText.End(1) 
     elseif String == "Side" or String == "side" then
       OpenSideDoors()
       Shine.ScreenText.End(3)
     elseif String == "Siege" or String == "siege" then
        OpenSiegeDoors()
         Shine.ScreenText.End(2) 
         return
    end 
  self:NotifyGeneric( nil, "Opened the %s doors", true, String)  
  
end 

local OpenCommand = self:BindCommand( "sh_open", "open", Open )
OpenCommand:AddParam{ Type = "string" }
OpenCommand:Help( "Opens <type> doors (Front/Side/Siege) (not case sensitive) - timer will still display." )


end