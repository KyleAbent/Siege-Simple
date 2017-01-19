/*
Conc Grenade inspired by TFC - With simple conversions of .bsp to .level && teleporter entities == fun rr minigame if e == throw gren?
Kyle 'Avoca' Abent
*/

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")

class 'ConcGrenade' (PredictedProjectile)

ConcGrenade.kMapName = "concgrenade"
ConcGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_nerve_world.model")
ConcGrenade.kUseServerPosition = true




ConcGrenade.kRadius = 0.085
ConcGrenade.kClearOnImpact = true
ConcGrenade.kClearOnEnemyImpact = true 


local networkVars = 
{
    concActivated = "boolean"
}

local kDelay = 4

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

local function TimeUp(self)
    DestroyEntity(self)
end

function ConcGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then    
        self:AddTimedCallback(TimeUp, kDelay + .5)
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

       //if self:GetVelocity():GetLength() > 2 then
           self:BlowMinds()
      //  end
        
    end

if Server then
        
    function ConcGrenade:BlowMinds()  
        --self:TriggerEffects("release_firegas", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )  
          GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self:GetOrigin())})
    
    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), 8)) do
      -- if Server and target.GetIsKnockbackAllowed and target:GetIsKnockbackAllowed() then
            local toPlayer = player:GetEyePos() - self:GetOrigin()
            local strength = Clamp( 8 - self:GetDistance(player), 1, 8)
            local velocity = GetNormalizedVector(toPlayer) * strength
            
                    // Take target mass into account.
        local direction = player:GetOrigin() - self:GetOrigin()
        direction:Normalize()
         local targetVelocity = direction * (300 / player:GetMass()) * strength
          if player:GetIsOnGround() then targetVelocity.y = targetVelocity.y + strength end --?
         player:SetVelocity(targetVelocity)
         GetEffectManager():TriggerEffects("arc_hit_secondary", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
         
    end
   end

end

Shared.LinkClassToMap("ConcGrenade", ConcGrenade.kMapName, networkVars)

