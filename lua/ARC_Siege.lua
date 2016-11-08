local origrules = ARC.GetCanFireAtTargetActual
function ARC:GetCanFireAtTargetActual(target, targetPoint) 

local canfire = ( kSideTimer ~= 0 and GetSideDoorOpen() )  or  GetFrontDoorOpen()  
return origrules and canfire

end