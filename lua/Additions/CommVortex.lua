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

    local entities = GetEntitiesWithMixinForTeamWithinRange("VortexAble", 1, self:GetOrigin(), CommVortex.kSearchRange)
    
    for index, entity in ipairs(entities) do    
       if entity:GetCanBeVortexed() and not entity:GetIsVortexed() then
        entity:SetVortexDuration(6)   
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
    return 12 ///  6 is too short - It Basically dissapears a few seconds after finding a target!
end

Shared.LinkClassToMap("CommVortex", CommVortex.kMapName, netWorkVars)