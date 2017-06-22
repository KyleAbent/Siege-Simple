Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/SandMixin.lua")
local kHoloMarineMaterialname = PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.material")

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(SandMixin, networkVars)



    local originit = InfantryPortal.OnInitialized
    function InfantryPortal:OnInitialized()
        originit(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, SandMixin)
    end
        function InfantryPortal:GetMaxLevel()
    return 15
    end
    function InfantryPortal:GetAddXPAmount()
    return 0.30
    end
function InfantryPortal:GetMinRangeAC()
return IPAutoCCMR  
end
function InfantryPortal:CheckSpaceAboveForSpawn()

    local startPoint = self:GetOrigin() 
    local endPoint = startPoint + Vector(0.35, 0.95, 0.35)
    
    return GetWallBetween(startPoint, endPoint, self)
    
end

if Server then

local origfree = InfantryPortal.FillQueueIfFree
function InfantryPortal:FillQueueIfFree()

  if GetSandCastle():GetSDBoolean() then return end
  
  origfree(self)

end

end
Shared.LinkClassToMap("InfantryPortal", InfantryPortal.kMapName, networkVars)