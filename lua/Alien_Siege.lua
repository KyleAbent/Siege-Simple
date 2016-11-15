local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    if Server then
        local t4 = self.GetTierFourTechId and self:GetTierFourTechId() or nil
        self:AddTimedCallback(function() UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), t4) end, .8) 
    end
    
    
end

if Server then

function Alien:CreditBuy(Class)

        local upgradetable = {}
        local upgrades = Player.lastUpgradeList
        if upgrades and #upgrades > 0 then
            table.insert(upgradetable, upgrades)
        end
        local class = nil
        
        if Class == Gorge then
        class = kTechId.Gorge
        elseif Class == Lerk then
        class = kTechId.Lerk
        elseif Class == Fade then
        class = kTechId.Fade
        elseif Class == Onos then
        class = kTechId.Onos
        end
        
        table.insert(upgradetable, class)
        self:ProcessBuyAction(upgradetable, true)
        
end

function Alien:RefreshTechsManually()
local t4 = self.GetTierFourTechId and self:GetTierFourTechId() or nil
UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), t4 )
end


end



