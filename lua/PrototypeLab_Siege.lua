--derp
local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit, 
                                kTechId.DualWelderExosuit, kTechId.DualFlamerExosuit, kTechId.None,
                                kTechId.None, kTechId.None, kTechId.None, kTechId.None}
        
               
           return otherbuttons
end

local origbuttons = PrototypeLab.GetTechButtons
function PrototypeLab:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.DropExosuit
 
 return table

end

function PrototypeLab:GetMinRangeAC()
return ProtoAutoCCMR      
end