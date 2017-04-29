--derp
local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit,  kTechId.DualWelderExosuit, kTechId.DualFlamerExosuit, kTechId.JumpPack }
        
              if (forPlayer.GetHasJumpPack and forPlayer:GetHasJumpPack()) or forPlayer:isa("JetpackMarine")  or forPlayer:isa("Exo")  then
              otherbuttons[6] = kTechId.None
           end
           return otherbuttons
end

local origbuttons = PrototypeLab.GetTechButtons
function PrototypeLab:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.DropExosuit
 
 return table

end