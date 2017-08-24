kRemoveXSupplyEveryMin = 8

/*
kOnoGrowEnergyCost = 20
kOnocideEnergyCost = 20
kOnocideMaxDuration = 4
kOnocideOnoGrowCoolDown = 12.5
*/


kDuringSiegeOnosSpdBuff = 1.25
kPrimalDMGBuff = 1.05
WhipStealFT = 10
kWhipStealFTTime = 20

kPrestoSaltMul = 10
kPresToSaltMultWeapons = 7
kPresToStructureMult = 8
kPresToClassesMult = 9

kPresArmoryProtoEquivMult = 1.5


kBonewallLifeSpan = 5

--gCreditStructureCostPetDrifter = 5
gCreditStructureCostPerDrifter = 5
kFadeBlinkSpeedBuff = 1.10
--kALienCragWhipShadeShiftDynamicSpeedBpdB = 1.75 -- Nerf if in siege room??
kNumberofGlows = 3

kSentrysPerRoom = 6 --6

kWallCommLimitPerRoom = 5


kWallWalkMarineCost = 10

--Credits Start

--Credits Structures Marine
gCreditStructureWallCost = 15
gCreditStructureWallLimit = 2

gCreditStructureObservatoryCost = 10
gCreditStructureArmoryCost = 10
gCreditStructureSentryCost = 5
gCreditStructureSentryLimit = 2
gCreditStructureBackUpBatteryCost = 10
gCreditStructureBackUpBatteryLimit = 1

gCreditStructureBackupLightCost = 5
gCreditStructureBackupLightLimit = 2

gCreditStructurePhaseGateCost = 15
gCreditStructurePhaseGateLimit = 2
gCreditStructureInfantryPortalCost = 20
gCreditStructureInfantryPortalLimit = 3

gCreditStructureRoboticsFactoryCost = 10
gCreditStructureRoboticsFactoryLimit = 3

gCreditStructureMacCost = 5
gCreditStructureMacLimit = 3

gCreditStructureArcCost = 10
gCreditStructureArcLimit = 2

gCreditStructureExtractorCost = 2000
gCreditStructureExtractorLimit = 1



--Classes Credits Cost
gCreditClassCostJetPack = 15 * kPresArmoryProtoEquivMult

gCreditClassCostRailGunExo = 34 * kPresArmoryProtoEquivMult
gCreditClassCostMiniGunExo = 35 * kPresArmoryProtoEquivMult

gCreditClassCostWelderExo = 25 * kPresArmoryProtoEquivMult
gCreditClassCostFlamerExo = 30 * kPresArmoryProtoEquivMult

gCreditClassDelayJetPack = 10
gCreditClassDelayRailGun = 15
gCreditClassDelayMiniGun = 15

gCreditClassCostSkulk = 1
gCreditClassCostGorge = 10 
gCreditClassCostLerk = 20 
gCreditClassCostFade = 40 
gCreditClassCostOnos = 65 

gCreditClassDelaySkulk = 1
gCreditClassDelayGorge = 5
gCreditClassDelayLerk = 10
gCreditClassDelayFade = 15
gCreditClassDelayOnos = 20


--Weapons Credits Cost

gCreditWeaponCostHeavyRifle =  kHeavyRifleCost * kPresArmoryProtoEquivMult
gCreditWeaponCostMines = kMineCost * kPresArmoryProtoEquivMult
gCreditWeaponCostWelder = kWelderCost * kPresArmoryProtoEquivMult
gCreditWeaponCostHMG = kHeavyMachineGunCost * kPresArmoryProtoEquivMult
gCreditWeaponCostShotGun = kShotgunCost * kPresArmoryProtoEquivMult
gCreditWeaponCostFlameThrower = kFlamethrowerCost * kPresArmoryProtoEquivMult
gCreditWeaponCostGrenadeLauncher = kGrenadeLauncherCost * kPresArmoryProtoEquivMult
gCreditWeaponCostGrenadeGas = kClusterGrenadeCost * kPresArmoryProtoEquivMult
gCreditWeaponCostGrenadeCluster = kClusterGrenadeCost * kPresArmoryProtoEquivMult
gCreditWeaponCostGrenadePulse = kClusterGrenadeCost * kPresArmoryProtoEquivMult



--Alien Abilities  Credits Cost
gCreditAbilityCostInk = 3 --1.5
gCreditAbilityCostNutrientMist = 1
gCreditAbilityCostHallucination = 10
gCreditAbilityCostEnzymeCloud = 10
gCreditAbilityCostMucous = 10
gCreditAbilityCostContamination = 5


