local networkVars =
{
    wallWalking = "compensated boolean",
    timeLastWallWalkCheck = "private compensated time",
}

if Client then
    Script.Load("lua/Gorge_Client.lua", true)
end

local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3
local kJumpWallRange = 0.4
local kJumpWallFeelerSize = 0.1
local kWallJumpInterval = 0.4
local kWallJumpForce = 5.2 // scales down the faster you are
local kMinWallJumpForce = 0.1
local kVerticalWallJumpForce = 4.3

local origcreate = Gorge.OnCreate
function Gorge:OnCreate()

    origcreate(self)
    InitMixin(self, WallMovementMixin)
    
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
    self.timeLastWallJump = 0
end
local originit = Gorge.OnInitialized
function Gorge:OnInitialized()

    originit(self)
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    self.timeLastWallJump = 0
end



function Gorge:GetRebirthLength()
return 3
end
function Gorge:GetRedemptionCoolDown()
return 30
end
function Gorge:GetBaseArmor()
    return kGorgeArmor
end




function Gorge:GetCanJump()
    local canWallJump = self:GetCanWallJump()
    return self:GetIsOnGround() or canWallJump
end
function Gorge:GetIsWallWalking()
    return self.wallWalking
end
function Gorge:GetIsWallWalkingPossible() 
    return not self:GetRecentlyJumped() and not self:GetCrouching()
end
local function PredictGoal(self, velocity)

    PROFILE("Gorge:PredictGoal")

    local goal = self.wallWalkingNormalGoal
    if velocity:GetLength() > 1 and not self:GetIsGround() then

        local movementDir = GetNormalizedVector(velocity)
        local trace = Shared.TraceCapsule(self:GetOrigin(), movementDir * 2.5, Gorge.kXExtents, 0, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))

        if trace.fraction < 1 and not trace.entity then
            goal = trace.normal    
        end

    end

    return goal

end

// Handle transitions between starting-sliding, sliding, and ending-sliding
local function UpdateGorgeSliding(self, input)

    PROFILE("Gorge:UpdateGorgeSliding")
    
    local slidingDesired = GetIsSlidingDesired(self, input)
    if slidingDesired and not self.sliding and self:GetIsOnGround() and self:GetEnergy() >= kBellySlideCost and not self:GetIsWallWalking() then
    
        self.sliding = true
        self.startedSliding = true
        
        if Server then
            if (GetHasSilenceUpgrade(self) and ConditionalValue(self.RTDSilence == true, 3, GetVeilLevel(self:GetTeamNumber())) == 0) or not GetHasSilenceUpgrade(self) then
                self.slideLoopSound:Start()
            end
        end
        
        self:DeductAbilityEnergy(kBellySlideCost)
        self:PrimaryAttackEnd()
        self:SecondaryAttackEnd()
        
    end
    
    if not slidingDesired and self.sliding then
    
        self.sliding = false
        
        if Server then
            self.slideLoopSound:Stop()
        end
        
        self.timeSlideEnd = Shared.GetTime()
    
    end

    // Have Gorge lean into turns depending on input. He leans more at higher rates of speed.
    if self:GetIsBellySliding() then

        local desiredBellyYaw = 2 * (-input.move.x / kSlidingMoveInputScalar) * (self:GetVelocity():GetLength() / self:GetMaxSpeed())
        self.bellyYaw = Slerp(self.bellyYaw, desiredBellyYaw, input.time * kGorgeLeanSpeed)
        
    end
    
end
function Gorge:GetRecentlyWallJumped()
    return self.timeLastWallJump + kWallJumpInterval > Shared.GetTime()
end

function Gorge:GetCanWallJump()

    local wallWalkNormal = self:GetAverageWallWalkingNormal(kJumpWallRange, kJumpWallFeelerSize)
    if wallWalkNormal then -- and GetHasTech(self, kTechId.BileBomb) then
        return wallWalkNormal.y < 0.5
    end
    
    return false

end

