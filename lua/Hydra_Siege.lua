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
