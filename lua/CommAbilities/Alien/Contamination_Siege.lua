Script.Load("lua/PointGiverMixin.lua")
local networkVars = {}
local function TimeUp(self)
    self:Kill()
    return false
end
local function GetLifeSpan(self)
local default = kContaminationLifeSpan
return ConditionalValue(not GetIsInSiege(self), default * math.random(.10, .30) + default, default)
end
function Contamination:GetPointValue()
    return 3
end
function Contamination:GetInfestationGrowthRate()
    return ConditionalValue(not GetIsInSiege(self), 0.625, 0.5)
end
function Contamination:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and doer ~= nil and doer:isa("Minigun") then
    
        damageTable.damage = damageTable.damage * 0.9
        --self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end

end
local origcreate = Contamination.OnCreate
function Contamination:OnCreate()
    origcreate(self)
    InitMixin(self, PointGiverMixin)
end
function Contamination:OnInitialized()

    ScriptActor.OnInitialized(self)

    InitMixin(self, InfestationMixin)
    
    self:SetModel(Contamination.kModelName, kAnimationGraph)

    local coords = Angles(0, math.random() * 2 * math.pi, 0):GetCoords()
    coords.origin = self:GetOrigin()
    
    if Server then
             if not Shared.GetCheatsEnabled() then
               if not GetFrontDoorOpen() then 
               DestroyEntity(self)
               end
           end
        InitMixin( self, StaticTargetMixin )
        self:SetCoords( coords )
        
        self:AddTimedCallback( TimeUp, GetLifeSpan(self) )
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
       
        self.infestationDecal = CreateSimpleInfestationDecal(1, coords)
    
    end

end
Shared.LinkClassToMap("Contamination", Contamination.kMapName, networkVars)
