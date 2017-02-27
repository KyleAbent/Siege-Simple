/*
Conc Grenade inspired by TFC - With simple conversions of .bsp to .level && teleporter entities == fun rr minigame if e == throw gren?
Kyle 'Avoca' Abent
*/

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/OwnerMixin.lua")

class 'ConcGrenade' (PredictedProjectile)

ConcGrenade.kMapName = "concgrenade"
ConcGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_nerve_world.model")
ConcGrenade.kUseServerPosition = true




ConcGrenade.kRadius = 0.085
ConcGrenade.kClearOnImpact = true
ConcGrenade.kClearOnEnemyImpact = true 


local networkVars = 
{
}

local kDelay = 1.25

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function ConcGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then    
        self:AddTimedCallback(ConcGrenade.BlowMinds, kDelay)
    end
end

function ConcGrenade:GetDeathIconIndex()
    return kDeathMessageIcon.GasGrenade
end

function ConcGrenade:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:BlowMinds()
        end
        return true
    end
end 
    function ConcGrenade:ProcessHit(targetHit, surface, normal, endPoint )
      if Server then
       //if self:GetVelocity():GetLength() > 2 then
           self:BlowMinds()
      //  end
         end
    end

if Server then
        
    function ConcGrenade:BlowMinds()  
        --self:TriggerEffects("release_firegas", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )  
          GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self:GetOrigin())})
          
        local owner = self:GetOwner() --Print("owner is %s", owner)
       -- Print("Derp3")
    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), 8)) do
          --Stop fade blink / stop lerk glide?
          if  player:GetTeamNumber() == 2 then 
            -- player:SetElectrified(4)
     if player.DisableGroundMove then player:DisableGroundMove(0.3) end
                  if player.SlapPlayer then player:SlapPlayer() end
          end
    end
          DestroyEntity(self)
   end
end

Shared.LinkClassToMap("ConcGrenade", ConcGrenade.kMapName, networkVars)

