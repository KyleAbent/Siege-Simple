Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Additions/JediConcGrenade.lua")
class 'JediConcGrenadeThrower' (GrenadeThrower)

JediConcGrenadeThrower.kMapName = "jediconcgrenadethrower"
local kModelName = PrecacheAsset("models/marine/grenades/gr_nerve.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_nerve")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function JediConcGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function JediConcGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function JediConcGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function JediConcGrenadeThrower:GetGrenadeClassName()
    return "JediConcGrenade"
end

Shared.LinkClassToMap("JediConcGrenadeThrower", JediConcGrenadeThrower.kMapName, networkVars)