-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\VoiceOver.lua
--
--11.15 siege simple - It's just easier to replace this right now, than to find a way to add this in with mods pre-or post-hooking.
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

LEFT_MENU = 1
RIGHT_MENU = 2
kMaxRequestsPerSide = 6

kVoiceId = enum ({

    'None', 'VoteEject', 'VoteConcede', 'Ping',

    'RequestWeld', 'MarineRequestMedpack', 'MarineRequestAmmo', 'MarineRequestOrder', 
    'MarineTaunt', 'MarineTauntExclusive', 'MarineCovering', 'MarineFollowMe', 'MarineHostiles', 'MarineLetsMove', 'MarineAcknowledged',
    
    'AlienRequestHarvester', 'AlienRequestHealing', 'AlienRequestMist', 'AlienRequestDrifter',
    'AlienTaunt', 'AlienFollowMe', 'AlienChuckle', 'EmbryoChuckle',


})

local kAlienTauntSounds =
{
    [kTechId.Skulk] = "sound/NS2.fev/alien/voiceovers/chuckle",
    [kTechId.Gorge] = "sound/NS2.fev/alien/gorge/taunt",
    [kTechId.Lerk] = "sound/NS2.fev/alien/lerk/taunt",
    [kTechId.Fade] = "sound/NS2.fev/alien/fade/taunt",
    [kTechId.Onos] = "sound/NS2.fev/alien/onos/taunt",
    [kTechId.Embryo] = "sound/NS2.fev/alien/common/swarm",
    [kTechId.ReadyRoomEmbryo] = "sound/NS2.fev/alien/common/swarm",
}
for _, tauntSound in pairs(kAlienTauntSounds) do
    PrecacheAsset(tauntSound)
end

local function VoteEjectCommander(player)

    if player then
        GetGamerules():CastVoteByPlayer(kTechId.VoteDownCommander1, player)
    end    
    
end

local function VoteConcedeRound(player)

    if player then
        GetGamerules():CastVoteByPlayer(kTechId.VoteConcedeRound, player)
    end  
    
end

local function GetLifeFormSound(player)

    if player and (player:isa("Alien") or player:isa("ReadyRoomEmbryo")) then    
        return kAlienTauntSounds[player:GetTechId()] or ""    
    end
    
    return ""

end
local function BuyMist(player)

    if player then
        player:HookWithShineToBuyMist(player)
    end  
    
end
local function BuyMedPack(player)

    if player then
        player:HookWithShineToBuyMed(player)
    end  
    
end
local function BuyAmmoPack(player)

    if player then
        player:HookWithShineToBuyAmmo(player)
    end  
    
end
local function PingInViewDirection(player)

    if player and (not player.lastTimePinged or player.lastTimePinged + 60 < Shared.GetTime()) then
    
        local startPoint = player:GetEyePos()
        local endPoint = startPoint + player:GetViewCoords().zAxis * 40        
        local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterOne(player))   
        
        -- seems due to changes to team mixin you can be assigned to a team which does not implement SetCommanderPing
        local team = player:GetTeam()
        if team and team.SetCommanderPing then
            player:GetTeam():SetCommanderPing(trace.endPoint)
        end
        
        player.lastTimePinged = Shared.GetTime()
        
    end

end

local function GiveWeldOrder(player)

    if ( player:isa("Marine") or player:isa("Exo") ) and player:GetArmor() < player:GetMaxArmor() then
    
        for _, marine in ipairs(GetEntitiesForTeamWithinRange("Marine", player:GetTeamNumber(), player:GetOrigin(), 8)) do
        
            if player ~= marine and marine:GetWeapon(Welder.kMapName) then
                marine:GiveOrder(kTechId.AutoWeld, player:GetId(), player:GetOrigin(), nil, true, false)
            end
        
        end
    
    end

end

