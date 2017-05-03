Sentry.kFov = 360
Sentry.kMaxPitch = 180 
Sentry.kMaxYaw = Sentry.kFov / 2

function Sentry:GetFov()
    return 360
end

local networkVars = {}




AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    
    function Sentry:GetMaxLevel()
    return kDefaultLvl
    end
    function Sentry:GetAddXPAmount()
    return kDefaultAddXp
    end



Shared.LinkClassToMap("Sentry", Sentry.kMapName, networkVars)

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

function Sentry:GetMinRangeAC()
return SentryAutoCCMR     
end
 

