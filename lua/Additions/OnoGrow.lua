--Kyle 'Avoca' Abent
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")
Script.Load("lua/Additions/PoopEgg.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

class 'OnoGrow' (Ability)

OnoGrow.kMapName = "onogrow"

local networkVars =
{
    timeFuelChanged = "private time",
    fuelAtChange = "private float (0 to 1 by 0.01)",
    modelsize = "float (1 to 2 by 0.1)",
    
}
AddMixinNetworkVars(StompMixin, networkVars)

function OnoGrow:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, StompMixin)
    
    self.timeFuelChanged = 0
    self.fuelAtChange = 1
    self.modelsize = 1
    self.durationofholdingdownmouse = 0

end
function OnoGrow:SetFuel(fuel)
   self.timeFuelChanged = Shared.GetTime()
   self.fuelAtChange = fuel
end

function OnoGrow:GetFuel()
    if self.primaryAttacking then
        return Clamp(self.fuelAtChange - (Shared.GetTime() - self.timeFuelChanged) / kOnocideMaxDuration, 0, 1)
    else
        return Clamp(self.fuelAtChange + (Shared.GetTime() - self.timeFuelChanged) / kOnocideOnoGrowCoolDown, 0, 1)
    end
end

function OnoGrow:GetEnergyCost()
    return kOnoGrowEnergyCost
end

function OnoGrow:GetAnimationGraphName()
    return kAnimationGraph
end

function OnoGrow:GetHUDSlot()
    return 3
end

function OnoGrow:GetCooldownFraction()
    return 1 - self:GetFuel()
end
    
function OnoGrow:IsOnCooldown()
     local boolean = self:GetFuel() < 0.9
     --Print("IsOnCooldown is %s", boolean)
     return boolean
end

function OnoGrow:GetOnoGrow(player)
    local boolean = not self:IsOnCooldown() and not self.secondaryAttacking and not player.charging 
   -- Print("Canuse is %s", boolean)
    return boolean
end

function OnoGrow:OnPrimaryAttack(player)
  --Print("Umm123")
    if not self.primaryAttacking then
          -- Print("Energy cost is %s, player energy is %s, player has more energy is %s", self:GetEnergyCost(),  player:GetEnergy(), self:GetEnergyCost() < player:GetEnergy())
        if player:GetIsOnGround() and self:GetOnoGrow(player) and self:GetEnergyCost() < player:GetEnergy() then
           --     Print("Umm")
            player:DeductAbilityEnergy(self:GetEnergyCost())
            
            self:SetFuel( self:GetFuel() ) -- set it now, because it will go down from this point
            self.primaryAttacking = true
            
            if Server then
                player:TriggerEffects("onos_shield_start")
            end
        end
    end

end

function OnoGrow:OnPrimaryAttackEnd(player)
    
    if self.primaryAttacking then 
    
        self:SetFuel( self:GetFuel() ) -- set it now, because it will go up from this point
        self.primaryAttacking = false
    
    end
    
end

function OnoGrow:OnUpdateAnimationInput(modelMixin)

    local activityString = "none"
    local abilityString = "boneshield"
    
    if self.primaryAttacking then
        activityString = "primary" -- TODO: set anim input
    end
    
    modelMixin:SetAnimationInput("ability", abilityString)
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function OnoGrow:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self:OnPrimaryAttackEnd(player)
    
end
function OnoGrow:OnEggFilled(player)

end
function OnoGrow:OnProcessMove(input)
   local parent = self:GetParent()
    if self.primaryAttacking then
        
        if self:GetFuel() > 0 then
                if  self.durationofholdingdownmouse == 0 then
                  self.durationofholdingdownmouse = Shared.GetTime() 
                  if parent then parent:SetCameraDistance(3) end
                  end
                 parent:DeductAbilityEnergy(1)                
                self.modelsize = Clamp(self.modelsize + (0.5 * input.time), 1, 2 )
                --parent:SetDesiredCameraYOffset(self.modelsize  )
        else
           self.modelsize = Clamp(self.modelsize - (0.5 * input.time), 1, 2)
            self:SetFuel( 0 )
            parent:SetCameraDistance(0)
            self.primaryAttacking = false
            self.durationofholdingdownmouse = 0
               if Shared.GetTime() > self.durationofholdingdownmouse + 6 then
                     if Server then
                      local egg = GetEntitiesForTeam( "PoopEgg", 2 )
                      local count = table.count(egg) or 0
                      if count < 8  then
                      local egg = CreateEntity(PoopEgg.kMapName, parent:GetOrigin() + Vector(0, .5, 0), parent:GetTeamNumber())
                      else
                        self:OnEggFilled(parent)
                    end --count
                     end --server
            end --shared.
        end -- orig
        
   else
       self.durationofholdingdownmouse = 0
       parent:SetCameraDistance(0)
              self.modelsize = Clamp(self.modelsize - (0.5 * input.time), 1, 2)
              
             -- if self.modelsize ~= 1 then 
             -- parent:SetDesiredCameraYOffset(self.modelsize)
            --  end
              
              end
              
           

end

Shared.LinkClassToMap("OnoGrow", OnoGrow.kMapName, networkVars)