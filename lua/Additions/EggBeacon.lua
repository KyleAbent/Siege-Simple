--Kyle 'Avoca' Abent 
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

class 'AlienBeacon' (ScriptActor)

AlienBeacon.kMapName = "alienbeacon"

AlienBeacon.kModelName = PrecacheAsset("models/alien/shell/shell.model")

AlienBeacon.kAnimationGraph =  PrecacheAsset("models/alien/shell/shell.animation_graph")

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function AlienBeacon:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, ObstacleMixin)    
    InitMixin(self, FireMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, CombatMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end

function AlienBeacon:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(AlienBeacon.kModelName, AlienBeacon.kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end

end

function AlienBeacon:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shell
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end

function AlienBeacon:GetCanSleep()
    return true
end

function AlienBeaconGetIsWallWalkingAllowed()
    return false
end 

function AlienBeaconGetReceivesStructuralDamage()
    return true
end
function AlienBeacon:GetIsSmallTarget()
    return true
end
function AlienBeacon:GetHealthbarOffset()
    return 0.45
end


Shared.LinkClassToMap("AlienBeacon", AlienBeacon.kMapName, networkVars)




class 'EggBeacon' (AlienBeacon)

EggBeacon.kMapName = "eggbeacon"


EggBeacon.kModelName = PrecacheAsset("models/alien/shell/shell.model")
local kAnimationGraph = PrecacheAsset("models/alien/shell/shell.animation_graph")

function EggBeacon:OnInitialized()
AlienBeacon.OnInitialized(self)
    self:SetModel(EggBeacon.kModelName, kAnimationGraph)
end


local kLifeSpan = 8

local networkVars = { }

local function TimeUp(self)

    self:Kill()
    return false

end

function EggBeacon:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shell
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
    function EggBeacon:OnKill(attacker, doer, point, direction)

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
        DestroyEntity(self)
    end
    
    function EggBeacon:OnDestroy()
        ScriptActor.OnDestroy(self)
    end
    function EggBeacon:GetTotalConstructionTime()
    local value =  ConditionalValue(GetIsInSiege(self), kEggBeaconBuildTime * 2, kEggBeaconBuildTime)
    return value
    end


function EggBeacon:OnConstructionComplete()
        if GetIsInSiege(self) then kLifeSpan = 4 end
        self:AddTimedCallback(TimeUp, kLifeSpan)  
        self:DoYourBusiness()
        self:AddTimedCallback(EggBeacon.DoYourBusiness, 1)
        if Server  then self:AdjustMaxHealth(675) self:AdjustMaxArmor(175) end
        
  end
function EggBeacon:DoYourBusiness()
   -- Print("DoYourBusiness")
      if not self:GetIsAlive() then return false end
         local egg = GetEntitiesForTeam( "Egg", 2 )
         local count = table.count(egg) or 0
      for i = 1, #egg do
       local actualegg = egg[i]
       local distance = self:GetDistance(actualegg)
       if distance >=8 then
           if HasMixin(actualegg, "Obstacle") then  actualegg:RemoveFromMesh()end
           actualegg:SetOrigin(FindFreeSpace(self:GetOrigin(), 1, 8))
           actualegg:SetHive(self)
              if HasMixin(actualegg, "Obstacle") then
                 if actualegg.obstacleId == -1 then actualegg:AddToMesh() end
              end
                             
           return self:GetIsAlive()
       end
      
      end
    local spawnpoint = FindFreeSpace(self:GetOrigin(), .5, 7)
    if spawnpoint and count < 16 then
     local eggy = CreateEntity(Egg.kMapName, spawnpoint, 2)
    --        egg:AddTimedCallback(function()  DestroyEntity(egg) end, 30)
            eggy:SetHive(self)
    end
   
    return self:GetIsAlive()
end

end //ofserver


function EggBeacon:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function EggBeacon:OverrideHintString(hintString)

    if self:GetIsUpgrading() then
        return "COMM_SEL_UPGRADING"
    end
    
    return hintString
    
end
Shared.LinkClassToMap("EggBeacon", EggBeacon.kMapName, networkVars)