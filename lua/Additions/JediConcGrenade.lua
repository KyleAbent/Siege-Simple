Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/OwnerMixin.lua")


class 'JediConcGrenade' (PredictedProjectile)

JediConcGrenade.kMapName = "jediconcgrenade"
JediConcGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_nerve_world.model")
JediConcGrenade.kUseServerPosition = true

JediConcGrenade.kRadius = 0.085
JediConcGrenade.kClearOnImpact = true
JediConcGrenade.kClearOnEnemyImpact = true 


local networkVars = 
{
}

local kDelay = 1

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function JediConcGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then    
        self:AddTimedCallback(ConcGrenade.BlowMinds, kDelay)
    end
end

function JediConcGrenade:GetDeathIconIndex()
    return kDeathMessageIcon.GasGrenade
end

    function JediConcGrenade:ProcessHit(targetHit, surface, normal, endPoint )

       //if self:GetVelocity():GetLength() > 2 then
           self:BlowMinds()
      //  end
        
    end

if Server then
      
    function JediConcGrenade:BlowMinds()  
            GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self:GetOrigin())})    
            local player = self:GetOwner()
            if self:GetDistance(player) > 8 then return end
            player:DisableGroundMove(0.5)
            local selforigin = self:GetOrigin()
                  selforigin.y = selforigin.y - 1
            local toPlayer = player:GetEyePos() - selforigin
            local strength = Clamp( 16 - self:GetDistance(player) - 1, 1, 16)
            local velocity = GetNormalizedVector(toPlayer) * strength
            local direction = player:GetOrigin() - selforigin
            direction:Normalize()
            local targetVelocity = direction  * strength
            targetVelocity.y = targetVelocity.y * strength
            player:SetVelocity(targetVelocity)
            GetEffectManager():TriggerEffects("arc_hit_secondary", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
            DestroyEntity(self)
   end
   
end

Shared.LinkClassToMap("JediConcGrenade", JediConcGrenade.kMapName, networkVars)



