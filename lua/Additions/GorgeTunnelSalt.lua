   function FindPlayerTunnels(owner)
       local nearhive = false
       local exit = nil
       local count = 0
    for _, tunnelent in ipairs( GetEntitiesForTeam("TunnelEntrance", 2)) do
        if tunnelent:GetOwner() == owner then
           exit = tunnelent
           if exit then nearhive = GetIsOriginInHiveRoom(exit:GetOrigin()) end
           count = count + 1
        end
    end
    return exit, nearhive, count
end
local function MoveToUnstuck(who)
   for i = 1, 8 do
        local extents = LookupTechData(kTechId.GorgeTunnel, kTechDataMaxExtents, nil)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, who:GetModelOrigin(), .5, 7, EntityFilterAll())
        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
            break
        end
    end
        if spawnPoint then
        who:SetOrigin(spawnPoint)
        end
end
function GorgeWantsEasyEntrance(who, exit, nearhive)
             local hiveOrigin = who:GetTeam():GetHive():GetOrigin()
             local origin = GetNearest(hiveOrigin, "PowerPoint", 1)
               if origin then
                    origin = FindFreeSpace(origin:GetOrigin(), 4, 24)
                    local tunnelent = CreateEntity(TunnelEntrance.kMapName, origin, 2)   
                    tunnelent:SetOwner(who)
                    tunnelent:SetConstructionComplete()
                    MoveToUnstuck(tunnelent)
                    who:GetTeam():AddGorgeStructure(who, tunnelent) -- dropstructur gui accuracy
                    if exit then
                    exit.isexit = true
                    end
                    
                 return tunnelent
               end
end
