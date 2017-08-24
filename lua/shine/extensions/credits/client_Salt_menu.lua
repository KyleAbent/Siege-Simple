

Shine.VoteMenu:AddPage ("SpendStructuresSalt", function( self )
       local player = Client.GetLocalPlayer()
     if player:GetTeamNumber() == 1 then
		self:AddSideButton("Mac: "..gCreditStructureMacCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Mac salt")  end)
		self:AddSideButton("Arc: "..gCreditStructureArcCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Arc salt")  end)
		self:AddSideButton("Observatory: "..gCreditStructureObservatoryCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Observatory salt")  end)
		self:AddSideButton("Sentry: "..gCreditStructureSentryCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Sentry salt")  end)
		--self:AddSideButton("BackupBattery: "..gCreditStructureBackUpBatteryCost * kPresToStructureMult,  function() Shared.ConsoleCommand ("sh_buy BackupBattery salt")  end)
		self:AddSideButton("Armory: "..gCreditStructureArmoryCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Armory salt")  end)
    	self:AddTopButton("PhaseGate: "..gCreditStructurePhaseGateCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy PhaseGate salt")  end)
		self:AddSideButton("BackupLight: "..gCreditStructureBackupLightCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy BackupLight salt")  end)
		self:AddSideButton("InfantryPortal: "..gCreditStructureInfantryPortalCost * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy InfantryPortal salt")  end)
        self:AddSideButton("RoboticsFactory: "..gCreditStructureRoboticsFactoryCost* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy RoboticsFactory salt") end)
       -- self:AddSideButton("Wall: "..gCreditStructureWallCost, function() Shared.ConsoleCommand ("sh_buy Wall") end)    
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
		if player:isa("Gorge") then
		self:AddTopButton("Tunnel@Hive: "..gCreditStructureCostTunnelToHive * kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buycustom TunnelEntrance salt")  end)
        end
		--self:AddSideButton("PetDrifter: "..gCreditStructureCostPetDrifter, function() Shared.ConsoleCommand ("sh_buy PetDrifter")  end)
		self:AddSideButton("Drifter: "..gCreditStructureCostPerDrifter* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Drifter salt")  end)
		self:AddSideButton("Hydra: "..gCreditStructureCostHydra* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Hydra salt")  end)
		--self:AddSideButton("SaltyEgg: "..gCreditStructureCostSaltyEgg* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy SaltyEgg salt")  end)
		--self:AddSideButton("Drifter: "..gCreditStructureCostDrifter, function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
		self:AddSideButton("Whip: "..gCreditStructureCostWhip* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Whip salt")  end)
		self:AddSideButton("Shift: "..gCreditStructureCostShift* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Shift salt")  end)
		self:AddSideButton("Shade: "..gCreditStructureCostShade* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Shade salt")  end)
		self:AddSideButton("Crag: "..gCreditStructureCostCrag* kPresToStructureMult, function() Shared.ConsoleCommand ("sh_buy Crag salt")  end)

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
	    self:AddSideButton("Welder: "..gCreditWeaponCostWelder* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp Welder salt")  end)
	    self:AddSideButton("Cluster: "..gCreditWeaponCostGrenadeCluster* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp clustergrenade salt")  end)
	    self:AddSideButton("Stun: "..gCreditWeaponCostGrenadePulse* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp pulseGrenade salt")  end)
	    self:AddSideButton("NerveGas: "..gCreditWeaponCostGrenadeGas* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp gasgrenade salt")  end)
        self:AddSideButton("Mines: "..gCreditWeaponCostMines* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp Mines salt")  end)

        self:AddSideButton("FlameThrower: "..gCreditWeaponCostFlameThrower* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp FlameThrower salt")  end)
        self:AddSideButton("GrenadeLauncher: "..gCreditWeaponCostGrenadeLauncher* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp GrenadeLauncher salt")  end)
        self:AddSideButton("Shotgun: "..gCreditWeaponCostShotGun* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp Shotgun salt")  end)
       -- self:AddSideButton("HeavyRifle: "..gCreditWeaponCostHMG, function() Shared.ConsoleCommand ("sh_buywp HeavyRifle")  end)
        self:AddSideButton("HeavyMachineGun: "..gCreditWeaponCostHMG* kPresToSaltMultWeapons, function() Shared.ConsoleCommand ("sh_buywp HeavyMachineGun salt")  end)
       self:AddBottomButton("Back", function()self:SetPage("SpendSalt")end)

end)

Shine.VoteMenu:AddPage ("FastGestation", function( self )
		self:AddSideButton("Gorge: "..(gCreditClassCostGorge*kPresToClassesMult)*1.7, function() Shared.ConsoleCommand ("sh_buyclass Gorge salt fast")  end)
		self:AddSideButton("Lerk: "..(gCreditClassCostLerk*kPresToClassesMult)*1.7, function() Shared.ConsoleCommand ("sh_buyclass Lerk salt fast")  end)
		self:AddSideButton("Fade: "..(gCreditClassCostFade*kPresToClassesMult)*1.7, function() Shared.ConsoleCommand ("sh_buyclass Fade salt fast")  end)
        self:AddSideButton("Onos: "..(gCreditClassCostOnos*kPresToClassesMult)*1.7, function() Shared.ConsoleCommand ("sh_buyclass Onos salt fast") end)
       self:AddBottomButton("Back", function()self:SetPage("SpendClassesSalt")end)
end)


Shine.VoteMenu:AddPage ("SpendClassesSalt", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton("JetPack: "..gCreditClassCostJetPack* kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass JetPack salt") end) 
    self:AddSideButton("MiniGunExo: "..gCreditClassCostMiniGunExo* kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass MiniGun salt") end) 
    self:AddSideButton("RailGunExo: "..gCreditClassCostRailGunExo* kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass RailGun salt") end) 
    self:AddSideButton("WelderExo: "..gCreditClassCostWelderExo* kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass Welder salt") end) 
    self:AddSideButton("FlamerExo: "..gCreditClassCostFlamerExo* kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass Flamer salt") end) 
    elseif player:GetTeamNumber() == 2 then
        self:AddSideButton( "FastGestation", function()self:SetPage("FastGestation")end)
		self:AddSideButton("Gorge: "..gCreditClassCostGorge*kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass Gorge salt")  end)
		self:AddSideButton("Lerk: "..gCreditClassCostLerk*kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass Lerk salt")  end)
		self:AddSideButton("Fade: "..gCreditClassCostFade*kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass Fade salt")  end)
        self:AddSideButton("Onos: "..gCreditClassCostOnos*kPresToClassesMult, function() Shared.ConsoleCommand ("sh_buyclass Onos salt") end)
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
		self:AddSideButton("Mucous: "..gCreditAbilityCostMucous * kPrestoSaltMul, function()Shared.ConsoleCommand ("sh_buy Mucous salt")end)
		self:AddSideButton("EnzymeCloud: "..gCreditAbilityCostEnzymeCloud* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy EnzymeCloud salt")  end)
		self:AddSideButton("Ink: "..gCreditAbilityCostInk* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_tbuy Ink")  end)
		self:AddSideButton("Hallucination: "..gCreditAbilityCostHallucination* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Hallucination salt")  end)
		self:AddSideButton("Contamination: "..gCreditAbilityCostContamination* kPrestoSaltMul, function() Shared.ConsoleCommand ("sh_buy Contamination salt")  end)
end
     self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)


Shine.VoteMenu:AddPage ("RemoveBadges", function( self )
        self:AddSideButton( "1 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 1 Salt")  end)
        self:AddSideButton( "2 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 2 Salt")  end)
        self:AddSideButton( "3 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 3 Salt")  end)
        self:AddSideButton( "4 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 4 Salt")  end)
        self:AddSideButton( "5 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 5 Salt")  end)
        self:AddSideButton( "6 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 6 Salt")  end)
        self:AddSideButton( "7 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 7 Salt")  end)
        self:AddSideButton( "8 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 8 Salt")  end)
        self:AddSideButton( "9 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 9 Salt")  end)
        self:AddSideButton( "10 (500)", function() Shared.ConsoleCommand ("sh_buyremovebadge 10 Salt")  end)
          self:AddBottomButton( "Back", function()self:SetPage("SpendBadges")end) 
end)
Shine.VoteMenu:AddPage ("SpendBadges", function( self )
        self:AddTopButton( "RemoveBadges", function() self:SetPage( "RemoveBadges" ) end)
        self:AddSideButton( "cockatiel (5k)", function() Shared.ConsoleCommand ("sh_buybadge cockatiel Salt")  end)
        self:AddSideButton( "weed (5k)", function() Shared.ConsoleCommand ("sh_buybadge weed Salt")  end)
        self:AddSideButton( "pepe (5k)", function() Shared.ConsoleCommand ("sh_buybadge pepe Salt")  end)
        self:AddSideButton( "trump (5k)", function() Shared.ConsoleCommand ("sh_buybadge trump Salt")  end)
        self:AddSideButton( "sonic (5k)", function() Shared.ConsoleCommand ("sh_buybadge sonic Salt")  end)
        self:AddSideButton( "finger (5k)", function() Shared.ConsoleCommand ("sh_buybadge finger Salt")  end)
        self:AddSideButton( "pistol (5k)", function() Shared.ConsoleCommand ("sh_buybadge pistol Salt")  end)
        self:AddSideButton( "peter (5k)", function() Shared.ConsoleCommand ("sh_buybadge peter Salt")  end)
        self:AddSideButton( "feels (5k)", function() Shared.ConsoleCommand ("sh_buybadge feels Salt")  end)
        self:AddSideButton( "heart (5k)", function() Shared.ConsoleCommand ("sh_buybadge heart Salt")  end)
        

        
      --  self:AddSideButton( "Badge 2(5)", function() Shared.ConsoleCommand ("sh_buybadge Badge2 Salt")  end)
      --  self:AddSideButton( "Badge 3(5)", function() Shared.ConsoleCommand ("sh_buybadge Badge3 Salt")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)


Shine.VoteMenu:AddPage ("SpendBadges", function( self )
        self:AddTopButton( "RemoveBadges", function() self:SetPage( "RemoveBadges" ) end)
        self:AddSideButton( "cockatiel (5k)", function() Shared.ConsoleCommand ("sh_buybadge cockatiel sand")  end)
        self:AddSideButton( "weed (5k)", function() Shared.ConsoleCommand ("sh_buybadge weed sand")  end)
        self:AddSideButton( "pepe (5k)", function() Shared.ConsoleCommand ("sh_buybadge pepe sand")  end)
        self:AddSideButton( "trump (5k)", function() Shared.ConsoleCommand ("sh_buybadge trump sand")  end)
        self:AddSideButton( "sonic (5k)", function() Shared.ConsoleCommand ("sh_buybadge sonic sand")  end)
        self:AddSideButton( "finger (5k)", function() Shared.ConsoleCommand ("sh_buybadge finger sand")  end)
        self:AddSideButton( "pistol (5k)", function() Shared.ConsoleCommand ("sh_buybadge pistol sand")  end)
        self:AddSideButton( "peter (5k)", function() Shared.ConsoleCommand ("sh_buybadge peter sand")  end)
        self:AddSideButton( "feels (5k)", function() Shared.ConsoleCommand ("sh_buybadge feels sand")  end)
        self:AddSideButton( "heart (5k)", function() Shared.ConsoleCommand ("sh_buybadge heart sand")  end)
        

        
      --  self:AddSideButton( "Badge 2(5)", function() Shared.ConsoleCommand ("sh_buybadge Badge2 Salt")  end)
      --  self:AddSideButton( "Badge 3(5)", function() Shared.ConsoleCommand ("sh_buybadge Badge3 Salt")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)


Shine.VoteMenu:AddPage ("SpendGlowSalt", function( self )
        self:AddSideButton( "Purple(5)", function() Shared.ConsoleCommand ("sh_buyglow Purple sand")  end)
        self:AddSideButton( "Green(5)", function() Shared.ConsoleCommand ("sh_buyglow Green sand")  end)
        self:AddSideButton( "Gold(5)", function() Shared.ConsoleCommand ("sh_buyglow Gold sand")  end)
      --  self:AddSideButton( "Red(5)", function() Shared.ConsoleCommand ("sh_buyglow Red")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendSalt")end) 
end)
