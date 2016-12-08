SentryBattery.kMarineCircleDecalName = PrecacheAsset("models/misc/circle/circle.material")

function SentryBattery:OnAdjustModelCoords(modelCoords)
    local scale = 1.15
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scale
    coords.yAxis = coords.yAxis * scale
    coords.zAxis = coords.zAxis * scale
      
    return coords
    
end

function SentryBattery:GetTechButtons(techId)

    local techButtons = {  kTechId.BackupLight, kTechId.None, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    return techButtons
    
end

local orig = SentryBattery.OnInitialized
function SentryBattery:OnInitialized()
orig(self)
if Client then self:AddPowerVisual() end
end

function SentryBattery:PreOnKill(attacker, doer, point, direction)
       for _, backuplight in ipairs(GetEntitiesWithinRange("BackupLight", self:GetOrigin(), 8)) do
                backuplight:Kill()
    end
    
end



if Client then
    function SentryBattery:AddPowerVisual()
          local radius = 4 --kBatteryPowerRange
            self.ghostGuides = Client.CreateRenderDecal()
            self.ghostGuides.material = Client.CreateRenderMaterial()
          local materialName = SentryBattery.kMarineCircleDecalName
          self.ghostGuides:SetMaterial(materialName)
         local coords = Coords.GetTranslation(self:GetOrigin())
         self.ghostGuides:SetCoords( coords )
         self.ghostGuides:SetExtents(Vector(1,1,1)*radius)
       --  self.ghostGuides:SetIsVisible(false)
    end
    
      --  function SentryBattery:OnUpdate()
     --       if self.ghostGuides then
     --   local flashLightVisible = self:GetIsBuilt()
     --   self.ghostGuides:SetIsVisible(flashLightVisible)
     --   end
     --   end
    
end
    function SentryBattery:OnDestroy()
    
    if self.ghostGuides then
             Client.DestroyRenderMaterial(self.ghostGuides.material)
            Client.DestroyRenderDecal(self.ghostGuides)
    end
    end