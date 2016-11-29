local Shine = Shine
local Plugin = Plugin

Shine.MapStatsData = {}

Plugin.Version = "1.0"

local MapStatsPath = "config://shine/plugins/mapstats.json"

function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
self.GameStarted = false
self.MarinesWon = false
self.AliensWon = false


return true
end
function Plugin:OnFirstThink() 
local MapStatsFile = Shine.LoadJSONFile( MapStatsPath  )
self.MapStatsData = MapStatsFile
end
function Plugin:NotifyMapStats( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[11.15> MapStats]",  255, 0, 0, String, Format, ... )
end
function Plugin:CreateCommands()

local function MapStats(Client)
        self:NotifyMapStats( Client, "%s: Aliens:%s, Marines:%s", true, Shared.GetMapName(), self:GetStatsData(true, false), self:GetStatsData(false, true) )
end 
local MapStatsCommand = self:BindCommand("sh_mapstats", "mapstats", MapStats, true, false)
MapStatsCommand:Help("sh_mapstats - Shares the win/lose ratios for both marines and aliens on the currentmap")

end
function Plugin:SetGameState( Gamerules, State, OldState )   
     if State == kGameState.Countdown then
           Shine.ScreenText.End(1)  
          Shine.ScreenText.End(2)  
          Shine.ScreenText.End(3) 
         self:NotifyGeneric( nil, "%s: Marines: %s, Aliens: %s", true, Shared.GetMapName(), self:GetStatsData(false, true), self:GetStatsData(true, false))                                    
     elseif State == kGameState.Team1Won  then
     local MapStatsFile = Shine.LoadJSONFile( MapStatsPath  )
     self.MapStatsData = MapStatsFile
     self.MarinesWon = true
     self:SimpleTimer(3, function()
     self.MapStatsData.Maps[tostring(Shared.GetMapName() ) ] = {marines = self:GetStatsData(false, true), aliens = self:GetStatsData(true, false) }
     Shine.SaveJSONFile( self.MapStatsData, MapStatsPath  )
    // self:ShowStats()
     self.MarinesWon = false
     end)
     elseif State == kGameState.Team2Won then
     local MapStatsFile = Shine.LoadJSONFile( MapStatsPath  )
     self.MapStatsData = MapStatsFile
     self.AliensWon = true
     self:SimpleTimer(3, function()
     self.MapStatsData.Maps[tostring(Shared.GetMapName() ) ] = {marines = self:GetStatsData(false, true), aliens = self:GetStatsData(true, false) }
     Shine.SaveJSONFile( self.MapStatsData, MapStatsPath  )
    // self:ShowStats()
     self.AliensWon = false 
     end)    
  end
end
function Plugin:GetStatsData(aliens, marines)
      local Map = self.MapStatsData.Maps[ tostring( Shared.GetMapName() ) ]
       if not Map then return 0 end
      if aliens then 
        local alienstats = 0
        if Map and Map.aliens then alienstats = Map.aliens end
        if self.AliensWon then alienstats = alienstats + 1 end
       return alienstats
     end
    if marines then
      local marinestats = 0
       if Map and Map.marines then marinestats = Map.marines end
       if self.MarinesWon then marinestats = marinestats + 1 end
       return marinestats
    end
end
        
function Plugin:ShowStats()
      local Map = self.MapStatsData.Maps[ tostring( Shared.GetMapName() ) ] 
      Shine.ScreenText.Add( 1, {X = 0.40, Y = 0.45,Text = "Map Stats:",Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
      Shine.ScreenText.Add( 2, {X = 0.40, Y = 0.50,Text = "Aliens:".. Map.aliens,Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
      Shine.ScreenText.Add( 3, {X = 0.40, Y = 0.55,Text = "Marines:".. Map.marines,Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[11.15 MapStats]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end