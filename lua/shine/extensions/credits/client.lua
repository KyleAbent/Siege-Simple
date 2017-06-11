local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:AddPage ("SpendStructures", function( self )
       local player = Client.GetLocalPlayer()
     if player:GetTeamNumber() == 1 then
		self:AddSideButton("Mac: "..gCreditStructureMacCost, function() Shared.ConsoleCommand ("sh_buy Mac")  end)
		self:AddSideButton("Arc: "..gCreditStructureArcCost, function() Shared.ConsoleCommand ("sh_buy Arc")  end)
		self:AddSideButton("Observatory: "..gCreditStructureObservatoryCost, function() Shared.ConsoleCommand ("sh_buy Observatory")  end)
		self:AddSideButton("Sentry: "..gCreditStructureSentryCost, function() Shared.ConsoleCommand ("sh_buy Sentry")  end)
		self:AddSideButton("BackupBattery: "..gCreditStructureBackUpBatteryCost, function() Shared.ConsoleCommand ("sh_buy BackupBattery")  end)
		self:AddSideButton("Armory: "..gCreditStructureArmoryCost, function() Shared.ConsoleCommand ("sh_buy Armory")  end)
    	self:AddTopButton("PhaseGate: "..gCreditStructurePhaseGateCost, function() Shared.ConsoleCommand ("sh_buy PhaseGate")  end)
		self:AddSideButton("BackupLight: "..gCreditStructureBackupLightCost, function() Shared.ConsoleCommand ("sh_buy BackupLight")  end)
		self:AddSideButton("InfantryPortal: "..gCreditStructureInfantryPortalCost, function() Shared.ConsoleCommand ("sh_buy InfantryPortal")  end)
        self:AddSideButton("RoboticsFactory: "..gCreditStructureRoboticsFactoryCost, function() Shared.ConsoleCommand ("sh_buy RoboticsFactory") end)
        self:AddSideButton("Wall: "..gCreditStructureWallCost, function() Shared.ConsoleCommand ("sh_buy Wall") end)    
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
		if player:isa("Gorge") then
		self:AddTopButton("Tunnel@Hive: "..gCreditStructureCostTunnelToHive, function() Shared.ConsoleCommand ("sh_buycustom TunnelEntrance")  end)
        end

		self:AddSideButton("Hydra: "..gCreditStructureCostHydra, function() Shared.ConsoleCommand ("sh_buy Hydra")  end)
		self:AddSideButton("SaltyEgg: "..gCreditStructureCostSaltyEgg, function() Shared.ConsoleCommand ("sh_buy SaltyEgg")  end)
		--self:AddSideButton("Drifter: "..gCreditStructureCostDrifter, function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
		self:AddSideButton("Whip: "..gCreditStructureCostWhip, function() Shared.ConsoleCommand ("sh_buy Whip")  end)
		self:AddSideButton("Shift: "..gCreditStructureCostShift, function() Shared.ConsoleCommand ("sh_buy Shift")  end)
		self:AddSideButton("Shade: "..gCreditStructureCostShade, function() Shared.ConsoleCommand ("sh_buy Shade")  end)
		self:AddSideButton("Crag: "..gCreditStructureCostCrag, function() Shared.ConsoleCommand ("sh_buy Crag")  end)
		self:AddSideButton("Drifter: "..gCreditStructureCostDrifter, function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
   -- self:AddSideButton( "Clog(2)", function() Shared.ConsoleCommand ("sh_buy Clog")  end)
    //self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then
		self:AddSideButton("Extractor: "..gCreditStructureCostHarvesterExtractor, function() Shared.ConsoleCommand ("sh_buy Extractor")  end)
    elseif player:GetTeamNumber() == 2 then
		self:AddSideButton("Harvester: "..gCreditStructureCostHarvesterExtractor, function() Shared.ConsoleCommand ("sh_buy Harvester")  end)
    end
    self:AddBottomButton("Back", function()self:SetPage("SpendCredits")end)
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
	    self:AddSideButton("Welder: "..gCreditWeaponCostWelder, function() Shared.ConsoleCommand ("sh_buywp Welder")  end)
	    self:AddSideButton("Cluster: "..gCreditWeaponCostGrenadeCluster, function() Shared.ConsoleCommand ("sh_buywp clustergrenade")  end)
	    self:AddSideButton("Stun: "..gCreditWeaponCostGrenadePulse, function() Shared.ConsoleCommand ("sh_buywp pulseGrenade")  end)
	    self:AddSideButton("NerveGas: "..gCreditWeaponCostGrenadeGas, function() Shared.ConsoleCommand ("sh_buywp gasgrenade")  end)
        self:AddSideButton("Mines: "..gCreditWeaponCostMines, function() Shared.ConsoleCommand ("sh_buywp Mines")  end)

        self:AddSideButton("FlameThrower: "..gCreditWeaponCostFlameThrower, function() Shared.ConsoleCommand ("sh_buywp FlameThrower")  end)
        self:AddSideButton("GrenadeLauncher: "..gCreditWeaponCostGrenadeLauncher, function() Shared.ConsoleCommand ("sh_buywp GrenadeLauncher")  end)
        self:AddSideButton("Shotgun: "..gCreditWeaponCostShotGun, function() Shared.ConsoleCommand ("sh_buywp Shotgun")  end)
       -- self:AddSideButton("HeavyRifle: "..gCreditWeaponCostHMG, function() Shared.ConsoleCommand ("sh_buywp HeavyRifle")  end)
        self:AddSideButton("HeavyMachineGun: "..gCreditWeaponCostHMG, function() Shared.ConsoleCommand ("sh_buywp HeavyMachineGun")  end)
       self:AddBottomButton("Back", function()self:SetPage("SpendCredits")end)

end)

Shine.VoteMenu:AddPage ("SpendnoGestation", function( self )
		self:AddSideButton("Gorge: "..gCreditClassCostGorge*2, function() Shared.ConsoleCommand ("sh_buyclass GorgeFast")  end)
		self:AddSideButton("Lerk: "..gCreditClassCostLerk*2, function() Shared.ConsoleCommand ("sh_buyclass LerkFast")  end)
		self:AddSideButton("Fade: "..gCreditClassCostFade*2, function() Shared.ConsoleCommand ("sh_buyclass FadeFast")  end)
        self:AddSideButton("Onos: "..gCreditClassCostOnos*2, function() Shared.ConsoleCommand ("sh_buyclass OnosFast") end)
 self:AddBottomButton( "Back", function()self:SetPage("SpendClasses")end) 
end)
Shine.VoteMenu:AddPage ("SpendClasses", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton("JetPack: "..gCreditClassCostJetPack, function() Shared.ConsoleCommand ("sh_buyclass JetPack") end) 
    self:AddSideButton("MiniGunExo: "..gCreditClassCostMiniGunExo, function() Shared.ConsoleCommand ("sh_buyclass MiniGun") end) 
    self:AddSideButton("RailGunExo: "..gCreditClassCostRailGunExo, function() Shared.ConsoleCommand ("sh_buyclass RailGun") end) 
    self:AddSideButton("WelderExo: "..gCreditClassCostWelderExo, function() Shared.ConsoleCommand ("sh_buyclass Welder") end) 
    self:AddSideButton("FlamerExo: "..gCreditClassCostFlamerExo, function() Shared.ConsoleCommand ("sh_buyclass Flamer") end) 
    elseif player:GetTeamNumber() == 2 then
        self:AddSideButton("noGestation", function()  self:SetPage("SpendnoGestation")  end)  
		self:AddSideButton("Gorge: "..gCreditClassCostGorge, function() Shared.ConsoleCommand ("sh_buyclass Gorge")  end)
		self:AddSideButton("Lerk: "..gCreditClassCostLerk, function() Shared.ConsoleCommand ("sh_buyclass Lerk")  end)
		self:AddSideButton("Fade: "..gCreditClassCostFade, function() Shared.ConsoleCommand ("sh_buyclass Fade")  end)
        self:AddSideButton("Onos: "..gCreditClassCostOnos, function() Shared.ConsoleCommand ("sh_buyclass Onos") end)
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
		self:AddSideButton ("Scan: "..gCreditAbilityCostScan, function()Shared.ConsoleCommand ("sh_buy Scan")end)
		self:AddSideButton ("Medpack: "..gCreditAbilityCostMedpack, function()Shared.ConsoleCommand ("sh_buy Medpack")end)
	else
		self:AddSideButton("Mucous: "..gCreditAbilityCostMucous, function() Shared.ConsoleCommand ("sh_buy Mucous")  end)
		self:AddSideButton("NutrientMist: "..gCreditAbilityCostNutrientMist, function()Shared.ConsoleCommand ("sh_buy NutrientMist")end)
		self:AddSideButton("EnzymeCloud: "..gCreditAbilityCostEnzymeCloud, function() Shared.ConsoleCommand ("sh_buy EnzymeCloud")  end)
		self:AddSideButton("Ink: "..gCreditAbilityCostInk, function() Shared.ConsoleCommand ("sh_tbuy Ink")  end)
		self:AddSideButton("Hallucination: "..gCreditAbilityCostHallucination, function() Shared.ConsoleCommand ("sh_buy Hallucination")  end)
		self:AddSideButton("Contamination: "..gCreditAbilityCostContamination, function() Shared.ConsoleCommand ("sh_buy Contamination")  end)
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
             

        self:AddSideButton( "Glow", function() self:SetPage( "SpendGlow" ) end)
if player:isa("Onos") then 
		self:AddSideButton("LowGrav: "..2, function() Shared.ConsoleCommand ("sh_buycustom LowGrav")  end)
end
     
     self:AddBottomButton( "Back", function()self:SetPage("Main")end)
     
end)





     
     
Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Salt", function() self:SetPage( "SpendCredits" ) end)
end)


