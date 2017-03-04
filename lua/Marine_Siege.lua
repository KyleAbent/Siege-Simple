Script.Load("lua/Additions/ConcGrenadeThrower.lua")
Script.Load("lua/Additions/ConcGrenade.lua")
Script.Load("lua/Additions/JediConcGrenadeThrower.lua")
Script.Load("lua/Additions/JediConcGrenade.lua")


local origcreate = Marine.OnCreate
function Marine:OnCreate()
  origcreate(self)
  if Server then ExploitCheck(self) end
end

function Marine:GetHasLayStructure()
        local weapon = self:GetWeaponInHUDSlot(5)
        local builder = false
    if (weapon) then
            builder = true
    end
    
    return builder
end
function Marine:GetCanBeVortexed()
    return false
end

if Server then
/*
local origcweapons = Marine.InitWeapons


function Marine:InitWeapons()

origcweapons(self)

 if not GetGameStarted() or self:GetDarwinMode() then
    -- Print("Giving item")
     self:GiveItem(JediConcGrenadeThrower.kMapName, true)
 end

end
*/
function Marine:GiveLayStructure(techid, mapname)
  --  if not self:GetHasLayStructure() then
           local laystructure = self:GiveItem(LayStructures.kMapName)
           self:SetActiveWeapon(LayStructures.kMapName)
           laystructure:SetTechId(techid)
           laystructure:SetMapName(mapname)
  -- else
   --  self:TellMarine(self)
  -- end
end


function Marine:GiveExo(spawnPoint)
    local random = math.random(1,2)
    if random == 1 then 
        local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun" })
    return exo
    else
        local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun" })
    return exo
    end

    
end

function Marine:GiveDualExo(spawnPoint)

    local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun" })
    return exo
    
end
function Marine:GiveDualWelder(spawnPoint)

    local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "WelderWelder" })
    return exo
    
end
function Marine:GiveClawRailgunExo(spawnPoint)

    local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "ClawRailgun" })
    return exo
    
end

function Marine:GiveDualRailgunExo(spawnPoint)

    local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun" })
    return exo
    
end

local function BuyWelderExo(self)

    local maxAttempts = 100
    for index = 1, maxAttempts do
    
        -- Find open area nearby to place the big guy.
        local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
        local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)

        local spawnPoint        
        local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
        
        if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
            spawnPoint = checkPoint
        else
            spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 5, EntityFilterOne(self))
        end    
            

        if spawnPoint then
        
            self:AddResources(-GetCostForTech(techId))
            
                self:GiveDualWelder(spawnPoint)
            return
            
        end
        
    end
    
    Print("Error: Could not find a spawn point to place the Exo")
    
end

local origattemptbuy = Marine.AttemptToBuy
function Marine:AttemptToBuy(techIds)

  local techId = techIds[1]
    
    local hostStructure = GetHostStructureFor(self, techId)

    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
        
            Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if self:GetTeam() and self:GetTeam().OnBought then
                self:GetTeam():OnBought(techId)
            end
            
            if techId == kTechId.DualWelderExosuit then
                 Print("Derp")
                 BuyWelderExo(self)
             else
                origattemptbuy(self, techIds)
            end
       end
   end
    

end

elseif Client then



local orig_Marine_UpdateGhostModel = Marine.UpdateGhostModel
function Marine:UpdateGhostModel()

orig_Marine_UpdateGhostModel(self)

 self.currentTechId = nil
 
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon then
       if weapon:isa("LayStructures") then
        self.currentTechId = weapon:GetDropStructureId()
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
        elseif weapon:isa("LayMines") then
        self.currentTechId = kTechId.Mine
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
         end
    end




end --function


function Marine:AddGhostGuide(origin, radius)

return

end

end -- client