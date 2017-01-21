Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Additions/ConcGrenade.lua")

local networkVars =
{
}

class 'ConcGrenadeThrower' (GrenadeThrower)

ConcGrenadeThrower.kMapName = "concgrenadethrower"

local kModelName = PrecacheAsset("models/marine/grenades/gr_nerve.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_nerve")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function ConcGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function ConcGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function ConcGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function ConcGrenadeThrower:GetGrenadeClassName()
    return "ConcGrenade"
end

Shared.LinkClassToMap("ConcGrenadeThrower", ConcGrenadeThrower.kMapName, networkVars)