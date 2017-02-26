class 'CystSiege' (Cyst)
CystSiege.kMapName = "cystsiege"
-- for admin use to help when map cyst chains are broken etc

local networkVars = {}

function CystSiege:GetCystParentRange()
return 999
end
function CystSiege:GetCystParentRange()
return 999
end

function CystSiege:GetMaxSpeed()
    return 3 * self:GetHealthScalar()
end
if Server then


   function CystSiege:GetIsActuallyConnected()
   return true
   end
   
   

    
    
end
     


Shared.LinkClassToMap("CystSiege", CystSiege.kMapName, networkVars)