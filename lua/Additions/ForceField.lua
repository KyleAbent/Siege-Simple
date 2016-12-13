Script.Load("lua/ScriptActor.lua")
Script.Load("lua/LiveMixin.lua")

class 'ForceField' (ScriptActor) 
ForceField.kMapName = "forcefield"

local networkVars = { scale = "vector" }

ForceField.kModelName = PrecacheAsset("models/effects/proximity_force_field_noentry.model")

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)





function ForceField:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)

    self:SetPhysicsType(PhysicsType.Kinematic) --?
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    
    self.scale.x =  32.22
    self.scale.y =  14.36
    self:AddTimedCallback(ForceField.UpdateModelStuffMaybe, 1)

end

function ForceField:OnInitialized()
    Shared.PrecacheModel(ForceField.kModelName) 
    ScriptActor.OnInitialized(self)
    self:SetModel(ForceField.kModelName)
end
function ForceField:UpdateModelStuffMaybe()
                self:UpdateModelCoords()
                self:UpdatePhysicsModel()
               if (self._modelCoords and self.boneCoords and self.physicsModel) then
              self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
               end  
               self:MarkPhysicsDirty()    
               return false
end
function ForceField:GetCanSleep()
return true
end
function ForceField:OnAdjustModelCoords(coords)
    
        coords.xAxis = coords.xAxis * self.scale.x
        coords.yAxis = coords.yAxis * self.scale.y
        coords.zAxis = coords.zAxis 
        
    return coords
    
end


Shared.LinkClassToMap("ForceField", ForceField.kMapName, networkVars)