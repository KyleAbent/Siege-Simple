Script.Load("lua/Additions/LevelsMixin.lua")

class 'HydraAvoca' (Hydra)
HydraAvoca.kMapName = "hydraavoca"

local networkVars = {}

function HydraAvoca:OnInitialized()
 Hydra.OnInitialized(self)
   InitMixin(self, LevelsMixin)
   self:SetTechId(kTechId.Hydra) --Set Parent???
end


        function HydraAvoca:GetTechId()
         return kTechId.Hydra
    end
   function HydraAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Hydra
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
    function HydraAvoca:GetMaxLevel()
    return kAlienDefaultLvl
    end
    function HydraAvoca:GetAddXPAmount()
    return self:GetMaxLevel() / math.random(8,16) 
    end
    /*
    function HydraAvoca:OnAddXp(amount)
       Hydra.kDamage = Hydra.kDamage * (self.level/100) + Hydra.kDamage
    end
    */
Shared.LinkClassToMap("HydraAvoca", HydraAvoca.kMapName, networkVars) 



local originit = Hydra.OnInitialized
function Hydra:OnInitialized()

originit(self)

if Server then

               self.targetSelector = TargetSelector():Init(
                self,
                Hydra.kRange, 
                true,
                { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) } ) 


end

end

function Hydra:FilterTarget(slap)

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function Hydra:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("BreakableDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end
