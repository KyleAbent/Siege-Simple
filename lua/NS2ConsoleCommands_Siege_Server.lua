local function OnCommandRebirth(client)

    local player = client:GetControllingPlayer()
    
    if Shared.GetCheatsEnabled() and player and player:isa("Alien") then
        player:TriggerRebirth()
    end
    
end

Event.Hook("Console_rebirth", OnCommandRebirth)