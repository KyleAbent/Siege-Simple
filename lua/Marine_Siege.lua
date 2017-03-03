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

function Marine:GiveClawRailgunExo(spawnPoint)

    local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "ClawRailgun" })
    return exo
    
end

function Marine:GiveDualRailgunExo(spawnPoint)

    local exo = self:Replace(ExoSiege.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun" })
    return exo
    
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