--Bleh.

local gMarineMenuButtons =
{

    [kTechId.BuildMenu] = { kTechId.CommandStation, kTechId.Extractor, kTechId.InfantryPortal, kTechId.Armory,
                            kTechId.RoboticsFactory, kTechId.ArmsLab, kTechId.None, kTechId.None },
                            
    [kTechId.AdvancedMenu] = { kTechId.Sentry, kTechId.Observatory, kTechId.PhaseGate, kTechId.PrototypeLab, 
                               kTechId.SentryBattery, kTechId.None, kTechId.None, kTechId.None },

    [kTechId.AssistMenu] = { kTechId.AmmoPack, kTechId.MedPack, kTechId.NanoShield, kTechId.Scan,
                             kTechId.PowerSurge, kTechId.CatPack, kTechId.WeaponsMenu, kTechId.None, },
                             
    [kTechId.WeaponsMenu] = { kTechId.DropShotgun, kTechId.DropGrenadeLauncher, kTechId.DropFlamethrower, kTechId.DropWelder,
                              kTechId.DropMines, kTechId.DropJetpack, kTechId.DropHeavyMachineGun, kTechId.AssistMenu}


}

function MarineCommander:GetButtonTable()
    return gMarineMenuButtons
end