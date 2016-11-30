Script.Load("lua/Additions/LevelsMixin.lua")

class 'CommandStationAvoca' (CommandStation)
CommandStationAvoca.kMapName = "commandstationavoca"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)



    function CommandStationAvoca:OnInitialized()
         CommandStation.OnInitialized(self)
        InitMixin(self, LevelsMixin)
        self:SetTechId(kTechId.CommandStation)
    end
    
     function CommandStationAvoca:GetMaxLevel()
    return kDefaultLvl
    end
    function CommandStationAvoca:GetAddXPAmount()
    return kDefaultAddXp
    end   
   function CommandStationAvoca:OnGetMapBlipInfo()
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

Shared.LinkClassToMap("CommandStationAvoca", CommandStationAvoca.kMapName, networkVars)

