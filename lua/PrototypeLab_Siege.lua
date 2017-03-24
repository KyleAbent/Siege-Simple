--derp
local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        return { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit,  kTechId.DualWelderExosuit, kTechId.DualFlamerExosuit }
    
end

local origbuttons = PrototypeLab.GetTechButtons
function PrototypeLab:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.DropExosuit
 
 return table

end