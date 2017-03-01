Script.Load("lua/Weapons/Weapon.lua")


class 'AxeAvoca' (Axe)

AxeAvoca.kMapName = "axeavoca"

function AxeAvoca:GetHUDSlot()
return 6
end
function AxeAvoca:OnPrimaryAttack(player)
     Axe.OnPrimaryAttack(self, player)
     
     if GetBallForPlayerOwner(player) then return end
     
    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    local startPoint = player:GetEyePos() + viewCoords.zAxis * 1
    local extents = Vector(1, 1, 1) 
    local trace = Shared.TraceBox(extents, startPoint, startPoint + Vector(1,0,1) , CollisionRep.Move, PhysicsMask.Bullets,  EntityFilterOne(player))
   -- local trace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
       
         if trace.entity then
           local classname = trace.entity:GetClassName()
                   Print("Traced entity %s", classname)
         if Server and HasMixin( trace.entity, "Construct" ) and not  trace.entity:isa("CommandStation") then
           local viewAngles = player:GetViewAngles()
           local viewCoords = viewAngles:GetCoords()
           local startVelocity = viewCoords.zAxis * 15
          local newBall = CreateEntity(Ball.kMapName, player:GetOrigin(), player:GetTeamNumber())
        --  newBall:SetMapName(classname) not saving?
          newBall:Setup(player, startVelocity, true, Vector(1.5, 1, 0.4), player, trace.entity:GetModelName())
          newBall:SetParent(player)
          newBall:SetAttachPoint(player:GetBallFlagAttatchPoint())
          newBall:SetTeamNumber(player:GetTeamNumber())
          player:GiveBall()
          DestroyEntity(trace.entity)
          end
         end
         

end


Shared.LinkClassToMap("AxeAvoca", AxeAvoca.kMapName, networkVars)