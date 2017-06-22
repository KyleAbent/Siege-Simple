/*
function HeavyMachineGun:GetCatalystSpeedBase()
local base = 1
 --   local scal = GetRoundLengthToSiege()
	if self.reloading then 
        base = Clamp(1.4 * GetRoundLengthToSiege(), 1, 1.4)
	end
	--Print("Hmg reload speed buff: %s, scal is  %s", base, scal)
	return base
end

 */