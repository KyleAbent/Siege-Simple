local origdelay = Shotgun.GetPrimaryMinFireDelay

function Shotgun:GetPrimaryMinFireDelay()
    local delay = origdelay(self)
    local parent = self:GetParent()
    
    if parent then
         if GetHasTech(parent, kTechId.Weapons3) then
           delay = delay - 0.24 * delay
         elseif GetHasTech(parent, kTechId.Weapons2) then
           delay = delay - 0.16 * delay
         elseif GetHasTech(parent, kTechId.Weapons1) then
           delay = delay - 0.08 * delay
         end
    
    end
    --Print("Shotgun primary fire delay is %s", delay)
    return delay    
end