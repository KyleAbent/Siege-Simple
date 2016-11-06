/*
  TODO: 
  Points on kill
  nanoshield on first weld
  weld speed bonus while nano shielded
  physics type adjustment
  back posture damage
  possible transition into broken model, not sure. I like infinite doors with delays and weld bonus with nano.
  minimap
*/

Script.Load("lua/LiveMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/StaticTargetMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/WeldableMixin.lua")

class 'BreakableDoor' (ScriptActor)

BreakableDoor.kMapName = "breakable_door"

local kModelNameDefault = PrecacheAsset("models/misc/door/door.model")
local kDoorAnimationGraph = PrecacheAsset("models/misc/door/door.animation_graph")
local networkVars =
{
     open = "boolean",
     team = "integer (0 to 2)",
     ---add in time last destroyed to delay weldtime

}
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function BreakableDoor:OnCreate()

        ScriptActor.OnCreate(self)
       InitMixin(self, BaseModelMixin)
       InitMixin(self, ModelMixin)
       InitMixin(self, LiveMixin)
       InitMixin(self, CombatMixin)
       InitMixin(self, TeamMixin)
       


end
function BreakableDoor:OnInitialized()
        ScriptActor.OnInitialized(self)
    self:SetModel(kModelNameDefault, kDoorAnimationGraph)  
        InitMixin(self, WeldableMixin)
    
   self.open = false
    
    if Server then
            self:SetPhysicsType(PhysicsType.Kinematic)
            self:SetPhysicsGroup(0)
            self.health = 4000  
             self:SetMaxHealth(self.health)
             self.teamNumber = 1
        if not HasMixin(self, "MapBlip") then
           InitMixin(self, MapBlipMixin)
        end
            InitMixin(self, StaticTargetMixin)
          self:SetUpdates(true) 
      elseif Client then
        InitMixin(self, UnitStatusMixin)
        end
        
end
function BreakableDoor:GetCanTakeDamageOverride()
    if self.health == 0 then 
    return false
    else
    return true
    end
end

function BreakableDoor:OnUpdate(deltatime)  --Add in scan for arcs and macs to open for
  if Server then
      if self.health == 0 and not self.open then 
       self.open = true
       return true 
     end
  end
  
end
function BreakableDoor:GetCanTakeDamageOverride()
    return true
end
function BreakableDoor:GetReceivesStructuralDamage()
    return true
end
function BreakableDoor:GetCanDieOverride() 
return false
end
function BreakableDoor:Reset() 
       self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(0)
    self:SetModel(kModelNameDefault, kDoorAnimationGraph)      
   self.open = false
        self.health = 4000
end
  function BreakableDoor:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
     if not self.open then
         unitName = string.format(Locale.ResolveString("Locked Door"))
     else 
    unitName = string.format(Locale.ResolveString("Open Door"))
     end
return unitName
end  
function BreakableDoor:OnGetMapBlipInfo()

    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
    
    
            blipType = kMinimapBlipType.Door
        blipTeam = self:GetTeamNumber()
    
    return blipType, blipTeam, isAttacked, isParasited
end
function BreakableDoor:GetCanBeUsed(player, useSuccessTable)
   if player:GetTeamNumber() == 1 and self.health > 0 and not self.open then 
    useSuccessTable.useSuccess = true  
   else    
   useSuccessTable.useSuccess = false
    end  
end
local function AutoClose(self, timePassed)
       if self.open then self.open = false end
       return false
end
function BreakableDoor:OnUse(player, elapsedTime, useSuccessTable)

    if not self.open  then
        self.open = true
     end
    self:AddTimedCallback(AutoClose, 4)
end
function BreakableDoor:OnAddHealth()
      if self.open and self.health >= 1 then self.open = false end
end
function BreakableDoor:GetHealthbarOffset()
    return 0.45
end 
function BreakableDoor:GetHealthbarOffset()
    return 0.45
end 
function BreakableDoor:OnUpdateAnimationInput(modelMixin)

    PROFILE("BreakableDoor:OnUpdateAnimationInput")
    
    local open = self.open == true
    local lock = not open
    
    modelMixin:SetAnimationInput("open", open)
    modelMixin:SetAnimationInput("lock", lock)
    
end
function BreakableDoor:GetShowHitIndicator()
    return true
end
function BreakableDoor:GetSendDeathMessageOverride()
    return false
end
function BreakableDoor:GetCanTakeDamageOverride()
    return true
end
Shared.LinkClassToMap("BreakableDoor", BreakableDoor.kMapName, networkVars)