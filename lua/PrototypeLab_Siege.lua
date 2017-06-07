--derp
local oldfunc = PrototypeLab.GetItemList
function PrototypeLab:GetItemList(forPlayer)
        local  otherbuttons = { kTechId.Jetpack, kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit,  kTechId.DualWelderExosuit, kTechId.DualFlamerExosuit, kTechId.JumpPack,
                                kTechId.HeavyArmor, kTechId.LightArmor, kTechId.WallWalk, kTechId.RegenArmor}
        
          /*
             6 = jumppack
             7 = ha
             8 = la
             9 = moonboots
             10 = regen armor
           */
           
           if forPlayer:GetHasJumpPack()  then
                otherbuttons[1] = kTechId.None 
                otherbuttons[2] = kTechId.None 
                otherbuttons[3] = kTechId.None 
                otherbuttons[4] = kTechId.None 
                otherbuttons[5] = kTechId.None 
                otherbuttons[6] = kTechId.None 
                otherbuttons[9] = kTechId.None 
           end
           
            if forPlayer:GetHasWallWalk() then
                otherbuttons[1] = kTechId.None 
                otherbuttons[2] = kTechId.None 
                otherbuttons[3] = kTechId.None 
                otherbuttons[4] = kTechId.None 
                otherbuttons[5] = kTechId.None 
                otherbuttons[6] = kTechId.None 
                otherbuttons[9] = kTechId.None 
            end
            
            if forPlayer:isa("JetpackMarine") then
                otherbuttons[6] = kTechId.None 
                otherbuttons[9] = kTechId.None 
            end

               if forPlayer:GetHasHeavyArmor() then 
                otherbuttons[7] = kTechId.None 
                otherbuttons[8] = kTechId.None 
                end
                
               if forPlayer:GetHasLightArmor() then 
                otherbuttons[8] = kTechId.None 
                otherbuttons[7] = kTechId.None 
                end
                
               
           if forPlayer:GetHasNanoArmor() then otherbuttons[12] = kTechId.None end
               
           return otherbuttons
end

local origbuttons = PrototypeLab.GetTechButtons
function PrototypeLab:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.DropExosuit
 
 return table

end