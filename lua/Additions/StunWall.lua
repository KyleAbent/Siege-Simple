local kLifeSpan = 4

class 'StunWall' (BoneWall)
StunWall.kMapName = "stunwall"

function StunWall:OnInitialized()
BoneWall.OnInitialized(self)

if Server then 
 self:AdjustMaxHealth(self:GetMaxHealth() / 2)
end

end

function StunWall:GetLifeSpan()
    return kLifeSpan
end
function StunWall:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = .5
	local y = 1
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * y
        coords.zAxis = coords.zAxis * scale
    return coords
end

function StunWall:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.BoneWall
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

Shared.LinkClassToMap("StunWall", StunWall.kMapName, networkVars)