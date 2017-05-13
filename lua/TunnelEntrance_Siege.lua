function TunnelEntrance:GetInfestationGrowthRate()
    return ConditionalValue(not GetIsInSiege(self), 0.25, 0.09)
end

function TunnelEntrance:GetInfestationRadius()
    return ConditionalValue(not GetIsInSiege(self), 7, 3.7) 
end



local origbuttons = TunnelEntrance.GetTechButtons
function TunnelEntrance:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[1] = kTechId.TunnelTeleport
 
 return table

end

function TunnelEntrance:PerformActivation(techId, position, normal, commander)

local success  = false
   if  techId == kTechId.TunnelTeleport then
    success = self:TriggerCommTeleport(position, commander)
end

return success, true

end

function TunnelEntrance:TriggerCommTeleport(position, commander)
local cyst = GetEntitiesForTeamWithinRange("Cyst", 2, position, 7)
local boolean = false
  if #cyst >= 1 then boolean = true end 
  
                if GetIsPointOnInfestation(position) and boolean then
                    self:TriggerTeleport(5, self:GetId(), position, 2)
                    return true
                else
                    local message = BuildCommanderErrorMessage("Cyst && Infestation Required", position)
                    Server.SendNetworkMessage(commander, "CommanderError", message, true)  
                   return false
                end
end
