Script.Load("lua/Siege/Shared.lua")






function LoadPathing(mapName, groupName, values)


    if mapName == "nav_point" then
        Pathing.AddFillPoint(values.origin) 
    end


end
Event.Hook("MapLoadEntity", LoadPathing)