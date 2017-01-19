Script.Load("lua/Additions/Convars.lua")
Script.Load("lua/Additions/EggBeacon.lua")
Script.Load("lua/Additions/StructureBeacon.lua")
Script.Load("lua/Weapons/Alien/PrimalScream.lua")
Script.Load("lua/Additions/BackupLight.lua")
Script.Load("lua/Additions/CommTunnel.lua")
Script.Load("lua/Additions/OnoGrow.lua")
Script.Load("lua/Additions/CragUmbra.lua")
Script.Load("lua/Additions/CommVortex.lua")
Script.Load("lua/Weapons/Alien/AcidRocket.lua")
Script.Load("lua/MAC_Siege.lua")


function CheckCommTunnelReq(techId, origin, normal, commander)
local tunnelEntrances = 0 
for index, tunnelEntrance in ientitylist(Shared.GetEntitiesWithClassname("CommTunnel")) do 
tunnelEntrances = tunnelEntrances + 1 
end

   local cyst = GetEntitiesWithinRange("Cyst", origin, 7)
   
   if #cyst >= 1 then 
   
         for i = 1, #cyst do
            local cysty = cyst[i]
                if cysty:GetCurrentInfestationRadius() == kInfestationRadius then
                return tunnelEntrances < 2
                 end
         end
   

   end
   
                return false


end

function GetCheckEggBeacon(techId, origin, normal, commander)
    local num = 0

        
        for index, shell in ientitylist(Shared.GetEntitiesWithClassname("EggBeacon")) do
        
           -- if not spur:isa("StructureBeacon") then 
                num = num + 1
          --  end
            
    end
    
    return num < 1
    
end

function GetCheckStructureBeacon(techId, origin, normal, commander)
    local num = 0

        
        for index, shell in ientitylist(Shared.GetEntitiesWithClassname("EggBeacon")) do
        
           -- if not spur:isa("StructureBeacon") then 
                num = num + 1
          --  end
            
    end
    
    return num < 1
    
end

