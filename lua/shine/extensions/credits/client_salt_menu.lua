Shine.VoteMenu:AddPage ("SpendStructuresSalt", function( self )
       local player = Client.GetLocalPlayer()
     if player:GetTeamNumber() == 1 then
		self:AddSideButton("Mac: "..gCreditStructureMacCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Mac salt")  end)
		self:AddSideButton("Arc: "..gCreditStructureArcCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Arc salt")  end)
		self:AddSideButton("Observatory: "..gCreditStructureObservatoryCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Observatory salt")  end)
		self:AddSideButton("Sentry: "..gCreditStructureSentryCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Sentry salt")  end)
		self:AddSideButton("BackupBattery: "..gCreditStructureBackUpBatteryCost * kPrestoSaltMul,  function() Shared.ConsoleCommand ("sh_buy BackupBattery salt")  end)
		self:AddSideButton("Armory: "..gCreditStructureArmoryCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Armory salt")  end)
    	self:AddTopButton("PhaseGate: "..gCreditStructurePhaseGateCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy PhaseGate salt")  end)
		self:AddSideButton("BackupLight: "..gCreditStructureBackupLightCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy BackupLight salt")  end)
		self:AddSideButton("InfantryPortal: "..gCreditStructureInfantryPortalCost * kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy InfantryPortal salt")  end)
        self:AddSideButton("RoboticsFactory: "..gCreditStructureRoboticsFactoryCost* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy RoboticsFactory salt") end)
       -- self:AddSideButton("Wall: "..gCreditStructureWallCost, function() Shared.ConsoleCommand ("sh_buy Wall") end)    
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
		if player:isa("Gorge") then
		self:AddTopButton("Tunnel@Hive: "..gCreditStructureCostTunnelToHive, function() Shared.ConsoleCommand ("sh_buycustom TunnelEntrance salt")  end)
        end
		--self:AddSideButton("PetDrifter: "..gCreditStructureCostPetDrifter, function() Shared.ConsoleCommand ("sh_buy PetDrifter")  end)
		self:AddSideButton("Drifter: "..gCreditStructureCostPerDrifter* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Drifter salt")  end)
		self:AddSideButton("Hydra: "..gCreditStructureCostHydra* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Hydra salt")  end)
		self:AddSideButton("SaltyEgg: "..gCreditStructureCostSaltyEgg* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy SaltyEgg salt")  end)
		--self:AddSideButton("Drifter: "..gCreditStructureCostDrifter, function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
		self:AddSideButton("Whip: "..gCreditStructureCostWhip* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Whip salt")  end)
		self:AddSideButton("Shift: "..gCreditStructureCostShift* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Shift salt")  end)
		self:AddSideButton("Shade: "..gCreditStructureCostShade* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Shade salt")  end)
		self:AddSideButton("Crag: "..gCreditStructureCostCrag* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Crag salt")  end)

   -- self:AddSideButton( "Clog(2)", function() Shared.ConsoleCommand ("sh_buy Clog")  end)
    //self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)
Shine.VoteMenu:AddPage ("SpendExpeniveSalt", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then
		self:AddSideButton("Extractor: "..gCreditStructureCostHarvesterExtractor* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Extractor salt")  end)
    elseif player:GetTeamNumber() == 2 then
		self:AddSideButton("Harvester: "..gCreditStructureCostHarvesterExtractor* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Harvester salt")  end)
    end
    self:AddBottomButton("Back", function()self:SetPage("SpendSalt")end)
end)

Shine.VoteMenu:AddPage ("SpendUpgradesSalt", function( self )
        local player = Client.GetLocalPlayer()
        
        if player.GetHasResupply and not player:GetHasResupply() then
        self:AddSideButton( "Resupply(5)", function() Shared.ConsoleCommand ("sh_buyupgrade Resupply salt")  end)
        end
        
        if player.GetHasLightArmor and not player:GetHasLightArmor() then
        self:AddSideButton( "LightArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade LightArmor salt")  end)
        end
        
        if player.GetHasHeavyArmor and not player:GetHasHeavyArmor() then
        self:AddSideButton( "HeavyArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade HeavyArmor salt")  end)
        end
        if player.GetHasNanoArmor and not player:GetHasNanoArmor() then
        self:AddSideButton( "RegenArmor(5)", function() Shared.ConsoleCommand ("sh_buyupgrade RegenArmor salt")  end)
        end
        
        if player.GetHasFireBullets and not player:GetHasFireBullets() then
        self:AddSideButton( "FireBullets(5)", function() Shared.ConsoleCommand ("sh_buyupgrade FireBullets salt")  end)
        end

        self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)

Shine.VoteMenu:AddPage ("SpendGlowSalt", function( self )
        self:AddSideButton( "Purple(5)", function() Shared.ConsoleCommand ("sh_buyglow Purple salt")  end)
        self:AddSideButton( "Green(5)", function() Shared.ConsoleCommand ("sh_buyglow Green salt")  end)
        self:AddSideButton( "Gold(5)", function() Shared.ConsoleCommand ("sh_buyglow Gold salt")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)

Shine.VoteMenu:AddPage ("SpendWeaponsSalt", function( self )
	    self:AddSideButton("Welder: "..gCreditWeaponCostWelder* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp Welder salt")  end)
	    self:AddSideButton("Cluster: "..gCreditWeaponCostGrenadeCluster* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp clustergrenade salt")  end)
	    self:AddSideButton("Stun: "..gCreditWeaponCostGrenadePulse* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp pulseGrenade salt")  end)
	    self:AddSideButton("NerveGas: "..gCreditWeaponCostGrenadeGas* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp gasgrenade salt")  end)
        self:AddSideButton("Mines: "..gCreditWeaponCostMines* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp Mines salt")  end)

        self:AddSideButton("FlameThrower: "..gCreditWeaponCostFlameThrower* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp FlameThrower salt")  end)
        self:AddSideButton("GrenadeLauncher: "..gCreditWeaponCostGrenadeLauncher* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp GrenadeLauncher salt")  end)
        self:AddSideButton("Shotgun: "..gCreditWeaponCostShotGun* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp Shotgun salt")  end)
       -- self:AddSideButton("HeavyRifle: "..gCreditWeaponCostHMG, function() Shared.ConsoleCommand ("sh_buywp HeavyRifle")  end)
        self:AddSideButton("HeavyMachineGun: "..gCreditWeaponCostHMG* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buywp HeavyMachineGun salt")  end)
       self:AddBottomButton("Back", function()self:SetPage("SpendSalt")end)

end)
Shine.VoteMenu:AddPage ("SpendClassesSalt", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton("JetPack: "..gCreditClassCostJetPack* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass JetPack salt") end) 
    self:AddSideButton("MiniGunExo: "..gCreditClassCostMiniGunExo* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass MiniGun salt") end) 
    self:AddSideButton("RailGunExo: "..gCreditClassCostRailGunExo* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass RailGun salt") end) 
    self:AddSideButton("WelderExo: "..gCreditClassCostWelderExo* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass Welder salt") end) 
    self:AddSideButton("FlamerExo: "..gCreditClassCostFlamerExo* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass Flamer salt") end) 
    elseif player:GetTeamNumber() == 2 then
		self:AddSideButton("Gorge: "..gCreditClassCostGorge*kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass Gorge salt")  end)
		self:AddSideButton("Lerk: "..gCreditClassCostLerk*kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass Lerk salt")  end)
		self:AddSideButton("Fade: "..gCreditClassCostFade*kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass Fade salt")  end)
        self:AddSideButton("Onos: "..gCreditClassCostOnos*kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buyclass Onos salt") end)
    end
        self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)
/*
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
        self:AddSideButton( "OffensiveConcGrenade(100) (WIP)", function() Shared.ConsoleCommand ("sh_buywp OffensiveConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 

end)
*/
/*
Shine.VoteMenu:AddPage ("SpendFunSalt ", function( self )
        self:AddSideButton( "JediConcGrenade(5) (WIP)", function() Shared.ConsoleCommand ("sh_buywp JediConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 

end)
*/
Shine.VoteMenu:AddPage ("SpendCommAbilitiesSalt", function( self )
       local player = Client.GetLocalPlayer()
if player:GetTeamNumber() == 1 then
		self:AddSideButton ("Scan: "..gCreditAbilityCostScan* kPrestoSaltMul, function()Shared.ConsoleCommand ("sh_buy Scan salt")end)
		self:AddSideButton ("Medpack: "..gCreditAbilityCostMedpack* kPrestoSaltMul, function()Shared.ConsoleCommand ("sh_buy Medpack salt")end)
	else
		self:AddSideButton("NutrientMist: "..gCreditAbilityCostNutrientMist* kPrestoSaltMul, function()Shared.ConsoleCommand ("sh_buy NutrientMist salt")end)
		self:AddSideButton("EnzymeCloud: "..gCreditAbilityCostEnzymeCloud* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy EnzymeCloud salt")  end)
		self:AddSideButton("Ink: "..gCreditAbilityCostInk* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_tbuy Ink")  end)
		self:AddSideButton("Hallucination: "..gCreditAbilityCostHallucination* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Hallucination salt")  end)
		self:AddSideButton("Contamination: "..gCreditAbilityCostContamination* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Contamination salt")  end)
end
     self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)