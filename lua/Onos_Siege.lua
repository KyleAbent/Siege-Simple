--Script.Load("lua/Weapons/PredictedProjectile.lua")

local origcreate = Onos.OnCreate
function Onos:OnCreate()
origcreate(self)

--InitMixin(self, PredictedProjectileShooterMixin)



end
/*
local originit = Onos.OnInitialized 

function Onos:OnInitialized()

 originit(self)
 
  if Server then
     for i = 1, #self.freeAttachPoints do

       
       
        local freeAttachPoint = self.freeAttachPoints[i]
        if freeAttachPoint then
            local hydra = CreateEntity(Hydra.kMapName, self:GetOrigin(), 2)
            table.removevalue(self.freeAttachPoints, freeAttachPoint)
            --self.attachedBabblers[hydra:GetId()] = freeAttachPoint
            hydra:SetParent(self)
            hydra:SetAttachPoint(freeAttachPoint)

        end
     
     end
  
  end
  
end
*/
function Onos:GetRebirthLength()
return 5
end
function Onos:GetRedemptionCoolDown()
return 25
end

/*
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
*/

/*
function Onos:PreUpdateMove(input, runningPrediction)
end
*/




local origspeed = Onos.GetMaxSpeed

function Onos:GetMaxSpeed(possible)

local speed = origspeed(self, possible)

      if GetSiegeDoorOpen() then 
       speed = speed * kDuringSiegeOnosSpdBuff 
     end
     
    -- if self:GetIsPoopGrowing() then
    -- speed = 0.1
   --  end
     
     return speed
    
    
end



local origmodify = Onos.ModifyDamageTaken
function Onos:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

  origmodify(self, damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil  then
     -- Print("Derp 2")
       local damageReduct = 1
       
        if  self:GetIsCharging()  and GetSiegeDoorOpen() and not GetIsInSiege(self) then  
        damageReduct =  0.9
        end
        
        if damageReduct ~= 1 then
        damageTable.damage = damageTable.damage * damageReduct
        end
        
    end

end

function Onos:GetHasMovementSpecial()
    return GetHasTech(self, kTechId.Charge)
end

/*

function Onos:GetIsPoopGrowing()

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and ( activeWeapon:isa("OnoGrow") ) and activeWeapon.primaryAttacking then --or activeWeapon:isa("Onocide") ) and activeWeapon.primaryAttacking then
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


*/


/*

if Server then

function Onos:GetTierFourTechId()
    return kTechId.OnoGrow
end

function Onos:GetTierFiveTechId()
    return kTechId.Onocide
end

end

*/
