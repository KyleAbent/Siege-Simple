AvocaMixin = CreateMixin( AvocaMixin )
AvocaMixin.type = "Avoca"

AvocaMixin.networkVars =
{
isacreditstructure = "boolean",
    
}

function AvocaMixin:__initmixin()
   -- Print("%s initmiin avoca mixin", self:GetClassName())
self.isacreditstructure = false
   --  Print("%s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end
function AvocaMixin:SetIsACreditStructure(boolean)
    
self.isacreditstructure = boolean
      --Print("AvocaMixin SetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end
function AvocaMixin:GetCanStick()
     local canstick = not GetSetupConcluded()
     --Print("Canstick = %s", canstick)
     return canstick and self:GetIsACreditStructure() 
end

function AvocaMixin:GetIsACreditStructure()
    
       -- Print("AvocaMixin GetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
return self.isacreditstructure 
 

end