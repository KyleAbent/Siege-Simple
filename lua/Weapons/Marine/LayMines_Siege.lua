local kPlacementDistance = 2
function LayMines:GetPositionForStructure(player)

    local isPositionValid = false
    local foundPositionInRange = false
    local structPosition = nil
    
    local origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
    
    -- Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
    
    local displayOrigin = trace.endPoint
    
    -- If we hit nothing, trace down to place on ground
    if trace.fraction == 1 then
    
        origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
        trace = Shared.TraceRay(origin, origin - Vector(0, kPlacementDistance, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
        
    end

    
    -- If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
        
        foundPositionInRange = true
    
        if trace.entity == nil then
            isPositionValid = true
        elseif HasMixin(trace.entity, "Construct") then
            isPositionValid = true
        end
        
        displayOrigin = trace.endPoint
        
        -- Can not be built on infestation
        if GetIsPointOnInfestation(displayOrigin) then
            isPositionValid = false
        end
    
        -- Don't allow dropped structures to go too close to techpoints and resource nozzles
        if GetPointBlocksAttachEntities(displayOrigin) then
            isPositionValid = false
        end
    
        if trace.surface == "nocling" then       
            isPositionValid = false
        end
        
        -- Don't allow placing above or below us and don't draw either
        local structureFacing = player:GetViewAngles():GetCoords().zAxis
    
        if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
            structureFacing = trace.normal:GetPerpendicular()
        end
    
        -- Coords.GetLookIn will prioritize the direction when constructing the coords,
        -- so make sure the facing direction is perpendicular to the normal so we get
        -- the correct y-axis.
        local perp = Math.CrossProduct(trace.normal, structureFacing)
        structureFacing = Math.CrossProduct(perp, trace.normal)
    
        structPosition = Coords.GetLookIn(displayOrigin, structureFacing, trace.normal)
        
    end
    
    return foundPositionInRange, structPosition, isPositionValid
    
end