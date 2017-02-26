Script.Load("lua/Additions/LevelsMixin.lua")

class 'CommandStationSiege' (CommandStation)
CommandStationSiege.kMapName = "commandstationsiege"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)



    function CommandStationSiege:OnInitialized()
         CommandStation.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        self:SetTechId(kTechId.CommandStation)
    end
    
     function CommandStationSiege:GetMaxLevel()
    return kDefaultLvl
    end
    function CommandStationSiege:GetAddXPAmount()
    return kDefaultAddXp
    end   
   function CommandStationSiege:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.CommandStation
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end 

Shared.LinkClassToMap("CommandStationSiege", CommandStationSiege.kMapName, networkVars)

