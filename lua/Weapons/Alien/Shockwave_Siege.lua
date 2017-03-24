local kShockWaveVelocity = 31
local kShockwaveLifeTime = 0.49

local function DestroyShockwave(self)

    if Server then
    
        local owner = self:GetOwner()
        if owner then
        
            for i = 0, owner:GetNumChildren() - 1 do
            
                local child = owner:GetChildAtIndex(i)
                if HasMixin(child, "Stomp") then
                    child:UnregisterShockwave(self)
                end
                
            end
            
        end
        
        DestroyEntity(self)
        
    end
    
end

-- called in on processmove server side by stompmixin
function Shockwave:UpdateShockwave(deltaTime)

    if not self.endPoint then
    
        local bestEndPoint = nil
        local bestFraction = 0
    
        for i = 1, 11 do
        
            local offset = Vector.yAxis * (i-1) * 0.3
            local trace = Shared.TraceRay(self:GetOrigin() + offset, self:GetOrigin() + self:GetCoords().zAxis * kShockWaveVelocity * kShockwaveLifeTime + offset, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))

            --DebugLine(self:GetOrigin() + offset, trace.endPoint, 2, 1, 1, 1, 1)
            
            if trace.fraction == 1 then
            
                bestEndPoint = trace.endPoint
                break
                
            elseif trace.fraction > bestFraction then
            
                bestEndPoint = trace.endPoint
                bestFraction = trace.fraction
            
            end
        
        end
        
        self.endPoint = bestEndPoint
        local origin = self:GetOrigin()
        origin.y = self.endPoint.y
        self:SetOrigin(origin)
        
        --DebugLine(origin, self.endPoint, 2, 1, 0, 0, 1)
    
    end

     local newPosition = SlerpVector(self:GetOrigin(), self.endPoint, self:GetCoords().zAxis * kShockWaveVelocity * deltaTime)
     
     if (newPosition - self.endPoint):GetLength() < 0.1 then
        DestroyShockwave(self)
     else
        self:SetOrigin(newPosition)
     end

end

function Shockwave:Detonate()

    local origin = self:GetOrigin()

    local groundTrace = Shared.TraceRay(origin, origin - Vector.yAxis * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterAllButIsa("Tunnel"))
    local enemies = GetEntitiesWithMixinWithinRange("Live", groundTrace.endPoint, 2.2)
    
    -- never damage the owner
    local owner = self:GetOwner()
    if owner then
        table.removevalue(enemies, owner)
    end
    
    if groundTrace.fraction < 1 then
    
        for _, enemy in ipairs(enemies) do
        
            local enemyId = enemy:GetId()
            if enemy:GetIsAlive() and not table.contains(self.damagedEntIds, enemyId) and math.abs(enemy:GetOrigin().y - groundTrace.endPoint.y) < 0.8 then
                
                self:DoDamage(kStompDamage, enemy, enemy:GetOrigin(), GetNormalizedVector(enemy:GetOrigin() - groundTrace.endPoint), "none")
                table.insert(self.damagedEntIds, enemyId)
                
                if not HasMixin(enemy, "GroundMove") or enemy:GetIsOnGround() then
                    self:TriggerEffects("shockwave_hit", { effecthostcoords = enemy:GetCoords() })
                end

                if HasMixin(enemy, "Stun") then
                    enemy:SetStun(kDisruptMarineTime)
                    if enemy:isa("Exo") then
                     DestroyShockwave(self)
                     end
                end  
                
            end
        
        end
    
    end
    
    return true

end