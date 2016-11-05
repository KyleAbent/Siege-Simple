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


end