function Gorge:ModifyJump(input, velocity, jumpVelocity)

    if self:GetCanWallJump() then
    
        local direction = input.move.z == -1 and -1 or 1
    
        // we add the bonus in the direction the move is going
        local viewCoords = self:GetViewAngles():GetCoords()
        self.bonusVec = viewCoords.zAxis * direction
        self.bonusVec.y = 0
        self.bonusVec:Normalize()
        
        jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2

        local celerityMod = (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.4
        local currentSpeed = velocity:GetLengthXZ()
        local fraction = 1 - Clamp( currentSpeed / (11 + celerityMod), 0, 1)        
        
        local force = math.max(kMinWallJumpForce, (kWallJumpForce + celerityMod) * fraction)
          
        self.bonusVec:Scale(force)      

        if not self:GetRecentlyWallJumped() then
        
            self.bonusVec.y = viewCoords.zAxis.y * kVerticalWallJumpForce
            jumpVelocity:Add(self.bonusVec)

        end
        
        self.timeLastWallJump = Shared.GetTime()
        
    end
    
end
function Gorge:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end
function Gorge:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end


local kMaxSlideRoll = math.rad(20)

function Gorge:GetDesiredAngles()

    local desiredAngles = Alien.GetDesiredAngles(self)
    
    if self:GetIsBellySliding() then
        desiredAngles.pitch = - self.verticalVelocity / 10 
        desiredAngles.roll = GetNormalizedVectorXZ(self:GetVelocity()):DotProduct(self:GetViewCoords().xAxis) * kMaxSlideRoll
    end
   if self:GetIsWallWalking() then return self.currentWallWalkingAngles end
       return desiredAngles
end
function Gorge:GetHeadAngles()

    if self:GetIsWallWalking() then
        // When wallwalking, the angle of the body and the angle of the head is very different
        return self:GetViewAngles()
    else
        return self:GetViewAngles()
    end

end
function Gorge:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end

function Gorge:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end
function Gorge:OnJump()

    self.wallWalking = false

    local material = self:GetMaterialBelowPlayer()    
    local velocityLength = self:GetVelocity():GetLengthXZ()
    
    if velocityLength > 11 then
        self:TriggerEffects("jump_best", {surface = material})          
    elseif velocityLength > 8.5 then
        self:TriggerEffects("jump_good", {surface = material})       
    end

    self:TriggerEffects("jump", {surface = material})
    
end
function Gorge:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Gorge:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5
    
end
function Gorge:PreUpdateMove(input, runningPrediction)
    PROFILE("Gorge:PreUpdateMove")
    self.prevY = self:GetOrigin().y
        if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        // Most of the time, it returns a fraction of 0, which means
        // trace started outside the world (and no normal is returned)           
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize)
        if goal ~= nil then 
        
            self.wallWalkingNormalGoal = goal
            self.wallWalking = true
           -- self:SetEnergy(self:GetEnergy() - kWallWalkEnergyCost)

        else
            self.wallWalking = false
        end
    
    end
    
    if not self:GetIsWallWalking() then
        // When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end
    
    	if self.isriding then 
	 	local drifter = Shared.GetEntity( self.drifterId ) 
	 	 if drifter then
	   //    if not drifter:GetIsAlive() then self.isriding = false self.drifterId = Entity.invalidI return end 
	    	local offset = drifter:GetOrigin() + Vector(0,.5,0)
	 	   self:SetOrigin(offset)
           if not self:GetOrigin() == offset then self:SetOrigin(offset) SetMoveForHitregAnalysis(input)  end
         else
             local lerk = Shared.GetEntity(self.gorgeusingLerkID)
             if lerk then
         	       if not lerk then self.isriding = false self.gorgeusingLerkID = Entity.invalidI  self:RedemAlienToHive() return end 
         	       local origin = lerk:GetOrigin() + Vector(0,.5,0)
	 	           self.fullPrecisionOrigin = origin
	 	          self:SetOrigin(origin)
                  if not self:GetOrigin() == origin then self:SetOrigin(origin)  end
                  SetMoveForHitregAnalysis(input)
             end
         end
   end
   
   

  //  if self.leaping and Shared.GetTime() > self.timeOfLeap + kLeapTime then
  //      self.leaping = false
  //  end
    
    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles


end
function Gorge:GetMoveSpeedIs2D()
    return not self:GetIsWallWalking()
end
function Gorge:GetCanStep()
    return not self:GetIsWallWalking()
end

function Gorge:PostUpdatedsdMove(input, runningPrediction)

    if self:GetIsBellySliding() and self:GetIsOnGround() then
    
        local velocity = self:GetVelocity()
    
        local yTravel = self:GetOrigin().y - self.prevY
        local xzSpeed = velocity:GetLengthXZ()
        
        xzSpeed = xzSpeed + yTravel * -4
        
        if xzSpeed < kMaxSlidingSpeed or yTravel > 0 then
        
            local directionXZ = GetNormalizedVectorXZ(velocity)
            directionXZ:Scale(xzSpeed)

            velocity.x = directionXZ.x
            velocity.z = directionXZ.z
            
            self:SetVelocity(velocity)
            
        end

        self.verticalVelocity = yTravel / input.time
    
    end

end


if Server then


function Gorge:GetTierFourTechId()
    return kTechId.None
end


end


Shared.LinkClassToMap("Gorge", Gorge.kMapName, networkVars, true)