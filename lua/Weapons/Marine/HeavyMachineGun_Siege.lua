function HeavyMachineGun:GetCatalystSpeedBase()
local base = 1
    
	if self.reloading then 
        base = 1.7
	end
	
	return base
end

    