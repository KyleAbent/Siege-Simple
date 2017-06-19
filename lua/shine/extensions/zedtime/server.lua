/*Kyle Abent SiegeModCommands 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin

--Shine.Hook.SetupClassHook( "NS2Gamerules", "TriggerZedTime", "HookZedTime", "PassivePre" )


Plugin.Version = "1.0"
Plugin.HasConfig = true
Plugin.ConfigName = "zedtime.json"

Plugin.DefaultConfig = {
minimumtimeinsecondsbetweenzeds = 90,
thismanykilledwithinthatmanyseconds = 6,
thismuchtimebetweenthatmanykilled = 5,
minimumdurationzedtime = 3,
maximumdurationzedtime = 5,
zedtimeslowdownspeed = 0.5,
ignorethisteamnumberwhencheckingzedtime = 2,
minimumplayerstoactivatezedtime = 16
}
Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true

function Plugin:Initialise()
self.Enabled = true
self.countofstructuresdestroyedwithinXtimespan = 0
self.minimumtimebetweenzeds = 0
self.lasttime = 0
self:CreateCommands()

return true
end
 function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[ZedTime]",  255, 0, 0, String, Format, ... )
end

 function Plugin:OnEntityKilled( Gamerules, Victim, Attacker, Inflictor, Point, Dir ) 
 
 
    
     if Shared.GetTime() > self.minimumtimebetweenzeds + self.Config.minimumtimeinsecondsbetweenzeds and Victim:GetTeamNumber() ~= self.Config.ignorethisteamnumberwhencheckingzedtime and not Victim:isa("Mine") then
          local gameRules = GetGamerules()
         if not GetImaginator():GetMarineEnabled() then return end
                      local add = 1
                      if Victim:isa("PowerPoint") then
                      add = 2
                      end
              self.countofstructuresdestroyedwithinXtimespan = self.countofstructuresdestroyedwithinXtimespan + add
               if self:TimerExists(1) then self:DestroyTimer(1) end         
           self:CreateTimer(1,self.Config.thismuchtimebetweenthatmanykilled, 1, function () self.countofstructuresdestroyedwithinXtimespan = 0 end) // self:NotifyGeneric( nil,  "5 sec timer reset destroyed count", true) end)
                   if self.countofstructuresdestroyedwithinXtimespan >= self.Config.thismanykilledwithinthatmanyseconds then
                   self:TriggerZedTime(self.Config.minimumdurationzedtime, self.Config.maximumdurationzedtime)
                   self.countofstructuresdestroyedwithinXtimespan = 0
                   self.minimumtimebetweenzeds = Shared.GetTime()
                   end
     end
     
     
     /*
     if Victim and Victim:isa("Player") and Attacker and Attacker:isa("Player") then
      self:NotifyKillStats(Victim, "Health:%s, Armor:%s", Attacker:GetHealth(), Attacker:GetArmor(), true)
     end
     */
     
end
function Plugin:NotifyKillStats( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[KillStats]",  255, 0, 0, String, Format, ... )
end
/*
function Plugin:HookZedTime()
      self:TriggerZedTime(self.Config.minimumdurationzedtime, self.Config.maximumdurationzedtime)
end
*/
function Plugin:AdjustPowerLights()
   Shine.ScreenText.Add( "28", {X = 0.45, Y = 0.45,Text = "ZedTime ends in %s",Duration = self.duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,},  nil )
end
function Plugin:ResetPowerLights()
  Shine.ScreenText.End(23) 
end
function Plugin:TriggerZedTime(min, max, force)
   // if Shine.GetHumanPlayerCount() < self.Config.minimumplayerstoactivatezedtime then return end
     if Shared.GetTime() > self.Config.minimumtimeinsecondsbetweenzeds + self.lasttime or force then
     self.lasttime = Shared.GetTime()
      self.duration = math.random(min,max)
     self:AdjustPowerLights()
     --GetGamerules():SendZedTimeActivationMessage()
     Shared.ConsoleCommand(string.format("speed %s", self.Config.zedtimeslowdownspeed)) 
    // Shine.ScreenText.Add( 73, {X = 0.45, Y = 0.70,Text = "Zed Time: %s",Duration = duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
     self:CreateTimer( 2, self.duration, 1, 
     function () 
     Shared.ConsoleCommand("speed 1" ) 
      self:ResetPowerLights()
--     GetGamerules():SendZedTimeDeActivationMessage()
      end )
    end
end




function Plugin:CreateCommands()


local function ZedTime( Client )
local Gamerules = GetGamerules()
if not Gamerules then return end
self:TriggerZedTime(self.Config.minimumdurationzedtime, self.Config.maximumdurationzedtime, true)
end 

local ZedTimeCommand = self:BindCommand( "sh_zedtime", "zedtime", ZedTime )
ZedTimeCommand:Help( "triggers zed time" )




end

