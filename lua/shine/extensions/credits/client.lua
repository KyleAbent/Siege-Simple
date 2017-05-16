local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:AddPage ("SpendStructures", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "Mac(40)", function() Shared.ConsoleCommand ("sh_buy Mac")  end)
    self:AddSideButton( "Arc(110)", function() Shared.ConsoleCommand ("sh_buy Arc")  end)
    self:AddSideButton( "Observatory(100)", function() Shared.ConsoleCommand ("sh_buy Observatory")  end)
    self:AddSideButton( "Sentry(80)", function() Shared.ConsoleCommand ("sh_buy Sentry")  end)
    self:AddSideButton( "BackupBattery(60)", function() Shared.ConsoleCommand ("sh_buy BackupBattery")  end)
    self:AddSideButton( "BackupLight(40)", function() Shared.ConsoleCommand ("sh_buy BackupLight")  end)
    self:AddSideButton( "Armory(120)", function() Shared.ConsoleCommand ("sh_buy Armory")  end)
    self:AddSideButton( "PhaseGate(150)", function() Shared.ConsoleCommand ("sh_buy PhaseGate")  end)
    self:AddSideButton( "InfantryPortal(150)", function() Shared.ConsoleCommand ("sh_buy InfantryPortal")  end)
    self:AddSideButton( "RoboticsFactory(100)", function() Shared.ConsoleCommand ("sh_buy RoboticsFactory")  end)
    self:AddSideButton( "Wall(100)", function() Shared.ConsoleCommand ("sh_buy Wall")  end)
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
    self:AddSideButton( "Hydra(25)", function() Shared.ConsoleCommand ("sh_buy Hydra")  end)
    self:AddSideButton( "Egg(75)", function() Shared.ConsoleCommand ("sh_buy SaltyEgg")  end)
    --self:AddSideButton( "Drifter(5)", function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
    self:AddSideButton( "Shade(100)", function() Shared.ConsoleCommand ("sh_buy Shade")  end)
    self:AddSideButton( "Crag(80)", function() Shared.ConsoleCommand ("sh_buy Crag")  end)
    self:AddSideButton( "Whip(100)", function() Shared.ConsoleCommand ("sh_buy Whip")  end)
    self:AddSideButton( "Shift(100)", function() Shared.ConsoleCommand ("sh_buy Shift")  end)
   -- self:AddSideButton( "Clog(2)", function() Shared.ConsoleCommand ("sh_buy Clog")  end)
      if player:isa("Gorge") then
    self:AddSideButton( "Tunnel@Hive(40)", function() Shared.ConsoleCommand ("sh_buycustom TunnelEntrance")  end)
      end
    //self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
            self:AddSideButton( "Extractor(5000)", function() Shared.ConsoleCommand ("sh_buy Extractor")  end)
    elseif  player:GetTeamNumber() == 2 then
      self:AddSideButton( "Harvester(5000)", function() Shared.ConsoleCommand ("sh_buy Harvester")  end)
    end
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendUpgrades", function( self )
        local player = Client.GetLocalPlayer()
        
        if player.GetHasResupply and not player:GetHasResupply() then
        self:AddSideButton( "Resupply(5)", function() Shared.ConsoleCommand ("sh_buyupgrade Resupply")  end)
        end
        
        if player.GetHasHeavyArmor and not player:GetHasHeavyArmor() then
        self:AddSideButton( "HeavyArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade HeavyArmor")  end)
        end
        if player.GetHasNanoArmor and not player:GetHasNanoArmor() then
        self:AddSideButton( "RegenArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade RegenArmor")  end)
        end
        
        if player.GetHasFireBullets and not player:GetHasFireBullets() then
        self:AddSideButton( "FireBullets(5)", function() Shared.ConsoleCommand ("sh_buyupgrade FireBullets")  end)
        end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendGlow", function( self )
        self:AddSideButton( "Purple(5)", function() Shared.ConsoleCommand ("sh_buyglow Purple")  end)
        self:AddSideButton( "Green(5)", function() Shared.ConsoleCommand ("sh_buyglow Green")  end)
        self:AddSideButton( "Gold(5)", function() Shared.ConsoleCommand ("sh_buyglow Gold")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendWeapons", function( self )
        self:AddSideButton( "Mines(10)", function() Shared.ConsoleCommand ("sh_buywp Mines")  end)
        self:AddSideButton( "HeavyMachineGun(35)", function() Shared.ConsoleCommand ("sh_buywp HeavyMachineGun")  end)
        self:AddSideButton( "Shotgun(20)", function() Shared.ConsoleCommand ("sh_buywp Shotgun")  end)
        self:AddSideButton( "FlameThrower(30)", function() Shared.ConsoleCommand ("sh_buywp FlameThrower")  end)
        self:AddSideButton( "GrenadeLauncher(30)", function() Shared.ConsoleCommand ("sh_buywp GrenadeLauncher")  end)
          self:AddSideButton( "Welder(6)", function() Shared.ConsoleCommand ("sh_buywp Welder")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
Shine.VoteMenu:AddPage ("SpendClasses", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "JetPack(80)", function() Shared.ConsoleCommand ("sh_buyclass JetPack")  end)
    self:AddSideButton( "MiniGunExo(200)", function() Shared.ConsoleCommand ("sh_buyclass MiniGun")  end)
    self:AddSideButton( "RailGunExo(190)", function() Shared.ConsoleCommand ("sh_buyclass RailGun")  end)
    self:AddSideButton( "WelderExo(150)", function() Shared.ConsoleCommand ("sh_buyclass Welder")  end)
    self:AddSideButton( "FlamerExo(170)", function() Shared.ConsoleCommand ("sh_buyclass Flamer")  end)
        elseif player:GetTeamNumber() == 2 then
      self:AddSideButton( "Gorge(90)", function() Shared.ConsoleCommand ("sh_buyclass Gorge")  end)
      self:AddSideButton( "Lerk(120)", function() Shared.ConsoleCommand ("sh_buyclass Lerk")  end)
      self:AddSideButton( "Fade(150)", function() Shared.ConsoleCommand ("sh_buyclass Fade")  end)
      self:AddSideButton( "Onos(180)", function() Shared.ConsoleCommand ("sh_buyclass Onos")  end)
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
                  self:AddSideButton ("Scan(10)", function()Shared.ConsoleCommand ("sh_buy Scan")end)
                  self:AddSideButton ("Medpack(10)", function()Shared.ConsoleCommand ("sh_buy Medpack")end)
           else
       self:AddSideButton ("NutrientMist(5)", function()Shared.ConsoleCommand ("sh_buy NutrientMist")end)
       self:AddSideButton( "EnzymeCloud(15)", function() Shared.ConsoleCommand ("sh_buy EnzymeCloud")  end)
       self:AddSideButton( "Ink(20)", function() Shared.ConsoleCommand ("sh_tbuy Ink")  end)
       self:AddSideButton( "Hallucination(15)", function() Shared.ConsoleCommand ("sh_buy Hallucination")  end)
       self:AddSideButton( "Contamination(10)", function() Shared.ConsoleCommand ("sh_buy Contamination")  end)
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
               
       if player:GetTeamNumber() == 1 then 
        self:AddSideButton( "Upgrades(Armslab)", function() self:SetPage( "SpendUpgrades" ) end)
      end  
             
     if player:GetTeamNumber() == 1 then 
        self:AddSideButton( "Glow", function() self:SetPage( "SpendGlow" ) end)
      end  
     
     self:AddBottomButton( "Back", function()self:SetPage("Main")end)
     
end)





     
     
Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Salt", function() self:SetPage( "SpendCredits" ) end)
end)


