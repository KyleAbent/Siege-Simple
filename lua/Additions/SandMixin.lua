SandMixin = CreateMixin( SandMixin )
SandMixin.type = "Sand"

SandMixin.networkVars =
{
isacreditstructure = "boolean",
    
}

function SandMixin:__initmixin()
   -- Print("%s initmiin avoca mixin", self:GetClassName())
      self.isacreditstructure = false

   --  Print("%s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)

end
function SandMixin:SetIsACreditStructure(boolean)
    
      self.isacreditstructure = boolean
     -- Print("SandMixin SetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end
function SandMixin:GetCanStick()
     local canstick = not GetSetupConcluded()
     --Print("Canstick = %s", canstick)
     return canstick and self:GetIsACreditStructure() 
end

function SandMixin:GetIsACreditStructure()
    
      --  Print("SandMixin GetIsACreditStructure %s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
return self.isacreditstructure 
 

end