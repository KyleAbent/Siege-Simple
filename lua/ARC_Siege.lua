
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")

local networkVars =
{
   lastWand = "private time",
}
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)

local origcreate = ARC.OnCreate
function ARC:OnCreate()
origcreate(self)
self.lastWand = 0
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
     self.startsBuilt = not self:isa("ARCCredit")
end
if Server then


 function ARC:CreateScan()
    local origin = self:GetOrigin()
    local isSiege = GetIsInSiege(self)
        if isSiege then
          local hive =  GetNearest(origin, "Hive", 2)
           if hive then
              origin = hive:GetOrigin()
           end
        end
        if not GetHasActiveObsInRange(self:GetOrigin() ) or isSiege then 
        local scan = CreateEntity(Scan.kMapName, origin, 1)
        end
 end
 function ARC:Instruct()
     self:SpecificRules()
   return true
end
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
local function GetSiegeLocation()
--local locations = {}

local hive = nil

 for _, hivey in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
    hive = hivey
 end
 local siegeloc = nil
 if hive ~= nil then
  siegeloc = GetNearest(hive:GetOrigin(), "Location", nil, function(ent) return string.find(ent.name, "siege") or string.find(ent.name, "Siege") end)
 end
 
if siegeloc then return siegeloc end
 return nil
end
local function MoveToPowers(self)
   --Austin 
      if GetIsTimeUp(self.lastWand, math.random(8, 16) ) then
      local where = FindFreeSpace(GetRandomPowerOrigin(), 4, 24)
      if where then
     self:GiveOrder(kTechId.Move, nil, where, nil, true, true)
     end
     
     self.lastWand = Shared.GetTime()
     
     end
     
end
local function FindSiegeTP(self)

  local tp = GetNearest(self:GetOrigin(), "TeleportTrigger", nil, function(ent) return GetWhereIsInSiege(ent:GetOrigin()) end)
  
  if tp then
  
  return true, tp:GetOrigin()
  
  end
  
  return false, nil


end
local function MoveToHives(self) 
local siegelocation = GetSiegeLocation()
if not siegelocation then return true end
local siegepower = GetPowerPointForLocation(siegelocation.name)
local hasSiegeTP, tpLocation = FindSiegeTP(self)
local where = FindArcHiveSpawn(siegepower:GetOrigin()) 
                       --Some maps have a TP rather than path, so go to tp then teleport to siege :P.
                       if hasSiegeTP and tpLocation then
                           if self:GetDistance(tpLocation) <= 4 then
                              self:SetOrigin( where ) -- h4x
                              self:SetMode(ARC.kMode.Stationary)
                              return true
                           else
                              where = tpLocation
                           end
                       end
                       
               if where then
                      self:GiveOrder(kTechId.Move, nil, where, nil, true, true)
                end 
                 
   return true
end
local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTarget(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end
local function GetIsInRadius(self)

      if GetSiegeDoorOpen() then
     return  GetIsInSiege(self) and GetIsPointWithinHiveRadius(self:GetOrigin())
     else
     return  CheckForAndActAccordingly(self)  
     end
  
end
local function MoveAccordingly(self)
        if GetSiegeDoorOpen() then 
          -- Print("Apparently siege is open")
           MoveToHives(self) 
          else
         --   Print("Siege aint open")
             MoveToPowers(self)
           end
end
function ARC:SpecificRules()
--Print("Siegearc SpecificRules")
local moving = self.mode == ARC.kMode.Moving     
--Print("moving is %s", moving) 
        
local attacking = self:GetInAttackMode()
--Print("attacking is %s", moving) 
local inradius = GetIsInRadius(self)
--Print("inradius is %s", inradius) 

local shouldstop = not true
--Print("shouldstop is %s", shouldstop) 
local shouldmove = not moving and not inradius
--Print("shouldmove is %s", shouldmove) 
local shouldstop = moving and inradius
--Print("shouldstop is %s", shouldstop) 
local shouldattack = inradius and not attacking 
--Print("shouldattack is %s", shouldattack) 
local shouldundeploy = attacking and not inradius and not moving
--Print("shouldundeploy is %s", shouldundeploy) 
  
  if moving then
    
    if shouldstop or shouldattack then 
       --Print("StopOrder")
       FindNewParent(self)
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
         --Print("ShouldUndeploy")
         GiveUnDeploy(self)
       else --should move
       --Print("GiveMove")
          MoveAccordingly(self)
       end
       
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
    
 end
 
    end
end


local origrules = ARC.AcquireTarget
function ARC:AcquireTarget() 

local canfire = GetSetupConcluded() and not self:GetIsVortexed()
--Print("Arc can fire is %s", canfire)
if not canfire then return end
return origrules(self)

end



end

function ARC:GetIsBuilt()
 return self:GetIsAlive()
end

Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)



 

/*
local function DoNotEraseTarget(self)
   local currentOrder = self:GetCurrentOrder()
    if self:GetInAttackMode() then
        if self.targetPosition then
            local targetEntity = Shared.GetEntity(self.targetedEntity)
            if targetEntity then
                self.targetPosition = targetEntity:GetOrigin()
                self:SetTargetDirection(self.targetPosition)
            end
        end
     end
     
end
if Server then

local origorders = ARC.UpdateOrders
function ARC:UpdateOrders(deltaTime)
   if self.targetPosition and self:GetInAttackMode() and GetIsInSiege(self) then
       DoNotEraseTarget(self)
       return 
   end
  origorders(self, deltaTime)

end

end//server
    */
    
   

