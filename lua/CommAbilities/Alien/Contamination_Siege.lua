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
local function GetNearestToBile(self)
local where = self:GetOrigin()
local random = {}
    for _, ent in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live",1, where, self:GetCurrentInfestationRadius() )) do
       table.insert(random, ent)
    end
    
    if #random >= 1 then
     where = table.random(random):GetOrigin()
    end
    
    return where
end
local function GetScalar()
  --NowToSiegeOpen
  if GetSiegeDoorOpen() then
  return 0.7
  else 
  return 0.3
  end
  
end
local function SpewBile( self )
    local team1Commander = GetGamerules().team1:GetCommander() 
    local team2Commander = GetGamerules().team2:GetCommander() 
    if not self:GetIsAlive() or team2Commander or ( team1Commander and not GetSiegeDoorOpen() ) then
        return false
    end
    
    local dotMarker = CreateEntity( DotMarker.kMapName, GetNearestToBile(self), self:GetTeamNumber() )
    dotMarker:SetDamageType( kBileBombDamageType )
    dotMarker:SetLifeTime( kBileBombDuration * 0.7 )
    dotMarker:SetDamage( kBileBombDamage * GetScalar() )
    dotMarker:SetRadius( kBileBombSplashRadius )
    dotMarker:SetDamageIntervall( kBileBombDotInterval * 0.7 )
    dotMarker:SetDotMarkerType( DotMarker.kType.Static )
    dotMarker:SetTargetEffectName( "bilebomb_onstructure" )
    dotMarker:SetDeathIconIndex( kDeathMessageIcon.BileBomb )
    dotMarker:SetOwner( self:GetOwner() )
    dotMarker:SetFallOffFunc( SineFalloff )
    dotMarker:TriggerEffects( "bilebomb_hit" )
    return true
    
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
         self:DoYourBusiness()
       self:AddTimedCallback(Contamination.DoYourBusiness, GetLifeSpan(self) / 4 )
        if not GetWhereIsInSiege(self:GetOrigin()) then self:AddTimedCallback( SpewBile, 1 ) end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
       
        self.infestationDecal = CreateSimpleInfestationDecal(1, coords)
    
    end

end

if Server then

function Contamination:DoYourBusiness()

   -- Print("DoYourBusiness")
      if not self:GetIsAlive() or not GetHasTech(self, kTechId.CragHive ) then return false end
         local egg = GetEntitiesForTeam( "Egg", 2 )
         local count = table.count(egg) or 0
      for i = 1, #egg do
       local actualegg = egg[i]
       local distance = self:GetDistance(actualegg)
       if distance >=8 then
           if HasMixin(actualegg, "Obstacle") then  actualegg:RemoveFromMesh()end
           actualegg:SetOrigin(FindFreeSpace(self:GetOrigin(), 1, 8))
           actualegg:SetHive(self)
              if HasMixin(actualegg, "Obstacle") then
                 if actualegg.obstacleId == -1 then actualegg:AddToMesh() end
              end
                             
           return self:GetIsAlive()
       end
      
      end
    local spawnpoint = FindFreeSpace(self:GetOrigin(), .5, 7, true)
    if spawnpoint and count < 16 then
     local eggy = CreateEntity(Egg.kMapName, spawnpoint, 2)
    --        egg:AddTimedCallback(function()  DestroyEntity(egg) end, 30)
            eggy:SetHive(self)
    end
   
    return self:GetIsAlive()
end



end

function Contamination:StartBeaconTimer()

self:AddTimedCallback(Contamination.DelayActivation, math.random(1,8))

end

function Contamination:DelayActivation()
return GetImaginator():HandleIntrepid(self)
end


Shared.LinkClassToMap("Contamination", Contamination.kMapName, networkVars)
