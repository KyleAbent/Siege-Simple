Script.Load("lua/GlowMixin.lua")
local networkVars =
{
   hasjumppack = "private boolean",
   lastjump = "private time",
   hasfirebullets = "private boolean",
   hasresupply = "private boolean",
   heavyarmor = "private boolean",
   nanoarmor = "private boolean",
}

AddMixinNetworkVars(GlowMixin, networkVars)

local originit = Marine.OnInitialized
function Marine:OnInitialized()
    originit(self)
    InitMixin(self, GlowMixin)
end

local origcreate = Marine.OnCreate
function Marine:OnCreate()
  origcreate(self)
 local open = GetSiegeDoorOpen()
 //Print("siege door is open %s", open)
       if open == false then
         if GetIsInSiege(self)
           then self:Kill()  
            end
        end
        self.hasjumppack  = false
         self.lastjump = 0
end
function Marine:OnLocationChange(locationName)
 local open = GetSiegeDoorOpen()
 //Print("siege door is open %s", open)
       if open == false then
         if string.find(locationName, "siege") or string.find(locationName, "Siege") 
           then self:Kill()  
            end
        end
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
function Marine:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self.heavyarmor and 1.3 or 1
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis
        coords.zAxis = coords.zAxis * scale
    return coords
end

local origarmor = Marine.GetArmorAmount
function Marine:GetArmorAmount(armorLevels)
    local orig = origarmor(self, armorLevels)
    return orig + ConditionalValue(self.heavyarmor, 30, 0)
end

function Marine:GetHasResupply()
    if self.hasresupply then
    return true
    else 
    return false
    end
end
function Marine:GetHasHeavyArmor()
    if self.heavyarmor then
    return true
    else 
    return false
    end
end
function Marine:GetHasFireBullets()
    if self.hasfirebullets then
    return true
    else 
    return false
    end
end
function Marine:GetHasNanoArmor()
    if self.nanoarmor then
    return true
    else 
    return false
    end
end
function Marine:AdjustDisplayRessuply(player, left, has) 
 return
end
local origMove = Marine.OnProcessMove
function Marine:OnProcessMove(input)
  origMove(self, input)
  if not self:isa("JetpackMarine") then
      if self.hasjumppack then
       if Shared.GetTime() >  self.lastjump + 1.5 and bit.band(input.commands, Move.Jump) ~= 0 and bit.band(input.commands, Move.Crouch) ~= 0 then
       --if self:GetGravity() ~= 0 then self:JumpPackNotGravity() end
       local range = 12
       local force = 12
       local velocity = self:GetVelocity() * 0.5
       local forwardVec = self:GetViewAngles():GetCoords().zAxis
       local newVelocity = velocity + GetNormalizedVectorXZ(forwardVec) * force
          //Jumping upward ruins it.
        newVelocity.y = newVelocity.y * 0.3
        self:SetVelocity(  self:GetVelocity() + newVelocity )
        self.lastjump = Shared.GetTime()
        end
    end
  end
            if self.nanoarmor then
            
                if not self.lastCheck or Shared.GetTime() > self.lastCheck + 1 then
                  self:SetArmor(self:GetArmor() + 1, true) 
                  self.lastCheck = Shared.GetTime()
               end
            
            end
            
      if Server then
         if self.hasresupply then
         --  Print("Has resupply check 1")
           if not self.lastsupply or Shared.GetTime() >  self.lastsupply + 10 then
            if not self.suppliesleft then self.suppliesleft = 5 end
            local deduct = false
              if self.suppliesleft >= 1 then
                    if self:GetHealth() <= 90 then 
                   self:TriggerDropPack(self:GetOrigin(), kTechId.MedPack)
                   deduct = true
                    end
                    if self:GetWeaponInHUDSlot(1) and self:GetWeaponInHUDSlot(1):GetAmmoFraction() <= .5
                    or self:GetWeaponInHUDSlot(2) and self:GetWeaponInHUDSlot(2):isa("Pistol") and 
                    self:GetWeaponInHUDSlot(2):GetAmmoFraction() <= .3  then 
                    self:TriggerDropPack(self:GetOrigin(), kTechId.AmmoPack) 
                    deduct = true
                    end 
                    
            if deduct then 
            self.suppliesleft = self.suppliesleft - 1
            self.lastsupply = Shared.GetTime()
            self.hasresupply = self.suppliesleft >= 1 
            self:AdjustDisplayRessuply(self:GetClient():GetControllingPlayer(), self.suppliesleft, self.hasresupply) 
            end
            
             end
             
         end
       end
     end
  
  
end
if Server then

local function GetDroppackSoundName(techId)

    if techId == kTechId.MedPack then
        return MedPack.kHealthSound
    elseif techId == kTechId.AmmoPack then
        return AmmoPack.kPickupSound
   // elseif techId == kTechId.CatPack then
   //     return CatPack.kPickupSound
    end 
   
end
function Marine:TriggerDropPack(position, techId)

    local mapName = LookupTechData(techId, kTechDataMapName)
    local success = false
    if mapName then
    
        local droppack = CreateEntity(mapName, position, self:GetTeamNumber())
        StartSoundEffectForPlayer(GetDroppackSoundName(techId), self)
       // self:ProcessSuccessAction(techId)
        success = true
        
    end

    return success

end


local origdata = Marine.CopyPlayerDataFrom

function Marine:CopyPlayerDataFrom(player)
 origdata(self, player)
 
  if player:isa("Marine") then