local kSiege_TechData =
{        

 

                { [kTechDataId] = kTechId.ThickenedSkin, 
       [kTechDataCategory] = kTechId.ShiftHiveTwo,  
        [kTechDataDisplayName] = "Thickened Skin", 
      [kTechDataSponitorCode] = "A",  
      [kTechDataCostKey] = 10,
     [kTechDataTooltipInfo] = "+10% max hp", },
     
                     { [kTechDataId] = kTechId.Hunger, 
       [kTechDataCategory] = kTechId.CragHiveTwo,   
        [kTechDataDisplayName] = "Hunger", 
      [kTechDataSponitorCode] = "B",  
      [kTechDataCostKey] = 2, 
     [kTechDataTooltipInfo] = "10% health / energy gain, and effects of Enzyme on player kill (if gorge then structures not players) ", },
   



/*
             { [kTechDataId] = kTechId.JumpPack,
        [kTechDataCostKey] = kJumpPackCost,
        [kTechDataDisplayName] = "Jump Pack", 
        [kTechDataHotkey] = Move.Z, 
      [kTechDataTooltipInfo] = "Mimics the NS1/HL1 JumpPack (With Attempted Balance Modifications WIP) - Press DUCK + Jump @ the same time to mindfuck the alien team."},
*/

            { [kTechDataId] = kTechId.Rebirth, 
       [kTechDataCategory] = kTechId.CragHiveTwo,  
        [kTechDataDisplayName] = "Rebirth", 
      [kTechDataSponitorCode] = "A",  
      [kTechDataCostKey] = kRebirthCost, 
     [kTechDataTooltipInfo] = "Replaces death with gestation if cooldown is reached", },

      // Lifeform purchases
        { [kTechDataId] = kTechId.Redemption, 
       [kTechDataCategory] = kTechId.CragHiveTwo,  
        [kTechDataDisplayName] = "Redemption", 
      [kTechDataSponitorCode] = "B",  
      [kTechDataCostKey] = kRedemptionCost, 
     [kTechDataTooltipInfo] = "Will return you to a random (hive or beacon) egg spawn when 35% hp or lower (and cooldown reached)", },

 { [kTechDataId] = kTechId.DropMAC,  
 [kTechDataMapName] = DropMAC.kMapName, 
[kTechDataDisplayName] = "MAC", 
[kTechIDShowEnables] = false, 
[kTechDataTooltipInfo] =  "Now Constructable!", 
[kTechDataModel] = MAC.kModelName, 
            [kTechDataBuildTime] = 1,
[kTechDataCostKey] = kMACCost, 
[kStructureAttachRange] = 8,
[kTechDataSupply] = kMACSupply,
[kStructureAttachId] = { kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory },
[kStructureAttachRequiresPower] = true },

 { [kTechDataId] = kTechId.AcidRocket,        
  [kTechDataCategory] = kTechId.Fade,   
     [kTechDataMapName] = AcidRocket.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
    [kTechDataDamageType] = kDamageType.Corrode,  
     [kTechDataDisplayName] = "AcidRocket",
 [kTechDataTooltipInfo] = "Ranged Projectile dealing damage only to armor and structures"},

                 { [kTechDataId] = kTechId.CommVortex, 
        [kTechDataMapName] = CommVortex.kMapName, 
       [kTechDataAllowStacking] = true,
       [kTechDataIgnorePathingMesh] = true, 
       [kTechDataCollideWithWorldOnly] = true,
       [kTechDataRequiresInfestation] = true, 
      [kTechDataDisplayName] = "Etheral Gate", 
        [kTechDataCostKey] = kCommVortexCost, 
     [kTechDataCooldown] = kCommVortexCoolDown, 
      [kTechDataTooltipInfo] =  "Temporarily places marine structures/macs/arcs in another dimension rendering them unable to function correctly. "},

            { [kTechDataId] = kTechId.CragUmbra,
         [kTechDataDisplayName] = "UMBRA",
      --[kVisualRange] = Crag.kHealRadius, 
     [kTechDataCooldown] = kCragUmbraCooldown, 
     [kTechDataCostKey] = kCragUmbraCost,  
[kTechDataTooltipInfo] = "CRAG_UMBRA_TOOLTIP"},


  { [kTechDataId] = kTechId.CommTunnel,  
--[kTechDataSupply] = kCommTunnelSupply, 
[kTechDataBuildRequiresMethod] = CheckCommTunnelReq,
[kTechDataBuildMethodFailedMessage] = "2max/near fully infested cyst only",
[kTechDataGhostModelClass] = "AlienGhostModel", 
[kTechDataModel] = TunnelEntrance.kModelName, 
[kTechDataMapName] = CommTunnel.kMapName, 
[kTechDataMaxHealth] = kTunnelEntranceHealth, 
[kTechDataMaxArmor] = kTunnelEntranceArmor, 
 [kTechDataPointValue] = kTunnelEntrancePointValue, 
[kTechDataCollideWithWorldOnly] = true,
 [kTechDataDisplayName] = "Commander Tunnel", 
[kTechDataCostKey] = 4, 
[kTechDataRequiresInfestation] = false,
[kTechDataTooltipInfo] =  "GORGE_TUNNEL_TOOLTIP"}, 

   { [kTechDataId] = kTechId.OnoGrow,        
  [kTechDataCategory] = kTechId.Onos,   
     [kTechDataMapName] = OnoGrow.kMapName,  
[kTechDataCostKey] = kStabResearchCost,
 [kTechDataResearchTimeKey] = kStabResearchTime, 
 --   [kTechDataDamageType] = kStabDamageType,  
     [kTechDataDisplayName] = "OnoGrow",
[kTechDataTooltipInfo] = "wip"},


--AdvBeacTech
/*
        {
            [kTechDataId] = kTechId.AdvBeacTech,
            [kTechDataCostKey] = kAdvBeacTechChost,
            [kTechDataDisplayName] = "Advanced Beacon Tech",
            [kTechDataResearchTimeKey] = kAdvBeacTechTime,
            [kTechDataTooltipInfo] = "Unlocks Advanced Beacon (of which revives dead players and teleports exos)"
        },
*/
   { [kTechDataId] = kTechId.AdvancedBeacon,   
   [kTechDataBuildTime] = 0.1,   
   [kTechDataCooldown] = kAdvancedBeaconCoolDown,
    [kTechDataDisplayName] = "Advanced Beacon",   
   [kTechDataHotkey] = Move.B, 
    [kTechDataCostKey] = kAdvancedBeaconCost, 
[kTechDataTooltipInfo] = "Revives Dead Players as well. Powers off Observatory for a short duration after beaconing."},
								
								
								
				        { [kTechDataId] = kTechId.EggBeacon, 
        [kTechDataCooldown] = kEggBeaconCoolDown, 
         [kTechDataTooltipInfo] = "Eggs Spawn approximately at the placed Egg Beacon. Be careful as infestation is required.", 
        [kTechDataGhostModelClass] = "AlienGhostModel",   
           [kTechDataBuildRequiresMethod] = GetCheckEggBeacon,
            [kTechDataMapName] = EggBeacon.kMapName,        
                 [kTechDataDisplayName] = "Egg Beacon",
           [kTechDataCostKey] = kEggBeaconCost,   
            [kTechDataRequiresInfestation] = true, 
          [kTechDataHotkey] = Move.C,   
         [kTechDataBuildTime] = kEggBeaconBuildTime, 
        [kTechDataModel] = EggBeacon.kModelName,   
           [kTechDataBuildMethodFailedMessage] = "1 at a time",
         [kVisualRange] = 8,
[kTechDataMaxHealth] = kEggBeaconHealth, [kTechDataMaxArmor] = kEggBeaconArmor},


        { [kTechDataId] = kTechId.StructureBeacon, 
        [kTechDataCooldown] = kStructureBeaconCoolDown, 
         [kTechDataTooltipInfo] = "Structures move approximately at the placed Egg Beacon", 
        [kTechDataGhostModelClass] = "AlienGhostModel",   
            [kTechDataMapName] = StructureBeacon.kMapName,        
                 [kTechDataDisplayName] = "Structure Beacon",  [kTechDataCostKey] = kStructureBeaconCost,   
            [kTechDataRequiresInfestation] = true, [kTechDataHotkey] = Move.C,   
         [kTechDataBuildTime] = kStructureBeaconBuildTime, 
        [kTechDataModel] = StructureBeacon.kModelName,   
         [kVisualRange] = 8,
[kTechDataMaxHealth] = kStructureBeaconHealth, [kTechDataMaxArmor] = kStructureBeaconArmor},


				

           { [kTechDataId] = kTechId.BackupLight, 
           [kTechDataHint] = "Powered by thought!", 
           [kTechDataGhostModelClass] = "MarineGhostModel",  
           [kTechDataRequiresPower] = true,      
           [kTechDataMapName] = BackupLight.kMapName,   
         [kTechDataDisplayName] = "Backup Light", 
        [kTechDataSpecifyOrientation] = true,
        [kTechDataCostKey] = 5,     
        [kTechDataBuildMethodFailedMessage] = "1 per room",
        [kStructureBuildNearClass] = "SentryBattery",
        [kStructureAttachId] = kTechId.SentryBattery,
        [kTechDataBuildRequiresMethod] = GetCheckLightLimit,
        [kStructureAttachRange] = 5,
       [kTechDataModel] = BackupLight.kModelName,   
         [kTechDataBuildTime] = 6, 
         [kTechDataMaxHealth] = 1000,  --this could go in balancehealth etc
        [kTechDataMaxArmor] = 100,  
      [kTechDataPointValue] = 2, 
    [kTechDataHotkey] = Move.O, 
    [kTechDataNotOnInfestation] = false, 
[kTechDataTooltipInfo] = "This bad boy right here has the potential to blind anyone standing in its way.. or just.. you know.. help brighten the mood wherever it's placed.",
 [kTechDataObstacleRadius] = 0.25},
 
  
                  --Thanks dragon ns2c
       { [kTechDataId] = kTechId.PrimalScream,  
         [kTechDataCategory] = kTechId.Lerk,
       [kTechDataDisplayName] = "Primal Scream",
        [kTechDataMapName] =  Primal.kMapName,
         --[kTechDataCostKey] = kPrimalScreamCostKey, 
       -- [kTechDataResearchTimeKey] = kPrimalScreamTimeKey, 
 [kTechDataTooltipInfo] = "+Energy to teammates, enzyme cloud"},
 
    
        { [kTechDataId] = kTechId.MacSpawnOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Automatically spawn up to 8 macs for you",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "12 is currently the max amount to automatically spawn this way. Turning this on will automatically spawn up to this many for you"},
         
          { [kTechDataId] = kTechId.MacSpawnOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Disables automatic small mac spawning",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "For those who prefer micro-micro management"},
         
         { [kTechDataId] = kTechId.ArcSpawnOn,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Automatically spawn up to 12 arcs for you",       
         [kTechDataCostKey] = 0, 
         [kTechDataTooltipInfo] = "12 is currently the max amount of commander arcs. Turning this on will automatically spawn up to this many for you"},
         
          { [kTechDataId] = kTechId.ArcSpawnOff,    
          [kTechDataCooldown] = 5,    
          [kTechDataDisplayName] = "Disables automatic arc spawning",       
         [kTechDataCostKey] = 0, 
          [kTechDataTooltipInfo] = "For those who prefer micro-micro management"},
          
          

      
  
}   



local buildTechData = BuildTechData
function BuildTechData()

    local defaultTechData = buildTechData()
    local moddedTechData = {}
    local usedTechIds = {}
    
    for i = 1, #kSiege_TechData do
        local techEntry = kSiege_TechData[i]
        table.insert(moddedTechData, techEntry)
        table.insert(usedTechIds, techEntry[kTechDataId])
    end
    
    for i = 1, #defaultTechData do
        local techEntry = defaultTechData[i]
        if not table.contains(usedTechIds, techEntry[kTechDataId]) then
            table.insert(moddedTechData, techEntry)
        end
    end
    
    return moddedTechData

end


