function TunnelEntrance:GetInfestationGrowthRate()
    return ConditionalValue(not GetIsInSiege(self), 0.25, 0.09)
end

function TunnelEntrance:GetInfestationRadius()
    return ConditionalValue(not GetIsInSiege(self), 7, 3.7) 
end