local kSoundData = 
{

    -- always part of the menu
    [kVoiceId.VoteEject] = { Function = VoteEjectCommander },
    [kVoiceId.VoteConcede] = { Function = VoteConcedeRound },

    [kVoiceId.Ping] = { Function = PingInViewDirection, Description = "REQUEST_PING", KeyBind = "PingLocation" },

    -- marine vote menu
    [kVoiceId.RequestWeld] = { Sound = "sound/NS2.fev/marine/voiceovers/weld", Function = GiveWeldOrder, Description = "REQUEST_MARINE_WELD", KeyBind = "RequestWeld", AlertTechId = kTechId.None },
    [kVoiceId.MarineRequestMedpack] =  {  Sound = "sound/NS2.fev/marine/voiceovers/medpack", Function = BuyMedPack, Description = "Purchase Medpack(1)", KeyBind = "RequestHealth"},
    [kVoiceId.MarineRequestAmmo] = {   Sound = "sound/NS2.fev/marine/voiceovers/ammo", Function = BuyAmmoPack, Description = "Purchase Ammopack(1)", KeyBind = "RequestAmmo"},
    [kVoiceId.MarineRequestOrder] = { Sound = "sound/NS2.fev/marine/voiceovers/need_orders", Description = "REQUEST_MARINE_ORDER",  KeyBind = "RequestOrder", AlertTechId = kTechId.MarineAlertNeedOrder },
    
    [kVoiceId.MarineTaunt] = { Sound = "sound/NS2.fev/marine/voiceovers/taunt", Description = "REQUEST_MARINE_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.MarineTauntExclusive] = { Sound = "sound/NS2.fev/marine/voiceovers/taunt_exclusive", Description = "REQUEST_MARINE_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.MarineCovering] = { Sound = "sound/NS2.fev/marine/voiceovers/covering", Description = "REQUEST_MARINE_COVERING", KeyBind = "VoiceOverCovering", AlertTechId = kTechId.None },
    [kVoiceId.MarineFollowMe] = { Sound = "sound/NS2.fev/marine/voiceovers/follow_me", Description = "REQUEST_MARINE_FOLLOWME", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.MarineHostiles] = { Sound = "sound/NS2.fev/marine/voiceovers/hostiles", Description = "REQUEST_MARINE_HOSTILES", KeyBind = "VoiceOverHostiles", AlertTechId = kTechId.None },
    [kVoiceId.MarineLetsMove] = { Sound = "sound/NS2.fev/marine/voiceovers/lets_move", Description = "REQUEST_MARINE_LETSMOVE", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.MarineAcknowledged] = { Sound = "sound/NS2.fev/marine/voiceovers/ack", Description = "REQUEST_MARINE_ACKNOWLEDGED", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },
    
    -- alien vote menu
    [kVoiceId.AlienRequestHarvester] = { Sound = "sound/NS2.fev/alien/voiceovers/follow_me", Description = "REQUEST_ALIEN_HARVESTER", KeyBind = "RequestOrder", AlertTechId = kTechId.AlienAlertNeedHarvester },
    [kVoiceId.AlienRequestMist] = { Function = BuyMist, Description = "Purchase Mist(1)", KeyBind = "RequestHealth", AlertTechId = kTechId.None },
    [kVoiceId.AlienRequestDrifter] = { Sound = "sound/NS2.fev/alien/voiceovers/follow_me", Description = "REQUEST_ALIEN_DRIFTER", KeyBind = "RequestAmmo", AlertTechId = kTechId.AlienAlertNeedDrifter },
    [kVoiceId.AlienRequestHealing] = { Function = BuyMist, Description = "Purchase Mist", KeyBind = "RequestHealth", AlertTechId = kTechId.None },
    [kVoiceId.AlienTaunt] = { Sound = "", Function = GetLifeFormSound, Description = "REQUEST_ALIEN_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.AlienFollowMe] = { Sound = "sound/NS2.fev/alien/voiceovers/follow_me", Description = "REQUEST_ALIEN_FOLLOWME", AlertTechId = kTechId.None },
    [kVoiceId.AlienChuckle] = { Sound = "sound/NS2.fev/alien/voiceovers/chuckle", Description = "REQUEST_ALIEN_CHUCKLE", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },  
    [kVoiceId.EmbryoChuckle] = { Sound = "sound/NS2.fev/alien/structures/death_large", Description = "REQUEST_ALIEN_CHUCKLE", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },     

}

-- Initialize the female variants of the voice overs and precache.
for _, soundData in pairs(kSoundData) do

    if soundData.Sound ~= nil and string.len(soundData.Sound) > 0 then
    
        PrecacheAsset(soundData.Sound)
        
        -- Do not look for female versions of alien sounds.
        if string.find(soundData.Sound, "sound/NS2.fev/alien/", 1) == nil then
        
            soundData.SoundFemale = soundData.Sound .. "_female"
            PrecacheAsset(soundData.SoundFemale)
            
        end
        
    end
    
end

function GetVoiceSoundData(voiceId)
    return kSoundData[voiceId]
end

local kMarineMenu =
{
    [LEFT_MENU] = { kVoiceId.RequestWeld, kVoiceId.MarineRequestMedpack, kVoiceId.MarineRequestAmmo, kVoiceId.MarineRequestOrder, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.MarineTaunt, kVoiceId.MarineCovering, kVoiceId.MarineFollowMe, kVoiceId.MarineHostiles, kVoiceId.MarineAcknowledged}
}

local kExoMenu = 
 {
    [LEFT_MENU] = { kVoiceId.RequestWeld, kVoiceId.MarineRequestOrder, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.MarineTaunt, kVoiceId.MarineCovering, kVoiceId.MarineFollowMe, kVoiceId.MarineHostiles, kVoiceId.MarineAcknowledged }
}
    
local kAlienMenu =
{
    [LEFT_MENU] = { kVoiceId.AlienRequestHealing, kVoiceId.AlienRequestDrifter, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.AlienTaunt, kVoiceId.AlienChuckle }    
}

local kEmbryoMenu = 
{
    [LEFT_MENU] = { kVoiceId.AlienRequestMist },
    [RIGHT_MENU] = { kVoiceId.AlienTaunt, kVoiceId.EmbryoChuckle }
}

local kRequestMenus = 
{
    ["Spectator"] = { },
    ["AlienSpectator"] = { },
    ["MarineSpectator"] = { },
    
    ["Marine"] = kMarineMenu,
    ["JetpackMarine"] = kMarineMenu,
    ["Exo"] = kExoMenu,
    
    ["Skulk"] = kAlienMenu,
    ["Gorge"] =
    {
        [LEFT_MENU] = { kVoiceId.AlienRequestHealing, kVoiceId.AlienRequestDrifter, kVoiceId.AlienRequestHarvester, kVoiceId.Ping },
        [RIGHT_MENU] = { kVoiceId.AlienTaunt, kVoiceId.AlienChuckle }    
    },
    
    ["Lerk"] = kAlienMenu,
    ["Fade"] = kAlienMenu,
    ["Onos"] = kAlienMenu,
    ["Embryo"] = kEmbryoMenu,
    ["ReadyRoomPlayer"] = kMarineMenu,
    ["ReadyRoomExo"] = kExoMenu,
    ["ReadyRoomEmbryo"] = kEmbryoMenu,
}

function GetRequestMenu(side, className)

    local menu = kRequestMenus[className]
    if menu and menu[side] then
        return menu[side]
    end
    
    return { }
    
end

if Client then

    function GetVoiceDescriptionText(voiceId)
    
        local descriptionText = ""
        
        local soundData = kSoundData[voiceId]
        if soundData then
            descriptionText = Locale.ResolveString(soundData.Description)
        end
        
        return descriptionText
        
    end
    
    function GetVoiceKeyBind(voiceId)
    
        local soundData = kSoundData[voiceId]
        if soundData then
            return soundData.KeyBind
        end    
        
    end
    
end


local kAutoMarineVoiceOvers = {}
local kAutoAlienVoiceOvers = {}
