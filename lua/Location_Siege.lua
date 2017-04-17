-- Kyle 'Avoca' Abent
PrecacheAsset("materials/power/powered_decal.surface_shader")
local kAirLockMaterial = PrecacheAsset("materials/power/powered_decal.material")


local networkVars =
{
airlock = "boolean" 
}
local originit = Location.OnInitialized
function Location:OnInitialized()
originit(self)
self.airlock = false
end
local function IsPowerUp(self)
 local powerpoint = GetPowerPointForLocation(self.name)

   local boolean = false
 if powerpoint and not powerpoint:GetIsDisabled() then boolean = true end
  -- Print("IsPowerUp in %s is %s", self.name, boolean)
 return boolean 
end


function Location:GetIsPowerUp()
return IsPowerUp(self)
end
function Location:GetRandomMarine()

local lottery = {}
     for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 1, self:GetOrigin(), 24)) do
     
         local location = GetLocationForPoint(unit:GetOrigin())
         if location and location.name == self.name then
              table.insert(lottery, unit)
         end
     end
     
     if table.count(lottery) ~= 0 then
        local entity = table.random(lottery)
        return entity:GetOrigin()
     end
     
     return nil
end
function Location:GetIsAirLock()
     local boolean = IsPowerUp(self) and ( self.airlock or not GetSetupConcluded() ) 
    -- Print("%s airlock is %s", self.name, boolean)
     return boolean
end

if Server then 


function Location:GetRandomMarine()
--Because when round starts, room is empty. Have marine in room first to tell it to be eligable.
local lottery = {}
     for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 1, self:GetOrigin(), 24)) do
     
         local location = GetLocationForPoint(unit:GetOrigin())
         if location and location.name == self.name then
              table.insert(lottery, unit)
         end
     end
     
     if table.count(lottery) ~= 0 then
        local entity = table.random(lottery)
        return entity:GetOrigin()
     end
     
     return nil
end
local function SetAllSameNamesAsAirLock(self)
    local locations = GetAllLocationsWithSameName(self:GetOrigin())
    
    for i = 1, #locations do
    local location = locations[i]   
     if not location.airlock then location.airlock = true end
  end
  
  
end
local function RealWorld(self, entity)
               local powerPoint = GetPowerPointForLocation(self.name)
            if powerPoint ~= nil then
                    if entity:isa("Marine") and not entity:isa("Commander") then
                         if not powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then 
                         powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)  
                         end
                    end 
            end 
end
local function IfImagination(self, entity)
         local imagination = GetImaginator()
           if imagination:GetMarineEnabled() then
               local powerPoint = GetPowerPointForLocation(self.name)
            if powerPoint ~= nil then
                    if entity:isa("Marine") and not entity:isa("Commander") then
                         if not powerPoint:GetIsDisabled() and not powerPoint:GetIsSocketed() then 
                         powerPoint:SetInternalPowerState(PowerPoint.kPowerState.socketed)  
                          elseif  powerPoint:GetIsBuilt() and not powerPoint:GetIsDisabled() then
                          SetAllSameNamesAsAirLock(self)
                         end
                    end 
            end 
          end
end
local locorig = Location.OnTriggerEntered
 function Location:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
         locorig(self, entity, triggerEnt)
         
         
         if string.find(self.name, "siege") or string.find(self.name, "Siege") then
         ExploitCheck(entity)
         end
         
         if GetGameStarted() then 
             IfImagination(self, entity)
         else
             RealWorld(self, entity)
         end
  
                
end

function Location:BuffFadesInSiegeRoom()

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
          if entity:isa("Fade") then
          entity:AddEnergy(.1)
          --  Print("Buffing fade in siege room")
          end
    end

end

end