class 'CystAvoca' (Cyst)
CystAvoca.kMapName = "cystavoca"
-- for admin use to help when map cyst chains are broken etc

local networkVars = {}

function CystAvoca:GetCystParentRange()
return 999
end
function CystAvoca:GetCystParentRange()
return 999
end

function CystAvoca:GetMaxSpeed()
    return 3 * self:GetHealthScalar()
end
if Server then


   function CystAvoca:GetIsActuallyConnected()
   return true
   end
   
   

    
    
end
     


Shared.LinkClassToMap("CystAvoca", CystAvoca.kMapName, networkVars)