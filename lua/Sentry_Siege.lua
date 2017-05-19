Script.Load("lua/Additions/LevelsMixin.lua")
Sentry.kFov = 360
Sentry.kMaxPitch = 180 
Sentry.kMaxYaw = Sentry.kFov / 2

function Sentry:GetFov()
    return 360
end

local networkVars = {}




AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)

function Sentry:GetAddXPAmount()
return kSentryWeldGainXp
end
function Sentry:GetLevelPercentage()
return self.level / self:GetMaxLevel() * 1.8
end

    local originit = Sentry.OnInitialized
    function Sentry:OnInitialized()
        originit(self)
        InitMixin(self, LevelsMixin)
    end
    
    function Sentry:GetMaxLevel()
    return 10
    end
    function Sentry:GetAddXPAmount()
    return 0.30
    end

function Sentry:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
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
 

