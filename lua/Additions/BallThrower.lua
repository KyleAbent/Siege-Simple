Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Additions/Ball.lua")
Script.Load("lua/Weapons/Projectile.lua")

class 'BallThrower' (Weapon)

BallThrower.kMapName = "ball_thrower"

local kModelName = PrecacheAsset("models/dev/dev_sphere.model")

local kBombVelocity = 15
local kShootLimit = 0.5
local currentModel = 0

function BallThrower:OnCreate()
    Weapon.OnCreate(self)
end


function FireBallProjectile(player)

    if Server then
          
        local viewAngles = player:GetViewAngles()
        
        local viewCoords = viewAngles:GetCoords()
        

        local startPoint = player:GetEyePos() + viewCoords.zAxis * 1
        
        local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.PredictedProjectileGroup, EntityFilterOne(player))
        startPoint = startPointTrace.endPoint
        
        local startVelocity = viewCoords.zAxis * kBombVelocity
        
        local findBall = GetBallForPlayerOwner(player)
        
        if findBall then
         DestroyEntity(findBall) --ugh
        end
        
        local newBall = CreateEntity(Ball.kMapName, startPoint, player:GetTeamNumber())
        newBall:Setup(player, startVelocity, true, nil, player, kModelName)
        newBall:SetTeamNumber(player:GetTeamNumber())
        
        
        --local Ball = player:CreatePredictedProjectile(Ball.kMapName, startPoint, startVelocity, 0.25, 0.25, true)
        
    end
    
end

function BallThrower:GetIsDroppable()
    return false
end

Shared.LinkClassToMap("BallThrower", BallThrower.kMapName, networkVars)