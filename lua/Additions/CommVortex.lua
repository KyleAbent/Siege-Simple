Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'CommVortex' (CommanderAbility)

CommVortex.kMapName = "commvortex"

CommVortex.kVortexLoopingCinematic = PrecacheAsset("cinematics/alien/fade/vortex.cinematic")

CommVortex.kVortexLoopingSound = PrecacheAsset("sound/NS2.fev/alien/fade/vortex_loop")
CommVortex.kVortexEndCinematic = PrecacheAsset("cinematics/alien/fade/vortex_destroy.cinematic")

CommVortex.kType = CommanderAbility.kType.Repeat
CommVortex.kSearchRange = 5
local netWorkVars =
{
}

if Server then

    function CommVortex:OnInitialized()
    
        CommanderAbility.OnInitialized(self)
        
        // never show for marine commander
        local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom, kRelevantToTeam2Commander)
        self:SetExcludeRelevancyMask(mask)
        
        StartSoundEffectAtOrigin(CommVortex.kVortexLoopingSound, self:GetOrigin())

    end

end

function CommVortex:Perform()

    self.success = false
    local boolean = GetWhereIsInSiege(self:GetOrigin())
    local range = ConditionalValue(boolean, CommVortex.kSearchRange /2, CommVortex.kSearchRange )
    local entities = GetEntitiesWithMixinForTeamWithinRange("VortexAble", 1, self:GetOrigin(), range)
    local duration = ConditionalValue(boolean, 3, 6)
    for index, entity in ipairs(entities) do    
       if entity:GetCanBeVortexed() and not entity:GetIsVortexed() then
        entity:SetVortexDuration(duration)   
       end 
    end

end

function CommVortex:GetStartCinematic()
    return CommVortex.kVortexLoopingCinematic
end
function CommVortex:GetEndCinematic()
    return CommVortex.kVortexEndCinematic
end
function CommVortex:GetType()
    return CommVortex.kType
end

function CommVortex:GetUpdateTime()
    return 1.5
end

function CommVortex:GetLifeSpan()
    return kVortexLifeSpan 
end

Shared.LinkClassToMap("CommVortex", CommVortex.kMapName, netWorkVars)