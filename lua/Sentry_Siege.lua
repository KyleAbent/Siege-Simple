Script.Load("lua/Additions/LevelsMixin.lua")
Script.Load("lua/Additions/SaltMixin.lua")
Sentry.kFov = 360
Sentry.kMaxPitch = 180 
Sentry.kMaxYaw = Sentry.kFov /2
Sentry.kTargetAcquireTime = 0.45
/*
local kPilotCinematicName = PrecacheAsset("cinematics/marine/flamethrower/pilot.cinematic")

local kTrailCinematics =
{
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part3.cinematic"),
}

local kFadeOutCinematicNames =
{
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
}
*/
function Sentry:GetFov()
    return 360
end

local networkVars = {}




AddMixinNetworkVars(LevelsMixin, networkVars)
AddMixinNetworkVars(SaltMixin, networkVars)



function Sentry:GetLevelPercentage()
return self.level / self:GetMaxLevel() * 1.3
end

    local originit = Sentry.OnInitialized
    function Sentry:OnInitialized()
        originit(self)
        InitMixin(self, LevelsMixin)
        InitMixin(self, SaltMixin)
    end
    
    function Sentry:GetMaxLevel()
    return 15
    end
    function Sentry:GetAddXPAmount()
    return 0.30
    end

function Sentry:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end


Shared.LinkClassToMap("Sentry", Sentry.kMapName, networkVars)

function GetCheckSentryLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName  and not sentry.isacreditstructure then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kCommSentryPerRoom
    
end

