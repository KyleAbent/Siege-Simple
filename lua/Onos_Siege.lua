

function Onos:GetRebirthLength()
return 6
end
function Onos:GetRedemptionCoolDown()
return 45
end

function Onos:PreUpdateMove(input, runningPrediction)

    if self.charging then
        
        self:DeductAbilityEnergy(Onos.kChargeEnergyCost * input.time)
        if self:GetEnergy() == 0 or
           self:GetIsJumping() or
          (self.timeLastCharge + 1 < Shared.GetTime() and self:GetVelocity():GetLengthXZ() < 4.5) then
        
            self:EndCharge()
            
        end
        
    end
end

/*
function Onos:PreUpdateMove(input, runningPrediction)
end
*/

--local origspeed = Onos.GetMaxSpeed
--Onos.kMaxSpeed = 8
--Onos.kChargeSpeed = 13.7

function Onos:GetMaxSpeed(possible)
     local speed = 7.5
  
    if possible then
        return speed
    end
   if not self:GetIsOnFire() then speed = 9.375 end
    if self:GetIsPoopGrowing() then speed = 0 end
    local boneShieldSlowdown = self:GetIsBoneShieldActive() and kBoneShieldMoveFraction or 1
    local chargeExtra = self:GetChargeFraction() * (12 - speed)
    
    return ( speed + chargeExtra ) * boneShieldSlowdown
    
    
end



function Onos:GetHasMovementSpecial()
    return GetHasTech(self, kTechId.Charge)
end
function Onos:GetIsPoopGrowing()

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("OnoGrow") and activeWeapon.primaryAttacking then
        return true
    end    
    return false
    
end

--local orig_Onos_OnAdjustModelCoords = Onos.OnAdjustModelCoords
function Onos:OnAdjustModelCoords(modelCoords) 
--orig_Onos_OnAdjustModelCoords(self)
        local onoGrow = self:GetWeapon(OnoGrow.kMapName)
        local scale = 1
        if onoGrow then
          scale = onoGrow.modelsize
        end
    local coords = modelCoords
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    return coords
end

if Server then

function Onos:GetTierFourTechId()
    return kTechId.OnoGrow
end

function Onos:GetTierFiveTechId()
    return kTechId.OnicideStomp
end

end
