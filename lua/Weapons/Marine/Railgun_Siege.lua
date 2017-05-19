Print("Derp")

if Server then


    local origondmg = Railgun.OnDamageDone
    function Railgun:OnDamageDone(doer, target)
        origondmg(self, doer, target)
        if doer == self then
        
            if target:isa("Player") and target:GetIsAlive() then
                -- Print("Derp")
                if target:isa("Fade") then target:SetElectrified( math.random (2, 3) ) end
            end
            
        end
        
    end
    
end