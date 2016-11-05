--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


local TimersPath = "config://shine/plugins/doortimers.json"


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
return true
end

function Plugin:OnFirstThink() 
local TimersFile = Shine.LoadJSONFile( TimersPath )
self.TimersFile = CreditsFile
end

function Plugin:MapPostLoad()
      Server.CreateEntity(SandCastle.kMapName)
      
      local Data = self:GetTimerDataData( Shared.GetMapName() ) 
      if Data and Data.front and Data.siege then
      GetSandCastle().SiegeTimer = Data.siege
      GetSandCastle().FrontTimer =  Data.front
      end
           
      
end
function Plugin:GetTimerDataData(mapname
  if not self.TimersFile then return nil end
  if not self.TimersFile.Maps then return nil end)
  local Map = self.TimersFile.Maps[ tostring( mapname ) ]  --hm?
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
    local NowToFront = kFrontTimer - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
    Shine.ScreenText.Add( 1, {X = 0.40, Y = 0.75,Text = "Front Doors open in %s",Duration = FrontLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
end
local function AddSiegeTimer(who)
    local Client = who
    local NowToSiege = kSiegeTimer - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local SiegeLength =  math.ceil( Shared.GetTime() + NowToSiege - Shared.GetTime() )
    Shine.ScreenText.Add( 2, {X = 0.60, Y = 0.95,Text = "Siege Doors open in %s",Duration = SiegeLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 3,FadeIn = 0,}, Client )
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

local frontlength = GetSandCastle():GetFrontLength()
local siegelength = GetSandCastle:GetSiegeLength()

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