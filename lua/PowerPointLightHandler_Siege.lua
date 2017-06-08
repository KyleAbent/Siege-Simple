local function SetLight(renderLight, intensity, color)

    if intensity then
        renderLight:SetIntensity(intensity)
    end
    
    if color then
    
        renderLight:SetColor(color)
        
        if renderLight:GetType() == RenderLight.Type_AmbientVolume then
        
            renderLight:SetDirectionalColor(RenderLight.Direction_Right,    color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Left,     color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Up,       color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Down,     color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Forward,  color)
            renderLight:SetDirectionalColor(RenderLight.Direction_Backward, color)
            
        end
        
    end
    
end

local function RestoreColor(renderLight)

    renderLight:SetColor(renderLight.originalColor)

    if renderLight:GetType() == RenderLight.Type_AmbientVolume then

        renderLight:SetDirectionalColor(RenderLight.Direction_Right,    renderLight.originalRight)
        renderLight:SetDirectionalColor(RenderLight.Direction_Left,     renderLight.originalLeft)
        renderLight:SetDirectionalColor(RenderLight.Direction_Up,       renderLight.originalUp)
        renderLight:SetDirectionalColor(RenderLight.Direction_Down,     renderLight.originalDown)
        renderLight:SetDirectionalColor(RenderLight.Direction_Forward,  renderLight.originalForward)
        renderLight:SetDirectionalColor(RenderLight.Direction_Backward, renderLight.originalBackward)
        
    end

end

function PowerPointLightHandler:DiscoLights()
    local purerandom = math.random(1,2)
    local color = nil
      if purerandom == 1 then
       color = Color(math.random(0,255)/255, math.random(0,255)/255, math.random(0,255)/255, 1)
      end
     if self.timeofdisco == nil or (self.timeofdisco + 4) < Shared.GetTime() then
             for renderLight,_ in pairs(self.lightTable) do
           if purerandom == 2 then color = Color(math.random(0,255)/255, math.random(0,255)/255, math.random(0,255)/255, 1) end
             SetLight(renderLight, math.random(8,25), color)
              end
    self.timeofdisco = Shared.GetTime()
    end
end
function PowerPointLightHandler:RestoreColorDerp()
             for renderLight,_ in pairs(self.lightTable) do
            local color = nil
              color = randomcolor
             RestoreColor(renderLight)
              end

end