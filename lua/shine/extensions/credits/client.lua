local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:AddPage ("SpendStructures", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "Mac(5)", function() Shared.ConsoleCommand ("sh_buy Mac")  end)
    self:AddSideButton( "Arc(20)", function() Shared.ConsoleCommand ("sh_buy Arc")  end)
    self:AddSideButton( "Observatory(10)", function() Shared.ConsoleCommand ("sh_buy Observatory")  end)
    self:AddSideButton( "Sentry(8)", function() Shared.ConsoleCommand ("sh_buy Sentry")  end)
    self:AddSideButton( "BackupBattery(6)", function() Shared.ConsoleCommand ("sh_buy BackupBattery")  end)
    self:AddSideButton( "BackupLight(4)", function() Shared.ConsoleCommand ("sh_buy BackupLight")  end)
    self:AddSideButton( "Armory(12)", function() Shared.ConsoleCommand ("sh_buy Armory")  end)
    self:AddSideButton( "PhaseGate(15)", function() Shared.ConsoleCommand ("sh_buy PhaseGate")  end)
    self:AddSideButton( "InfantryPortal(15)", function() Shared.ConsoleCommand ("sh_buy InfantryPortal")  end)
    self:AddSideButton( "RoboticsFactory(10)", function() Shared.ConsoleCommand ("sh_buy RoboticsFactory")  end)
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
    self:AddSideButton( "Hydra(1)", function() Shared.ConsoleCommand ("sh_buy Hydra")  end)
    self:AddSideButton( "SaltyEgg(15)", function() Shared.ConsoleCommand ("sh_buy SaltyEgg")  end)
    --self:AddSideButton( "Drifter(5)", function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
    self:AddSideButton( "Shade(10)", function() Shared.ConsoleCommand ("sh_buy Shade")  end)
    self:AddSideButton( "Crag(10)", function() Shared.ConsoleCommand ("sh_buy Crag")  end)
    self:AddSideButton( "Whip(10)", function() Shared.ConsoleCommand ("sh_buy Whip")  end)
    self:AddSideButton( "Shift(10)", function() Shared.ConsoleCommand ("sh_buy Shift")  end)
   -- self:AddSideButton( "Clog(2)", function() Shared.ConsoleCommand ("sh_buy Clog")  end)
      if player:isa("Gorge") then
    self:AddSideButton( "Tunnel@Hive(4)", function() Shared.ConsoleCommand ("sh_buycustom TunnelEntrance")  end)
      end
    //self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
            self:AddSideButton( "Extractor(500)", function() Shared.ConsoleCommand ("sh_buy Extractor")  end)
    elseif  player:GetTeamNumber() == 2 then
      self:AddSideButton( "Harvester(500)", function() Shared.ConsoleCommand ("sh_buy Harvester")  end)
    end
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)


Shine.VoteMenu:AddPage ("SpendWeapons", function( self )

        self:AddSideButton( "Mines(1.5)", function() Shared.ConsoleCommand ("sh_buywp Mines")  end)
        self:AddSideButton( "HeavyMachineGun(5)", function() Shared.ConsoleCommand ("sh_buywp HeavyMachineGun")  end)
        self:AddSideButton( "Shotgun(2)", function() Shared.ConsoleCommand ("sh_buywp Shotgun")  end)
        self:AddSideButton( "FlameThrower(3)", function() Shared.ConsoleCommand ("sh_buywp FlameThrower")  end)
        self:AddSideButton( "GrenadeLauncher(3)", function() Shared.ConsoleCommand ("sh_buywp GrenadeLauncher")  end)
          self:AddSideButton( "Welder(2)", function() Shared.ConsoleCommand ("sh_buywp Welder")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
Shine.VoteMenu:AddPage ("SpendClasses", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "JetPack(8)", function() Shared.ConsoleCommand ("sh_buyclass JetPack")  end)
    self:AddSideButton( "MiniGunExo(30)", function() Shared.ConsoleCommand ("sh_buyclass MiniGun")  end)
    self:AddSideButton( "RailGunExo(29)", function() Shared.ConsoleCommand ("sh_buyclass RailGun")  end)
    self:AddSideButton( "WelderExo(25)", function() Shared.ConsoleCommand ("sh_buyclass Welder")  end)
    self:AddSideButton( "FlamerExo(27)", function() Shared.ConsoleCommand ("sh_buyclass Flamer")  end)
        elseif player:GetTeamNumber() == 2 then
      self:AddSideButton( "Gorge(9)", function() Shared.ConsoleCommand ("sh_buyclass Gorge")  end)
      self:AddSideButton( "Lerk(12)", function() Shared.ConsoleCommand ("sh_buyclass Lerk")  end)
      self:AddSideButton( "Fade(20)", function() Shared.ConsoleCommand ("sh_buyclass Fade")  end)
      self:AddSideButton( "Onos(25)", function() Shared.ConsoleCommand ("sh_buyclass Onos")  end)
    end
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
/*
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
        self:AddSideButton( "OffensiveConcGrenade(100) (WIP)", function() Shared.ConsoleCommand ("sh_buywp OffensiveConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 

end)
*/
Shine.VoteMenu:AddPage ("SpendFun", function( self )
        self:AddSideButton( "JediConcGrenade(5) (WIP)", function() Shared.ConsoleCommand ("sh_buywp JediConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 

end)

Shine.VoteMenu:AddPage ("SpendCommAbilities", function( self )
       local player = Client.GetLocalPlayer()
           if player:GetTeamNumber() == 1 then 
                  self:AddSideButton ("Scan(1)", function()Shared.ConsoleCommand ("sh_buy Scan")end)
                  self:AddSideButton ("Medpack(1)", function()Shared.ConsoleCommand ("sh_buy Medpack")end)
           else
       self:AddSideButton ("NutrientMist(1)", function()Shared.ConsoleCommand ("sh_buy NutrientMist")end)
       self:AddSideButton( "EnzymeCloud(1.5)", function() Shared.ConsoleCommand ("sh_buy EnzymeCloud")  end)
       self:AddSideButton( "Ink(2)", function() Shared.ConsoleCommand ("sh_tbuy Ink")  end)
       self:AddSideButton( "Hallucination(1.75)", function() Shared.ConsoleCommand ("sh_buy Hallucination")  end)
       self:AddSideButton( "Contamination(1)", function() Shared.ConsoleCommand ("sh_buy Contamination")  end)
     end
     self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)


Shine.VoteMenu:AddPage ("SpendCredits", function( self )
       local player = Client.GetLocalPlayer()
            self:AddSideButton( "CommAbilities", function() self:SetPage( "SpendCommAbilities" ) end)
    if player:GetTeamNumber() == 1 then 
        self:AddSideButton( "Weapons", function() self:SetPage( "SpendWeapons" ) end)
      end  


    

     self:AddSideButton( "Classes", function() self:SetPage( "SpendClasses" ) end) 
     self:AddSideButton( "Structures", function() self:SetPage( "SpendStructures" ) end)
             --  self:AddSideButton( "Fun", function() self:SetPage( "SpendFun" ) end)
               self:AddSideButton( "Expensive", function() self:SetPage( "SpendExpenive" ) end)
     self:AddBottomButton( "Back", function()self:SetPage("Main")end)
end)





     
     
Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Salt", function() self:SetPage( "SpendCredits" ) end)
end)


