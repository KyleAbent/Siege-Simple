
class 'AvocaSpectator' (Spectator)
AvocaSpectator.kMapName = "Spectator"

local networkVars = {}

AvocaSpectator.kModelName = PrecacheAsset("models/system/editor/camera_origin.model")
local kViewModelName = PrecacheAsset("models/alien/fade/fade_view.model")
local kFadeAnimationGraph = PrecacheAsset("models/alien/fade/fade.animation_graph")
function AvocaSpectator:OnInitialized()
Spectator.OnInitialized(self)
 self:SetModel(AvocaSpectator.kModelName, kFadeAnimationGraph)
end


function AvocaSpectator:OnCreate()
 Spectator.OnCreate(self)
 --self:SetPropagate(Propagate_PlayerOwner)
end


function AvocaSpectator:OnGetIsVisible(visibleTable)

    visibleTable.Visible = not self:GetIsFirstPerson()
end

function AvocaSpectator:OnAdjustModelCoords(modelCoords)
    local scale = 2
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scale
    coords.yAxis = coords.yAxis * scale
    coords.zAxis = coords.zAxis * scale
      
    return coords
    
end
Shared.LinkClassToMap("AvocaSpectator", AvocaSpectator.kMapName, networkVars)