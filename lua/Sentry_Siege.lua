Sentry.kFov = 360
Sentry.kMaxPitch = 180
Sentry.kMaxYaw = Sentry.kFov / 2
Sentry.kBaseROF = kSentryAttackBaseROF
Sentry.kRandROF = kSentryAttackRandROF
Sentry.kSpread = Math.Radians(3)
kSentryAttackBaseROF = 0.10

Sentry.kBarrelScanRate = 33      -- Degrees per second to scan back and forth with no target
Sentry.kBarrelMoveRate = 90    -- Degrees per second to move sentry orientation towards target or back to flat when targeted

Sentry.kTargetAcquireTime = 0.10
Sentry.kAttackEffectIntervall = 0.3



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


 

