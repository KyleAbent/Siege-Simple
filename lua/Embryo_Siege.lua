local kUpdateGestationTime = 0.1
function Embryo:OnAdjustModelCoords(coords)

    coords.origin = coords.origin - Embryo.kSkinOffset
    
    	local scale = Clamp(self.evolvePercentage / 100, .05, 1)
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
    return coords
    
end

