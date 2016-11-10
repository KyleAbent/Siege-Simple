
local origrules = ARC.GetCanFireAtTargetActual
function ARC:GetCanFireAtTargetActual(target, targetPoint) 

local canfire = ( kSideTimer ~= 0 and GetSideDoorOpen() )  or  GetFrontDoorOpen() 
 Print("Arc canfire is %s", canfire)
if origrules == true then return canfire end

return false 

end
