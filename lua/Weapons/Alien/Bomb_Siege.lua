Bomb.kClearOnImpact  = false
Bomb.kLifetime = 3
function Bomb:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:Detonate( targetHit )
        end
     else
         if Server then
         self:AddTimedCallback(Bomb.TimeUp, Bomb.kLifetime)
         end
     end
        return true
end

if Server then

     function Bomb:TimeUp(currentRate)
         self:Detonate(targetHit, hitPoint )
        return false
    end
    function Bomb:ProcessHit(targetHit, surface, normal, endPoint )

        if targetHit and GetAreEnemies(self, targetHit) then
            
            self:Detonate(targetHit, hitPoint )
                
        elseif self:GetVelocity():GetLength() > 2 then
            
            
        end
        
    end
    
        function Bomb:Detonate(targetHit, surface, normal)        
        if not normal then normal = 1 end
        local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin() + normal * 0.2, self:GetTeamNumber())
		dotMarker:SetTechId(kTechId.BileBomb)
		dotMarker:SetDamageType(kBileBombDamageType)        
        dotMarker:SetLifeTime(kBileBombDuration)
        dotMarker:SetDamage(kBileBombDamage)
        dotMarker:SetRadius(kBileBombSplashRadius)
        dotMarker:SetDamageIntervall(kBileBombDotInterval)
        dotMarker:SetDotMarkerType(DotMarker.kType.Static)
        dotMarker:SetTargetEffectName("bilebomb_onstructure")
        dotMarker:SetDeathIconIndex(kDeathMessageIcon.BileBomb)
        dotMarker:SetOwner(self:GetOwner())
        dotMarker:SetFallOffFunc(SineFalloff)
        
        dotMarker:TriggerEffects("bilebomb_hit")

        DestroyEntity(self)
        
        CreateExplosionDecals(self, "bilebomb_decal")

    end
    
    

end