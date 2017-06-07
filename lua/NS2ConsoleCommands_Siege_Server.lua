local function OnCommandRebirth(client)

    local player = client:GetControllingPlayer()
    
    if Shared.GetCheatsEnabled() and player and player:isa("Alien") then
        player:TriggerRebirth()
    end
    
end

Event.Hook("Console_rebirth", OnCommandRebirth)

local function OnCommandPrimal(client)

    local player = client:GetControllingPlayer()
    
    if Shared.GetCheatsEnabled() and player and player:isa("Alien") then
        player:PrimalScream(20)
    end
    
end

Event.Hook("Console_primal", OnCommandPrimal)