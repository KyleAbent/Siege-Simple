local function GetTeleportDestinationCoords(self)

    local destinationEntities = {}
    local randomize = self:isa("Teleport_Trigger_Siege_Randomizer")
  
  if not randomize then
    for _, entity in ientitylist(Shared.GetEntitiesWithClassname("TeleportDestination")) do
    
        if  entity.teleportDestinationId == self.teleportDestinationId  then     
            table.insert(destinationEntities, entity)  
        end
    
    end
    else
        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("TeleportDestination_Siege_Randomized")) do
    
            table.insert(destinationEntities, entity)  
         end

    end
    
    if #destinationEntities > 0 then
        return destinationEntities[math.random(1, #destinationEntities)]:GetCoords()
    end

end
function TeleportTrigger:OnTriggerEntered(enterEnt, triggerEnt)


    local className = enterEnt:GetClassName()

        local destinationCoords = GetTeleportDestinationCoords(self)

        if destinationCoords then
        
            local oldCoords = enterEnt:GetCoords()
        
            enterEnt:SetCoords(destinationCoords)
            
            if enterEnt:isa("Player") then
            
                local newAngles = Angles(0, 0, 0)            
                newAngles.yaw = GetYawFromVector(destinationCoords.zAxis)
                enterEnt:SetOffsetAngles(newAngles)
            
            end
            
            GetEffectManager():TriggerEffects("teleport_trigger", { effecthostcoords = oldCoords }, self)
            GetEffectManager():TriggerEffects("teleport_trigger", { effecthostcoords = destinationCoords }, self)
            
            enterEnt.timeOfLastPhase = Shared.GetTime()
        
        end
    
end

class 'Teleport_Trigger_Siege_Randomizer' (TeleportTrigger)
Teleport_Trigger_Siege_Randomizer.kMapName = "teleport_trigger_siege_randomizer"

Shared.LinkClassToMap("Teleport_Trigger_Siege_Randomizer", Teleport_Trigger_Siege_Randomizer.kMapName, networkVars)