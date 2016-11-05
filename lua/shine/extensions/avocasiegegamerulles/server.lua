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
local function GiveTimersToAll()
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddFrontTimer(Player)
                  AddSiegeTimer(Player) --Downside is the 30 min expiration date. Upside is no timer goes beyond 20.
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


end

end

function Plugin:SetGameState( Gamerules, State, OldState )

 if State == kGameState.Started then 
    GiveTimersToAll()
  else
 Shine.ScreenText.End(1) 
 Shine.ScreenText.End(2)
  end 
  
           if State == kGameState.Countdown then
             GetSandCastle():OnRoundStart()
       --elseif State == kGameState.NotStarted then
         --    GetSandCastle():OnPreGame()
          end
          
    
end

function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  255, 0, 0, String, Format, ... )
end

function Plugin:CreateCommands()

local function OpenSiegeDoors()
   for index, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
              sandcastle:OpenSiegeDoors(true)
      end 
end

local function OpenFrontDoors()
           for index, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
                sandcastle:OpenFrontDoors(true) 
                end

end

local function Open( Client, String )
local Gamerules = GetGamerules()
     if String == "Front" or String == "front" then
       OpenFrontDoors()
        Shine.ScreenText.End(1) 
     elseif String == "Side" or String == "side" then
      -- Gamerules:OpenSideDoors()
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