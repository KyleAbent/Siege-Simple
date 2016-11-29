--Kyle 'Avoca' Abent 
Script.Load("lua/Spur.lua")




class 'StructureBeacon' (AlienBeacon)

StructureBeacon.kModelName =  PrecacheAsset("models/alien/spur/spur.model")
local kAnimationGraph = PrecacheAsset("models/alien/spur/spur.animation_graph")

StructureBeacon.kMapName = "structurebeacon"

function StructureBeacon:OnInitialized()
AlienBeacon.OnInitialized(self)
    self:SetModel(StructureBeacon.kModelName, kAnimationGraph)
end
local kLifeSpan = 8

local networkVars = { }

local function TimeUp(self)

    self:Kill()
    return false

end
local function GetIsACreditStructure(who)
local boolean = HasMixin(who, "Avoca") and who:GetIsACreditStructure()  or false
--Print("isacredit structure is %s", boolean)
return boolean

end
function StructureBeacon:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Spur
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
local function GetIsStructureSiegeWall(self, structure)
 if structure:isa("Whip") then return false end
 local hives = GetEntitiesWithinRange("Hive", structure:GetOrigin(), 17)

 if #hives >=1 then return true end
return false
 
end
if Server then

    function StructureBeacon:OnConstructionComplete()
        if GetIsInSiege(self) then kLifeSpan = 4 end
        self:AddTimedCallback(TimeUp, kLifeSpan )  
        self:Magnetize()
         self:AddTimedCallback(StructureBeacon.Magnetize, 1)
    end
    function StructureBeacon:Magnetize()
      local eligable = {}
      local entity = GetEntitiesWithMixinForTeam( "Supply", 2 )
      
      for i = 1, #entity do
         local structure = entity[i]
         local distance = self:GetDistance(structure)
           local restrictions = distance >= 8 and not structure:isa("Drifter") and not structure:isa("DrifterEgg") and not  ( structure.GetIsMoving and structure:GetIsMoving() )  and not GetIsACreditStructure(structure)  and structure:GetIsBuilt() and not GetIsStructureSiegeWall(self, structure)
            if restrictions and self:GetIsAlive() then
            
                   local success = false 
                       if distance >= 16 then
                            if HasMixin(entity, "Obstacle") then  entity:RemoveFromMesh()end
                            success = structure:SetOrigin( FindFreeSpace(self:GetOrigin(), .5, 7 ) )
                             if HasMixin(structure, "Obstacle") then
                                if structure.obstacleId == -1 then structure:AddToMesh() end
                             end
                            if success then return self:GetIsAlive() end
                       end 
                       
                         structure:ClearOrders()
                         success = structure:GiveOrder(kTechId.Move, self:GetId(), FindFreeSpace(self:GetOrigin(), .5, 7), nil, true, true) 
                        if success then return self:GetIsAlive() end
                       
            end
      end
return self:GetIsAlive()
  end
  
         function StructureBeacon:OnDestroy()
        ScriptActor.OnDestroy(self)
         end 
end //
Shared.LinkClassToMap("StructureBeacon", StructureBeacon.kMapName, networkVars)