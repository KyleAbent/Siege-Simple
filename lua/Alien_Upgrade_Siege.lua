local function HasUpgrade(callingEntity, techId)

    if not callingEntity then
        return false
    end

    local techtree = GetTechTree(callingEntity:GetTeamNumber())

    if techtree then
        return callingEntity:GetHasUpgrade(techId) // and techtree:GetIsTechAvailable(techId)
    else
        return false
    end

end

function GetHasRedemptionUpgrade(callingEntity)
    return HasUpgrade(callingEntity, kTechId.Redemption) //or callingEntity.RTDRedemption
end
function GetHasRebirthUpgrade(callingEntity)
    return HasUpgrade(callingEntity, kTechId.Rebirth) //or callingEntity.RTDRedemption
end