Script.Load("lua/ScriptActor.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/MapBlipMixin.lua")

class 'Wall' (ScriptActor) 
Wall.kMapName = "wall"
Wall.kModelName = PrecacheAsset("models/props/eclipse/eclipse_wallmods01_03.model")

local networkVars = { }



AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)





function Wall:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, PointGiverMixin)

    self:SetPhysicsType(PhysicsType.Kinematic) --?
    self:SetPhysicsGroup(PhysicsGroup.WallGroup)
    
   

end

function Wall:OnInitialized()
    Shared.PrecacheModel(Wall.kModelName) 
    ScriptActor.OnInitialized(self)
    InitMixin(self, WeldableMixin)
    self:SetModel(Wall.kModelName)
    if Server then
    
       if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    
    elseif Client then
       InitMixin(self, UnitStatusMixin)
    end
end

function Wall:GetReceivesStructuralDamage()
    return true
end
function Wall:OnGetMapBlipInfo()

    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
    
    
        blipType = kMinimapBlipType.Door
        blipTeam = self:GetTeamNumber()
    
    return blipType, blipTeam, isAttacked, isParasited
end
function Wall:GetHealthbarOffset()
    return 0.25
end 
if Server then

    function Wall:OnKill()

        self:TriggerEffects("death")
        DestroyEntity(self)
    
    end

end
Shared.LinkClassToMap("Wall", Wall.kMapName, networkVars)