self.hasjumppack = player.hasjumppack
self.Glowing = player.Glowing
self.Color = player.Color
self.timeofStartGlow = player.timeofStartGlow 
self.hasfirebullets = player.hasfirebullets 
self.hasresupply = player.hasresupply 
self.heavyarmor = player.heavyarmor 
self.nanoarmor = player.nanoarmor 
end

end

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

function Marine:GetWeaponsToStore()
local toReturn = {}
            local weapons = self:GetWeapons()
            
          if weapons then
          
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)     
                local weapon
                table.insert(toReturn, weapons[i]:GetId())       
            end
            
           end
           
           return toReturn
end
function Marine:GiveExo(spawnPoint)
    local random = math.random(1,2)
    if random == 1 then 
        local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun", storedWeaponsIds = self:GetWeaponsToStore()  })
    return exo
    else
        local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    end

    
end

function Marine:GiveDualExo(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end
function Marine:GiveDualWelder(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "WelderWelder", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end
function Marine:GiveDualFlamer(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "FlamerFlamer", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end
function Marine:GiveClawRailgunExo(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "ClawRailgun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end

function Marine:GiveDualRailgunExo(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun", storedWeaponsIds = self:GetWeaponsToStore() })
    return exo
    
end
kIsExoTechId = { [kTechId.DualFlamerExosuit] = true, [kTechId.DualMinigunExosuit] = true,
                 [kTechId.DualWelderExosuit] = true, [kTechId.DualRailgunExosuit] = true }
                 
local function BuyExo(self, techId)

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
            
        local weapons 

        if spawnPoint then
        
            self:AddResources(-GetCostForTech(techId))
            
            local exo = nil
            
            if techId == kTechId.DualFlamerExosuit then
                exo = self:GiveDualFlamer(spawnPoint)
            elseif techId == kTechId.DualMinigunExosuit then
                exo = self:GiveDualExo(spawnPoint)
            elseif techId == kTechId.DualWelderExosuit then
                exo = self:GiveDualWelder(spawnPoint)
            elseif techId == kTechId.DualRailgunExosuit then
                exo = self:GiveDualRailgunExo(spawnPoint)
            end
            

            
            exo:TriggerEffects("spawn_exo")
            
            return
            
        end
        
    end
    
    Print("Error: Could not find a spawn point to place the Exo")
    
end
local function GetHostSupportsTechId(forPlayer, host, techId)

    if Shared.GetCheatsEnabled() then
        return true
    end
    
    local techFound = false
    
    if host.GetItemList then
    
        for index, supportedTechId in ipairs(host:GetItemList(forPlayer)) do
        
            if supportedTechId == techId then
            
                techFound = true
                break
                
            end
            
        end
        
    end
    
    return techFound
    
end
function GetHostStructureFor(entity, techId)

    local hostStructures = {}
    table.copy(GetEntitiesForTeamWithinRange("Armory", entity:GetTeamNumber(), entity:GetOrigin(), Armory.kResupplyUseRange), hostStructures, true)
    table.copy(GetEntitiesForTeamWithinRange("PrototypeLab", entity:GetTeamNumber(), entity:GetOrigin(), PrototypeLab.kResupplyUseRange), hostStructures, true)
    table.copy(GetEntitiesForTeamWithinRange("ArmsLab", entity:GetTeamNumber(), entity:GetOrigin(), 2.5), hostStructures, true)
    
    if table.count(hostStructures) > 0 then
    
        for index, host in ipairs(hostStructures) do
        
            -- check at first if the structure is hostign the techId:
            if GetHostSupportsTechId(entity,host, techId) then
                return host
            end
        
        end
            
    end
    
    return nil

end


function Marine:GetHasJumpPack()

if self.hasjumppack then return true
else return false
end

end
local origattemptbuy = Marine.AttemptToBuy
function Marine:AttemptToBuy(techIds)

  local techId = techIds[1]
  
               if techId == kTechId.JumpPack then
              --  StartSoundEffectForPlayer(Marine.activatedsound, self)
            //    self:AddResources(-GetCostForTech(techId))
                self.hasjumppack = true
              --  Print("Bought jump pack")
                return true
             elseif techId == kTechId.Resupply then
                self.hasresupply = true
                self:AdjustDisplayRessuply(self:GetClient():GetControllingPlayer(), 5, self.hasresupply)
               -- Print("bought resupply boolean is %s", self.hasresupply)
                return true
              elseif techId == kTechId.HeavyArmor then
               self.heavyarmor = true
               return true
               elseif techId == kTechId.FireBullets then
                self.hasfirebullets = true
                return true
               elseif techId == kTechId.RegenArmor then
                 self.nanoarmor = true
                 return true
                end
                
    local hostStructure = GetHostStructureFor(self, techId)

    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
        
            Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if self:GetTeam() and self:GetTeam().OnBought then
                self:GetTeam():OnBought(techId)
            end
            
                 
              if kIsExoTechId[techId] then
                BuyExo(self, techId)    
               else
                if hostStructure:isa("Armory") then self:AddResources(-GetCostForTech(techId)) end
                origattemptbuy(self, techIds)
            end
       end
   end
    

end
    function Marine:OnDamageDone(doer, target)
         -- Print(" Marine OnDamageDone 1")
        if self:GetHasFireBullets() and doer:GetParent() == self then
           --Print(" Marine OnDamageDone 2")
            if HasMixin(target, "Fire") and target:GetIsAlive() then
           -- Print(" Marine OnDamageDone 3")
                target:SetOnFire(self)
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

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars)