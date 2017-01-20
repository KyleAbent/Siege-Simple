JetpackMarine.kJetpackFuelReplenishDelay = .27 -- 30% deduction of .4



function JetpackMarine:GetFuel()

    local dt = Shared.GetTime() - self.timeJetpackingChanged

    --overwrote to not apply weapon weight
    local weightFactor = math.max( kJetpackWeightLiftForce, kMinWeightJetpackFuelFactor )
    local rate = -kJetpackUseFuelRate * weightFactor
    
    if not self.jetpacking then
        rate = kJetpackReplenishFuelRate
        dt = math.max(0, dt - JetpackMarine.kJetpackFuelReplenishDelay)
    end
    
    if self:GetDarwinMode() then
        return 1
    else
        return Clamp(self.jetpackFuelOnChange + rate * dt, 0, 1)
    end
    
end