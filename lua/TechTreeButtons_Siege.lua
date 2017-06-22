local kTechIdToMaterialOffset = {}
kTechIdToMaterialOffset[kTechId.MacSpawnOn] = 1

function GetMaterialXYOffsetderp(techId)
  --Print("GetMaterialXYOffset")
    local index = nil
    
    local columns = 12
    index = kTechIdToMaterialOffset[techId]
    
    if not index then
        DebugPrint("Warning: %s did not define kTechIdToMaterialOffset ", EnumToString(kTechId, techId) )
    else
    
        local x = index % columns
        local y = math.floor(index / columns)
      
        
    end
    
    local x,y = GetMaterialXYOffset(techId)
    
    if x == nil and y == nil then
    
        local x = 2 % 12
        local y = math.floor(2 / 12)
        return x, y
     else 
      return x, y   
    end

    
end