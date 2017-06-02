Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/Additions/DigestCommMixin.lua")

local networkVars = { salty = "private boolean" }

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(DigestCommMixin, networkVars)

local origcreate = Whip.OnCreate
function Whip:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
 end
  
function Whip:GetInfestationRadius()
    if self.salty then
    return 1
    else
    return 0
    end
end
function Whip:GetMinRangeAC()
return WhipAutoCCMR       
end

local origbuttons = Whip.GetTechButtons
function Whip:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[4] = kTechId.WhipExplode
 table[8] = kTechId.Digest
 return table

end

local origact = Whip.PerformActivation
function Whip:PerformActivation(techId, position, normal, commander)
origact(self, techId, position, normal, commander)

local success  = false
   if  techId == kTechId.WhipExplode then
    success = self:TriggerExplode()
end

return success, true

end

function Whip:TriggerExplode()

                self:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(self:GetOrigin())})
                local hitEntities = GetEntitiesWithMixinForTeamWithinRange( "Live", 1, self:GetOrigin(), kXenocideRange )
                local count = #GetEntitiesWithinRange("Whip", self:GetOrigin(), kXenocideRange)
                      count = Clamp(count, 1, 4)
              --   Print("Coount is %s", count)
                local scalar = Clamp(self:GetHealthScalar() / count, 0.30, 1)
              --   Print("Scalar is %s", scalar)
                local damage = ( kXenocideDamage + 25 ) * scalar
               --  Print ("Damage is %s", damage)
                RadiusDamage(hitEntities, self:GetOrigin(), kXenocideRange, damage, self)
                self:Kill()
                   return true
end

if Server then

function Whip:TryAttack(selector)
    return selector:AcquireTarget()
end

function Whip:UpdateRootState()
    
    local infested = self:GetGameEffectMask(kGameEffect.OnInfestation) or self.salty
    local moveOrdered = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Move
    -- unroot if we have a move order or infestation recedes
    if self.rooted and (moveOrdered or not infested) then
        self:Unroot()
    end
    
    -- root if on infestation and not moving/teleporting
    if not self.rooted and infested and not (moveOrdered or self:GetIsTeleporting()) then
        self:Root()
    end
    
end

end

function Whip:OnOrderGiven()
   if not  GetImaginator():GetAlienEnabled() and self:GetInfestationRadius() ~= 0 then self:SetInfestationRadius(0) end
end
    
    function Whip:GetMaxLevel()
    return kAlienDefaultLvl
    end
    function Whip:GetAddXPAmount()
    return kAlienDefaultAddXp
    end

local originit = Whip.OnInitialized
function Whip:OnInitialized()
self:SetArtificalSalty()
originit(self)
         InitMixin(self, LevelsMixin)
           InitMixin(self, InfestationMixin)
        InitMixin(self, AvocaMixin)
if Server then
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange, true, targetTypes, { self.SlapFilter(self) })
        self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange, true, targetTypes, { self.BombFilter(self) })

end

end
/*
function Whip:OnTeleportEnd()
        local contamination = GetEntitiesWithinRange("Contamination", self:GetOrigin(), kInfestationRadius) 
        if contamination then self:Root() end
end
*/
function Whip:SlapFilter()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanSlap(target, targetPosition) end
    
end
function Whip:BombFilter()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanBomb(target, targetPosition) end
    
end
function Whip:GetCanSlap(target, targetPoint)    
    local range = Whip.kRange
    if target:isa("BreakableDoor") and target.health == 0  or (self:GetOrigin() -targetPoint):GetLength() > range  then
    return false
    end
    
    return true
    
end
function Whip:GetCanBomb(target, targetPoint)    
    local range = Whip.kBombardRange
    if target:isa("BreakableDoor") and target.health == 0  or (self:GetOrigin() -targetPoint):GetLength() > range or
       target:isa("Marine") and target.armor == 0 then
    return false
    end
    
    return true
    
end

     function Whip:SetArtificalSalty()
         self.salty = GetImaginator():GetAlienEnabled() 
    end
     function Whip:SetSalty()
         self.salty = true 
    end
function Whip:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Minigun") then
    
        damageTable.damage = damageTable.damage * 0.9
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end

Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars)

    