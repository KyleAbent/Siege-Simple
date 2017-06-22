local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end


Script.Load("lua/shine/extensions/credits/client_Sand_menu.lua")
Shine.VoteMenu:AddPage ("SpendSand", function( self )
       local player = Client.GetLocalPlayer()
        self:AddSideButton( "Glow", function() self:SetPage( "SpendGlowSand" ) end)
        self:AddSideButton( "Badges", function() self:SetPage( "SpendBadges" ) end)
        self:AddBottomButton( "Back", function()self:SetPage("Main")end)  
end)
     
     
Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Disco", function() Shared.ConsoleCommand ("sh_disco")  end)
self:AddSideButton( "Sand", function()  self:SetPage( "SpendSand" ) end)
end)


