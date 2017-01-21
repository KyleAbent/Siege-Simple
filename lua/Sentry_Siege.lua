function Sentry:GetFov()
    return 360
end





--SentryBattery.kRange = 9999


Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")

class 'SentryAvoca' (Sentry)
SentryAvoca.kMapName = "sentryavoca"

local networkVars = {}




AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function SentryAvoca:OnInitialized()
         Sentry.kFov = 360
         Sentry.kMaxPitch = 360
        Sentry.kMaxYaw = 360
        Sentry.kBarrelMoveRate = 105 -- default 150
        InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
        self:SetTechId(kTechId.Sentry)
        Sentry.OnInitialized(self)
    end
        function SentryAvoca:GetTechId()
         return kTechId.Sentry
    end


if Server then

end
    function SentryAvoca:GetMaxLevel()
    return kDefaultLvl
    end
    function SentryAvoca:GetAddXPAmount()
    return kDefaultAddXp
    end


function SentryAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Sentry
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("SentryAvoca", SentryAvoca.kMapName, networkVars)

function GetCheckSentryLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName  and not sentry.isacreditstructure then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kCommSentryPerRoom
    
end


 

