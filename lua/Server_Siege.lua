function OnMapLoadEntity(mapName, groupName, values)

    local priority = GetMapEntityLoadPriority(mapName)
    if Server.mapPostLoadEntities[priority] == nil then
        Server.mapPostLoadEntities[priority] = { }
    end
    
    if mapName == "tech_point" or mapName == "nav_point" then
        Pathing.AddFillPoint(values.origin) 
    end

    table.insert(Server.mapPostLoadEntities[priority], { MapName = mapName, GroupName = groupName, Values = values })

end