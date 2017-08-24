SaltMixin = CreateMixin( SaltMixin )
SaltMixin.type = "Salt"

SaltMixin.networkVars =
{
isacreditstructure = "boolean",
    
}

function SaltMixin:__initmixin()
   -- Print("%s initmiin avoca mixin", self:GetClassName())
      self.isacreditstructure = false

   --  Print("%s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)

end
function SaltMixin:SetIsACreditStructure(boolean)
    
      self.isacreditstructure = boolean
     -- Print("SaltMixin SetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end
function SaltMixin:GetCanStick()
     local canstick = not GetSetupConcluded()
     --Print("Canstick = %s", canstick)
     return canstick and self:GetIsACreditStructure() 
end

function SaltMixin:GetIsACreditStructure()
    
      --  Print("SaltMixin GetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
return self.isacreditstructure 
 

end