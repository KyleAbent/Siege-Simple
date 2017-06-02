Script.Load("lua/Additions/Functions.lua")
function Rifle:GetClipSize()
    local buff  = 75 * GetRoundLengthToSiege()
    return Clamp(buff, kRifleClipSize, 75)
    end