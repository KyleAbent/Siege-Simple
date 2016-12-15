
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
end

Shared.LinkClassToMap("AvocaSpectator", AvocaSpectator.kMapName, networkVars)