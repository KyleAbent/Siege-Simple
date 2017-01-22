Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/AvocaMixin.lua")

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(AvocaMixin, networkVars)
    
local originit = PrototypeLab.OnInitialized
    function PrototypeLab:OnInitialized()
             originit(self)
         InitMixin(self, LevelsMixin)
        InitMixin(self, AvocaMixin)
    end
        function PrototypeLab:GetTechId()
         return kTechId.PrototypeLab
    end
        function PrototypeLab:GetMaxLevel()
    return kDefaultLvl
    end
    function PrototypeLab:GetAddXPAmount()
    return kDefaultAddXp
    end

local origbuttons = PrototypeLab.GetTechButtons
function PrototypeLab:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[2] = kTechId.DropExosuit
 
 return table

end


Shared.LinkClassToMap("PrototypeLab", PrototypeLab.kMapName, networkVars)