function Sentry:GetMinRangeAC()
return SentryAutoCCMR     
end
/*
function Sentry:CreateFlame(position, normal, direction)

    -- create flame entity, but prevent spamming:
    local nearbyFlames = GetEntitiesForTeamWithinRange("Flame", self:GetTeamNumber(), position, 1.5)    

    if table.count(nearbyFlames) == 0 then
    
        local flame = CreateEntity(Flame.kMapName, position, self:GetTeamNumber())
        flame:SetOwner(player)
        
        local coords = Coords.GetTranslation(flame:GetOrigin())
        coords.yAxis = normal
        coords.zAxis = direction
        
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.xAxis:Normalize()
        
        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
        coords.zAxis:Normalize()
        
        flame:SetCoords(coords)
        
    end

end
function Sentry:GetMeleeOffset()
    return 0.0 --flame
end
if Server then

    function Sentry:FireBullets()

     --if self.isFlame or
      local barellPoint  = self:GetBarrelPoint()
    local ents = {}


    local fireDirection = self:GetBarrelPoint().zAxis
    local extents = Vector(0.17, 0.17, 0.17) --width
    local remainingRange = kFlamethrowerRange
    
    local startPoint = Vector(barellPoint)
    local filterEnts = {self}
    
    for i = 1, 20 do
    
        if remainingRange <= 0 then
            break
        end
        
        local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, remainingRange, PhysicsMask.Flame, EntityFilterList(filterEnts))
        
        --DebugLine(startPoint, trace.endPoint, 0.3, 1, 0, 0, 1)
        
        -- Check for spores in the way.
       -- if Server and i == 1 then
       --     self:BurnSporesAndUmbra(startPoint, trace.endPoint)
       -- end
       --Nah.
        
        if trace.fraction ~= 1 then
        
            if trace.entity then
            
                if HasMixin(trace.entity, "Live") then
                    table.insertunique(ents, trace.entity)
                end
                
                table.insertunique(filterEnts, trace.entity)
                
            else
            
                -- Make another trace to see if the shot should get deflected.
                local lineTrace = Shared.TraceRay(startPoint, startPoint + remainingRange * fireDirection, CollisionRep.Damage, PhysicsMask.Flame, EntityFilterOne(self))
                
                if lineTrace.fraction < 0.8 then
                
                    fireDirection = fireDirection + trace.normal * 0.55
                    fireDirection:Normalize()
                    
                    if Server then
                        self:CreateFlame(lineTrace.endPoint, lineTrace.normal, fireDirection)
                    end
                    
                end
                
                remainingRange = remainingRange - (trace.endPoint - startPoint):GetLength()
                startPoint = trace.endPoint -- + fireDirection * self.kConeWidth * 2
                
            end
        
        else
            break
        end

    end
    
    for index, ent in ipairs(ents) do
    
        if ent ~= player then
        
            local toEnemy = GetNormalizedVector(ent:GetModelOrigin() - barellPoint)
            local health = ent:GetHealth()
            
            local attackDamage = kFlamethrowerDamage
            
            if HasMixin( ent, "Fire" ) then
                local time = Shared.GetTime()
                if ( ent:isa("AlienStructure") or HasMixin( ent, "Maturity" ) ) and ent:GetIsOnFire() and time >= (ent.timeBurnInit + kCompoundFireDamageDelay) then
                    attackDamage = kFlamethrowerDamage + ( kFlamethrowerDamage * kCompundFireDamageScalar )
                end
            end
            
            self:DoDamage( attackDamage, ent, ent:GetModelOrigin(), toEnemy )
            
            -- Only light on fire if we successfully damaged them
            if ent:GetHealth() ~= health and HasMixin(ent, "Fire") then
                ent:SetOnFire(player, self)
            end
            
           -- if ent.GetEnergy and ent.SetEnergy then
           --     ent:SetEnergy(ent:GetEnergy() - kFlameThrowerEnergyDamage)
           -- end
           -- Nah.
            
           -- if Server and ent:isa("Alien") then
           --     ent:CancelEnzyme()
           -- end
           --Nah.
            
        end
    
    end
    
        
    end


end
  if Client then
  
  function UpdatePilotEffect(self)

    
        if not self.pilotCinematic then
            
            self.pilotCinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            self.pilotCinematic:SetCinematic(kPilotCinematicName)
            self.pilotCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            
        end
  
        
        if renderModel then
        
        
                local attachCoords = self:GetAttachPointOrigin(Sentry.kMuzzleNode)       
                self.pilotCinematic:SetCoords(attachCoords)
            
            
        end
    
 --   else
    
     --   if self.pilotCinematic then
     --       Client.DestroyCinematic(self.pilotCinematic)
      --      self.pilotCinematic = nil
      --  end
    
    --end

end


      local function UpdateAttackEffects(self, deltaTime)
    
        local intervall = Sentry.kAttackEffectIntervall
        if self.attacking and (self.timeLastAttackEffect + intervall < Shared.GetTime()) then
            
            -- plays muzzle flash and smoke
         --   self:TriggerEffects("sentry_attack")

          --  self.timeLastAttackEffect = Shared.GetTime()
          
    
        
       -- if self.trailCinematic then
      --      Client.DestroyTrailCinematic(self.trailCinematic)
      --      self.trailCinematic = nil
     --   end
        
     --   if effectToLoad ~= kEffectType.None then            
            self:InitTrailCinematic(effectToLoad, parent)
      --  end
        
     --   self.effectLoaded = effectToLoad

    
    if self.trailCinematic then
    
        self.trailCinematic:SetIsVisible(self.createParticleEffects == true)
        
        if self.createParticleEffects then
            self:CreateImpactEffect(self:GetParent())
        end
    
    end
    
       UpdatePilotEffect(self)
            
        end
        
    end
    
     function Sentry:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if GetIsUnitActive(self) and self.deployed and self.attachedToBattery then
      
            -- Swing barrel yaw towards target
            if self.attacking then
            
                if self.targetDirection then
                
                    local invSentryCoords = self:GetAngles():GetCoords():GetInverse()
                    self.relativeTargetDirection = GetNormalizedVector( invSentryCoords:TransformVector( self.targetDirection ) )
                    self.desiredYawDegrees = Clamp(math.asin(-self.relativeTargetDirection.x) * 180 / math.pi, -Sentry.kMaxYaw, Sentry.kMaxYaw)            
                    self.desiredPitchDegrees = Clamp(math.asin(self.relativeTargetDirection.y) * 180 / math.pi, -Sentry.kMaxPitch, Sentry.kMaxPitch)       
                    
                end
                
                UpdateAttackEffects(self, deltaTime)
                
            -- Else when we have no target, swing it back and forth looking for targets
            else
            
                local sin = math.sin(math.rad((Shared.GetTime() + self:GetId() * .3) * Sentry.kBarrelScanRate))
                self.desiredYawDegrees = sin * self:GetFov()/2
                
                -- Swing barrel pitch back to flat
                self.desiredPitchDegrees = 0
            
            end
            
            -- swing towards desired direction
            self.barrelPitchDegrees = Slerp(self.barrelPitchDegrees, self.desiredPitchDegrees, Sentry.kBarrelMoveRate * deltaTime)    
            self.barrelYawDegrees = Slerp(self.barrelYawDegrees , self.desiredYawDegrees, Sentry.kBarrelMoveRate * deltaTime)
        
        end

end


function Sentry:InitTrailCinematic(effectType, player)

    self.trailCinematic = Client.CreateTrailCinematic(RenderScene.Zone_Default)
    
    local minHardeningValue = 0.5
    local numFlameSegments = 6


    
        self.trailCinematic:SetCinematicNames(kTrailCinematics)
    
        -- attach to third person fx node otherwise with an X offset since we align it along the X-Axis (the attackpoint is oriented in the model like that)
        self.trailCinematic:AttachTo(self, TRAIL_ALIGN_X,  Vector(0.3, 0, 0), "fxnode_sentrymuzzle")
        minHardeningValue = 0.1
        numFlameSegments = 8
    
    
    self.trailCinematic:SetFadeOutCinematicNames(kFadeOutCinematicNames)
    self.trailCinematic:SetIsVisible(false)
    self.trailCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    self.trailCinematic:SetOptions( {
            numSegments = numFlameSegments,
            collidesWithWorld = true,
            visibilityChangeDuration = 0.2,
            fadeOutCinematics = true,
            stretchTrail = false,
            trailLength = kTrailLength,
            minHardening = minHardeningValue,
            maxHardening = 2,
            hardeningModifier = 0.8,
            trailWeight = 0.2
        } )

end


  end  
  
  */
Shared.LinkClassToMap("Sentry", Sentry.kMapName, networkVars)
