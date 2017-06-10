Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/SaltMixin.lua")
local kHoloMarineMaterialname = PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.material")

local networkVars = {}

AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(SaltMixin, networkVars)



    local originit = InfantryPortal.OnInitialized
    function InfantryPortal:OnInitialized()
        originit(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, SaltMixin)
    end
        function InfantryPortal:GetMaxLevel()
    return 15
    end
    function InfantryPortal:GetAddXPAmount()
    return 0.30
    end
    /*
local function CreateSpinEffect(self)


    if not self.spinCinematic then
    
        self.spinCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.spinCinematic:SetCinematic(kSpinEffect)
        self.spinCinematic:SetCoords(self:GetCoords())
        self.spinCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    
    end
    
    if not self.fakeMarineModel and not self.fakeMarineMaterial then
    
        self.fakeMarineModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        self.fakeMarineModel:SetModel(Shared.GetModelIndex(kHoloMarineModel))
        
        local coords = self:GetCoords()
        coords.origin = coords.origin + Vector(0, 0.4, 0)
        
        self.fakeMarineModel:SetCoords(coords)
        self.fakeMarineModel:InstanceMaterials()
        self.fakeMarineModel:SetMaterialParameter("hiddenAmount", 1.0)
        
        self.fakeMarineMaterial = AddMaterial(self.fakeMarineModel, kHoloMarineMaterialname)
    
    end
    
    if self.clientQueuedPlayerId ~= self.queuedPlayerId then
        self.timeSpinStarted = self.queuedPlayerStartTime or Shared.GetTime()
        self.clientQueuedPlayerId = self.queuedPlayerId
    end
    
    local spawnProgress = Clamp((Shared.GetTime() - self.timeSpinStarted) / self:GetSpawnTime() , 0, 1)
   -- Print("spawnProgress is %s", spawnProgress)
    
    self.fakeMarineModel:SetIsVisible(true)
    self.fakeMarineMaterial:SetParameter("spawnProgress", spawnProgress+0.2)  
end
if Server then
// Spawn player on top of IP. Returns true if it was able to, false if way was blocked.
local function SpawnPlayer(self)

    if self.queuedPlayerId ~= Entity.invalidId then
    
        local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
        local team = queuedPlayer:GetTeam()
        
        // Spawn player on top of IP
        local spawnOrigin = self:GetAttachPointOrigin("spawn_point")
        spawnOrigin = ConditionalValue(self:CheckSpaceAboveForSpawn(), FindFreeSpace(self:GetOrigin(), 1, 4), spawnOrigin)
        local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetAngles())
        if success then

            player:SetCameraDistance(0)
            
            if HasMixin( player, "Controller" ) and HasMixin( player, "AFKMixin" ) then
                
                if player:GetAFKTime() > self:GetSpawnTime() - 1 then
                    
                    player:DisableGroundMove(0.1)
                    player:SetVelocity( Vector( GetSign( math.random() - 0.5) * 2.25, 3, GetSign( math.random() - 0.5 ) * 2.25 ) )
                    
                end
                
            end
            
            self.queuedPlayerId = Entity.invalidId
            self.queuedPlayerStartTime = nil
            
            player:ProcessRallyOrder(self)

            self:TriggerEffects("infantry_portal_spawn")            
            
            return true
            
        else
            Print("Warning: Infantry Portal failed to spawn the player")
        end
        
    end
    
    return false

end

*/
function InfantryPortal:GetMinRangeAC()
return IPAutoCCMR  
end
function InfantryPortal:CheckSpaceAboveForSpawn()

    local startPoint = self:GetOrigin() 
    local endPoint = startPoint + Vector(0.35, 0.95, 0.35)
    
    return GetWallBetween(startPoint, endPoint, self)
    
end

local function StopSpinning(self)

    self:TriggerEffects("infantry_portal_stop_spin")
    self.timeSpinUpStarted = nil
    
end



    function InfantryPortal:FinishSpawn()
    
        SpawnPlayer(self)
        StopSpinning(self)
        self.timeSpinUpStarted = nil
end

end


    function InfantryPortal:GetSpawnTime()
    local total =  ( kMarineRespawnTime - (GetRoundLengthToSiege()/1.5) * kMarineRespawnTime ) * 1.5
      total = Clamp(total, 4, kMarineRespawnTime)
    --Print("InfantryPortal GetSpawnTime Is: %s", total)
    return total
end

if Client then


local origupdate = InfantryPortal.OnUpdate

    function InfantryPortal:OnUpdate(deltaTime)
       origupdate(self, deltaTime)
               local shouldSpin = GetIsUnitActive(self) and self.queuedPlayerId ~= Entity.invalidId and (self.preventSpinDuration == nil or self.preventSpinDuration == 0)
        if shouldSpin then
            CreateSpinEffect(self)
            end
    end
end
if Server then

local origfree = InfantryPortal.FillQueueIfFree
function InfantryPortal:FillQueueIfFree()

  if GetSandCastle():GetSDBoolean() then return end
  
  origfree(self)

end

end
Shared.LinkClassToMap("InfantryPortal", InfantryPortal.kMapName, networkVars)