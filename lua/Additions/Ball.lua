--Kyle 'Avoca' Abent
local networkVars = {} 
Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Additions/BallGoal.lua")
Script.Load("lua/TeamMixin.lua")


class 'Ball' (Projectile)

Ball.kMapName = "Ball"
Ball.kRadius = 0.05
local kLifetime = 5


AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function Ball:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    self.lastOwner = Entity.invalidI 
    self:SetPhysicsGroup(PhysicsGroup.RagdollGroup)
    
end

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