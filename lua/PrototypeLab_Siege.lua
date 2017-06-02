--derp
local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit,  kTechId.DualWelderExosuit, kTechId.DualFlamerExosuit, kTechId.JumpPack,
                                kTechId.HeavyArmor,  kTechId.MoonBoots, kTechId.LightArmor, }
        
              if forPlayer.GetHasJumpPack and forPlayer:GetHasJumpPack() or forPlayer:isa("JetpackMarine")  or forPlayer:isa("Exo")  then
              otherbuttons[6] = kTechId.None
           end
               if forPlayer:GetHasHeavyArmor() then otherbuttons[7] = kTechId.None end
               if forPlayer:GetHasNanoArmor() then otherbuttons[9] = kTechId.None end
               if forPlayer:GetHasMoonBoots() or forPlayer:isa("JetpackMarine") then otherbuttons[10] = kTechId.None end
               if forPlayer:GetHasLightArmor() then otherbuttons[11] = kTechId.None end
               
           return otherbuttons
end

local origbuttons = PrototypeLab.GetTechButtons
function PrototypeLab:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.DropExosuit
 
 return table

end