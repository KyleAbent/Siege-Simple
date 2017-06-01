Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")

class 'Rock' (PredictedProjectile)

Rock.kMapName            = "rock"
Rock.kModelName          = PrecacheAsset("models/props/eclipse/eclipse_wallmods_l_02.model")

Rock.kClearOnImpact = true
Rock.kClearOnEnemyImpact = true
Rock.kRadius = 0.75

local kRocketLifetime = 1

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

-- Blow up after a time.
local function UpdateLifetime(self)

    // in order to get the correct lifetime, 
	// we start counting our lifetime from the first UpdateLifetime rather than when
    // we were created
    if not self.endOfLife then
        self.endOfLife = Shared.GetTime() + kRocketLifetime
    end

    if self.endOfLife <= Shared.GetTime() then
    
        self:Detonate(nil)
        return false
        
    end
    
    return true
    
end

function Rock:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    if Server then
        self:AddTimedCallback(UpdateLifetime, 0.1)
        self.endOfLife = nil
    end

end

function Rock:GetProjectileModel()
    return Rock.kModelName
end 

function Rock:GetDeathIconIndex()
    return kDeathMessageIcon.Stomp
end

function Rock:GetDamageType()
    return kDamageType.Normal
end
function Rock:ProcessHit(targetHit, surface, normal, endPoint)
    if Server then
        self:Detonate(targetHit, surface)  
    end
    
end

if Server then

    function Rock:Detonate(targetHit, surface)

        if not self:GetIsDestroyed() then
             self.stopSimulation = true
            local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", 1, self:GetOrigin(), kAcidRocketRadius)
            // full damage on direct impact
            if targetHit then
                table.removevalue(hitEntities, targetHit)
                self:DoDamage(kAcidRocketDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
            end
            RadiusDamage(hitEntities, self:GetOrigin(), kAcidRocketRadius, kAcidRocketDamage, self)
            self:TriggerEffects("bilebomb_hit")
            DestroyEntity(self)
        end

    end

end


Shared.LinkClassToMap("Rock", Rock.kMapName, networkVars)