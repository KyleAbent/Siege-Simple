Script.Load("lua/Additions/LevelsMixin.lua")


ArmsLab.kBuyMenuFlash = "ui/marine_buy.swf"
ArmsLab.kBuyMenuTexture = "ui/marine_buymenu.dds"
ArmsLab.kBuyMenuUpgradesTexture = "ui/marine_buymenu_upgrades.dds"

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
    
local originit = ArmsLab.OnInitialized
    function ArmsLab:OnInitialized()
         originit(self)
        InitMixin(self, AvocaMixin)
        InitMixin(self, LevelsMixin)
    end
        function ArmsLab:GetTechId()
         return kTechId.ArmsLab
    end
        function ArmsLab:GetMaxLevel()
    return kDefaultLvl
    end
    function ArmsLab:GetAddXPAmount()
    return kDefaultAddXp
    end
function ArmsLab:GetMinRangeAC()
return ArmsLabAutoCCMR 
end

function ArmsLab:GetCanBeUsedConstructed(byPlayer)
    return not byPlayer:isa("Exo")
end  

function ArmsLab:GetItemList(forPlayer)
    
    local itemList = {
        kTechId.Resupply,
        kTechId.HeavyArmor,
        kTechId.RegenArmor,
        kTechId.FireBullets,
    }
    
    if forPlayer:GetHasResupply() then itemList[1] = kTechId.None end
    if forPlayer:GetHasHeavyArmor() then itemList[2] = kTechId.None end
    if forPlayer:GetHasNanoArmor() then itemList[3] = kTechId.None end
    if forPlayer:GetHasFireBullets() then itemList[4] = kTechId.None end
    return itemList
    
end


if Client then

function ArmsLab:GetWarmupCompleted()
    return not self.timeConstructionCompleted or (self.timeConstructionCompleted + 0.7 < Shared.GetTime())
end

function ArmsLab:OnUse(player, elapsedTime, useSuccessTable)
    
    if GetIsUnitActive(self) and not Shared.GetIsRunningPrediction() and not player.buyMenu and self:GetWarmupCompleted() then
    
        if Client.GetLocalPlayer() == player then
        
            Client.SetCursor("ui/Cursor_MarineCommanderDefault.dds", 0, 0)
            
            -- Play looping "active" sound while logged in
            -- Shared.PlayPrivateSound(player, Armory.kResupplySound, player, 1.0, Vector(0, 0, 0))
            
            MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
            
            -- tell the player to show the lua menu
            player:BuyMenu(self)
            
        end
        
    end
    
end

end


Shared.LinkClassToMap("ArmsLab", ArmsLab.kMapName, networkVars)