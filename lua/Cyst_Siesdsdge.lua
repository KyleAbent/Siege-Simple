local origone = Cyst.GetCystParentRange
function Cyst:GetCystParentRange()
return GetImaginator()GetAlienEnabled() and 999 or origone
end
local origtwo = Cyst.GetCystParentRange
function Cyst:GetCystParentRange()
return GetImaginator()GetAlienEnabled() and 999 or origtwo
end

function Cyst:GetMinRangeAC()
return  kCystRedeployRange * .7      
end

if Server then

local origthree = Cyst.GetIsActuallyConnected
   function Cyst:GetIsActuallyConnected()
     return GetImaginator()GetAlienEnabled() and true or origthree
   end
  local origfour = Cyst.GetCanAutoBuild 
  function Cyst:GetCanAutoBuild()
     return GetImaginator()GetAlienEnabled() and true or origfour
   end
    
end