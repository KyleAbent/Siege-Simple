--Kyle 'Avoca' Abent

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Additions/BallGoal.lua")
Script.Load("lua/TeamMixin.lua")


class 'Ball' (Projectile)

Ball.kMapName = "Ball"
Ball.kRadius = 0.05
local kLifetime = 5

local networkVars = { 

 --mapname = "string (128)",


 } 

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function Ball:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    self:SetPhysicsGroup(PhysicsGroup.RagdollGroup)
   -- self.mapname = derp
    
end
/*
function Ball:GetDropMapName()
 if Server then
  local toreturn =  self.mapname
 Print("GetDropMapName is %s", toreturn)
    return toreturn
    end
end
*/
function Ball:StartTimer()
  --self:GetDropMapName() 
--self:AddTimedCallback(Ball.IfConvertingEntity, math.random(4,8))
self:AddTimedCallback(Ball.Destroy, math.random(4,8))
end
function Ball:Destroy()
  DestroyEntity(self)
  return false
end
/*
function Ball:IfConvertingEntity()
 if self:GetDropMapName() ~= derp then
                local newEntity = CreateEntity(self:GetDropMapName(), self:GetOrigin(), 1)
                newEntity:SetConstructionComplete()
                DestroyEntity(self)
 end
    return false
end

function Ball:SetMapName(mapname)
      Print("set map name to %s", mapname)
     self.mapname = mapname
           self:GetDropMapName()
end
*/
function Ball:OnInitialized()

    Projectile.OnInitialized(self)
    
    if Server then
        self:AddTimedCallback(Ball.PickUp, 1)

     elseif Client then
                  local model = self:GetRenderModel()
              if self:GetTeamNumber() == 2 then
              HiveVision_AddModel( model, kHiveVisionOutlineColor.Green )
              elseif self:GetTeamNumber() == 1 then
              EquipmentOutline_AddModel( model, kEquipmentOutlineColor.TSFBlue )
              end
    end

end
if Server then

    function Ball:ProcessHit(targetHit, surface, normal)
    
        if (not self:GetOwner() or targetHit ~= self:GetOwner()) then
            --DestroyEntity(self)
        end
        local owner = self:GetOwner()
        if targetHit and owner then
        if self:GetTeamNumber() == 1 and HasMixin(targetHit, "Construct") and targetHit:GetTeamNumber() == 2 then
           MichaelBayThisBitch(targetHit, Hive.kMapName)
        elseif self:GetTeamNumber() == 2 and HasMixin(targetHit, "Construct") and targetHit:GetTeamNumber() == 1 then
         MichaelBayThisBitch(targetHit, CommandStation.kMapName)
        end
        end
        
    end
    
    function Ball:PickUp(currentRate)
    
       local playersNearby = GetEntitiesWithinXZRangeAreVisible( "Player", self:GetOrigin(), 1.5, true)
        Shared.SortEntitiesByDistance(self:GetOrigin(), playersNearby)

        for _, player in ipairs(playersNearby) do
        
            if not player:isa("Commander")  then
            
               -- self:OnTouch(player)
               -- DestroyEntity(self) why delete and destroy? SEX & VIOLENCE!
                self:SetParent(player)
                self:SetAttachPoint(player:GetBallFlagAttatchPoint())
                player:GiveBall()
                self.lastOwner = player:GetId()
                break
                
            end
        
        end
       -- DestroyEntity(self)
        return true
        
    end
    
end

Shared.LinkClassToMap("Ball", Ball.kMapName, networkVars)