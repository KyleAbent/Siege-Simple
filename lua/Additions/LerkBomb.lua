--=============================================================================
--
-- lua\Weapons\Alien\Bomb.lua
--
-- Created by Charlie Cleveland (charlie@unknownworlds.com)
-- Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
--
-- Bile bomb projectile
--
--=============================================================================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Weapons/DotMarker.lua")

PrecacheAsset("cinematics/vfx_materials/decals/bilebomb_decal.surface_shader")

class 'LerkBomb' (PredictedProjectile)

LerkBomb.kMapName            = "lerkbomb"
LerkBomb.kModelName          = PrecacheAsset("models/alien/gorge/bilebomb.model")

LerkBomb.kRadius             = 0.2
LerkBomb.kClearOnImpact      = false
LerkBomb.kClearOnEnemyImpact = true

--LerkBomb max amount of time a Bomb can last for
LerkBomb.kLifetime = 6

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function LerkBomb:OnCreate()
    
    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
                 if Server then
        self:AddTimedCallback(LerkBomb.TimeUp, 9)
                end
                
end

function LerkBomb:GetDeathIconIndex()
    return 
end
function LerkBomb:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:Detonate( targetHit )
        end
        return true
    end    

    

end
if Server then

    local function SineFalloff(distanceFraction)
        local piFraction = Clamp(distanceFraction, 0, 1) * math.pi / 2
        return math.cos(piFraction + math.pi) + 1 
    end

        if targetHit and GetAreEnemies(self, targetHit) then
            
            self:Detonate(targetHit, hitPoint )
                
        end
        
     function LerkBomb:ProcessHit(targetHit, surface, normal, endPoint )

        if targetHit and GetAreEnemies(self, targetHit) then
            
            self:Detonate(targetHit, hitPoint )
          else      
                  if Server then
        self:AddTimedCallback(LerkBomb.TimeUp, LerkBomb.kLifetime)
                end
           end
           
        end
        
        
     function LerkBomb:Detonate(targetHit, hitPoint )
        local dotMarker = CreateEntity(DotMarker.kMapName, self:GetModelOrigin(), self:GetTeamNumber())
		dotMarker:SetTechId(kTechId.BileBomb)
		dotMarker:SetDamageType(kBileBombDamageType)        
        dotMarker:SetLifeTime(kBileBombDuration * 0.4)
        dotMarker:SetDamage(kBileBombDamage * 0.7 )
        dotMarker:SetRadius(kBileBombSplashRadius * 0.7)
        dotMarker:SetDamageIntervall(kBileBombDotInterval * 0.7)
        dotMarker:SetDotMarkerType(DotMarker.kType.Static)
        dotMarker:SetTargetEffectName("bilebomb_onstructure")
        dotMarker:SetDeathIconIndex(kDeathMessageIcon.BileBomb)
        dotMarker:SetOwner(self:GetOwner())
        dotMarker:SetFallOffFunc(SineFalloff)
        
        dotMarker:TriggerEffects("bilebomb_hit")

        DestroyEntity(self)
        
        CreateExplosionDecals(self, "bilebomb_decal")

    end
    
    function LerkBomb:TimeUp(currentRate)

        self:Detonate(targetHit, hitPoint )
        return false
    
    end

end

function LerkBomb:GetNotifiyTarget()
    return false
end


Shared.LinkClassToMap("LerkBomb", LerkBomb.kMapName, networkVars)