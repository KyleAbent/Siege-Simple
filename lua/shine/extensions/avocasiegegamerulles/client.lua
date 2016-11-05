local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

function Plugin:ShowTimer(who)
 if who then
GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar") 
end
end
 


