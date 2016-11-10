if Server then


local origrules = ARC.AcquireTarget
function ARC:AcquireTarget() 

local canfire = ( kSideTimer ~= 0 and GetSideDoorOpen() )  or  GetFrontDoorOpen() 
--Print("Arc can fire is %s", canfire)
if not canfire then return end
return origrules(self)

end



end