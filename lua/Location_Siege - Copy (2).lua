if Server then 
local locorig = Location.OnTriggerEntered
 function Location:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
         locorig(self, entity, triggerEnt)
         
         
         if string.find(self.name, "siege") or string.find(self.name, "Siege") then
         ExploitCheck(entity)
         end
         if GetGameStarted() then return end
                 local powerPoint = GetPowerPointForLocation(self.name)
            if powerPoint ~= nil then
                    if entity:isa("Marine") and not entity:isa("Commander") then
                         if not powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then 
                         powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)  
                         end
                    end 
            end 
                
end

function Location:BuffFadesInSiegeRoom()

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
          if entity:isa("Fade") then
          entity:AddEnergy(.1)
          --  Print("Buffing fade in siege room")
          end
    end

end

end