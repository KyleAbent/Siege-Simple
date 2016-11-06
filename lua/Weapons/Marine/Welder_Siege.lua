-- buffed speed on doors
local originit = Welder.GetRepairRate
function Welder:GetRepairRate(repairedEntity)

    local repairRate = kPlayerWeldRate
    if repairedEntity:isa("BreakableDoor") then
        repairRate = kStructureWeldRate * 1.3
    end
    
    return repairRate
    
end