--Alien Abilities  Credits Delay
gCreditAbilityDelayInk = 50 --1.5
gCreditAbilityDelayNutrientMist = 0
gCreditAbilityDelayHallucination = 10
gCreditAbilityDelayEnzymeCloud = 10
gCreditAbilityDelayContamination = 10


--Alien Structures Credits Cost
gCreditStructureCostHydra = 6
gCreditStructureCostSaltyEgg = 5
gCreditStructureLimitSaltyEgg = 4
gCreditStructureCostShade = 13
gCreditStructureCostCrag = 13
gCreditStructureCostWhip = 13
gCreditStructureCostShift = 13
gCreditStructureCostTunnelToHive = 10
gCreditStructureCostHarvesterExtractor = 200
gCreditStructureLimitHarvesterExtractor = 1
--gCreditStructureCost =

--Alien Structures Credits Delay After Purchasing
gCreditStructureDelayHydra = 1
gCreditStructureDelaySaltyEgg = 10
gCreditStructureDelayShade = 5
gCreditStructureDelayCrag = 5
gCreditStructureDelayWhip = 5
gCreditStructureDelayShift = 8
gCreditStructureDelayTunnelToHive = 10
gCreditStructureDelay = 5
gCreditStructureDelayHarvesterExtractor = 15
--gCreditStructureDelay =

--Credit Mariners Tech


gCreditAbilityCostScan = 3
gCreditAbilityDelayScan = 4

gCreditAbilityCostMedpack = 2
gCreditAbilityDelayMedpack = 4
-----------------------------------


kTimeAfterSiegeOpeningToEnableSuddenDeath = 900 --900

/*

kResupplyCost = 5
kHeavyArmorCost = 5
kFireBulletsCost = 5
kNanoArmorCost = 4


kJumpPackCost = 10

*/


ArmoryAutoCCMR =  16
PGAutoCCMRMax = 54
PGAutoCCMRMin = 32
ObsAutoCCMR = kScanRadius
RoboAutoCCMR = 54 / 2
SentryAutoCCMR = 16
ProtoAutoCCMR = 35 / 3
--CommandStationAutoCCMR = math.random(16,420)
ArmsLabAutoCCMR = 4
IPAutoCCMR = 8

ShadeAutoCCMR = 16 / 2
ShiftAutoCCMR  = kEnergizeRange / 2
CragAutoCCMR  = 14 / 3
WhipAutoCCMR  = 14 / 3





kExoFlamerDamage = 25
kExoWelderDamagePerSecond = 28
kExoPlayerWeldRate = 15
kExoStructureWeldRate = 65

kNanoArmorHealPerSecond = 2
kObsAdvBeaconPowerOff = 16 --12 w/ lvl 25
kEggBeaconBuildTime = 8
kStructureBeaconBuildTime = 8
--kJumpPackCost = 7

kAcidRocketDamage = 25
kAcidRocketDamageType = kDamageType.Structural
kAcidRocketFireDelay = 0.5
kAcidRocketEnergyCost = 10
kAcidRocketRadius = 6

--kAdvBeacTechChost = 15
--kAdvBeacTechTime = 30 

kCommVortexCoolDown = 20
kCommVortexCost = 8 

kCragUmbraCooldown = 10
kCragUmbraCost = 5
kCragUmbraRadius = 12

kAlienDefaultLvl = 50
kAlienDefaultAddXp = 1

kDoorMoveUpVect = 40
kAdvancedBeaconCost = 13
kEggBeaconCost = 10
kEggBeaconCoolDown = 12

/*

kStructureBeaconCoolDown = 12
kStructureBeaconCost = 10

kEggBeaconHealth = 472
kEggBeaconArmor = 122
kStructureBeaconHealth = 675
kStructureBeaconArmor = 175 
*/


kPrimaryTimer = 0
kSideTimer = 0 -- b/c maps still use this


kPrimalScreamEnergyCost = 20
kPrimalScreamROF = 1.25

kBatteryPowerRange = 4

kInfantryPortalMaxLevel = 0
kDefaultLvl = 0
kDefaultAddXp = 0
kArmoryAddXp = 0
kArmoryLvl = 0
kInfantryPortalXPGain = 0
kCommSentryPerRoom = 0
kMacMaxLevel = 0











