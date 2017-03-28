--Kyle 'Avoca' Abent
class 'AvocaArc' (ARC)

local networkVars = 

{
    waypoint = "private float (1 to 25 by 0)",

}


AvocaArc.kMapName = "avocaarc"
local kNanoshieldMaterial = PrecacheAsset("Glow/green/green.material")
local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

function AvocaArc:OnCreate()
 ARC.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
  self.waypoint= 1
end
function AvocaArc:OnInitialized()
 ARC.OnInitialized(self)
   if Server then
 self:AddTimedCallback(AvocaArc.Instruct, 1)
 --self:AddTimedCallback(AvocaArc.Waypoint, 16)
 -- self:AddTimedCallback(AvocaArc.Scan, 6)
 end

end
function AvocaArc:GetPointValue()
 return kARCPointValue
end

function AvocaArc:GetMaxHealth()
    return 4200
end
function AvocaArc:GetMaxArmor()
    return 1000
end
local function SoTheGameCanEnd(self, who)
   local scan = #GetEntitiesWithinRange("Scan", who:GetOrigin(), ARC.kFireRange) or 0
   if not scan then CreateEntity(Scan.kMapName, who:GetOrigin(), 1) end
end
local function CheckHivesForScan()
local hives = {}
           for _, hiveent in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
             table.insert(hives, hiveent)
          end
          if #hives == 0 then return end
          --Scan hive if arc in range, only 1 check per hive.. not per arc.. or whatever. 
          for i = 1, #hives do
             local ent = hives[i]
             SoTheGameCanEnd(self, ent)
          end
end
function ARC:GetShowDamageIndicator()
    return true
end
function AvocaArc:GetHighestWaypointCount()
    return  #GetEntitiesWithinRange("FuncTrainWaypoint", self:GetOrigin(), 9999999) or 0
end
function AvocaArc:GetHighestWaypoint()
    local count = #GetEntitiesWithinRange("FuncTrainWaypoint", self:GetOrigin(), 9999999) or 0
        for _, ent in ientitylist(Shared.GetEntitiesWithClassname("FuncTrainWaypoint")) do 
           if ent.number == count then
             return ent
          end       
    end  
end
local function MoveToHives(who) --Closest hive from origin
if not GetFrontDoorOpen() then return true end
local where = who:GetOrigin()
local destination = Vector(0,0,0)
local self = who
 local nextDestination = nil
 local count = #GetEntitiesWithinRange("FuncTrainWaypoint", who:GetOrigin(), 9999999) or 0
 
 // Print("Self waypoint is %s", self.waypoint)
  
    local toMatch = self.waypoint
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("FuncTrainWaypoint")) do 
           if ent.number == toMatch then
            self.waypoint = ent.number
            destination = ent:GetOrigin()
            break
          end       
    end  
    
    local toBreak = toMatch + 1
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("FuncTrainWaypoint")) do 
                if ent.number == toBreak then
                nextDestination = ent:GetOrigin()
                break
             end
    end     

  local closertoNext =(self:GetOrigin() - destination ):GetLength() <=  1 //and ( self:GetOrigin() - nextDestination) >= 
  local getIsNear 
  
    //Print("closertoNext is %s", closertoNext)   
          if closertoNext then
              destination = nextDestination
              self.waypoint = toBreak
          end


                    if self.waypoint > count then
                     //   Print("Count is %s", count)
                        // end of track
                        //self.driving = false
                        //TODO : what happens then?
                        self.waypoint = 1
                    end
                    
                    who:GiveOrder(kTechId.Move, nil, destination, nil, true, true)
                //    Print("Self waypoint is %s", self.waypoint)
              
         
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
local function PlayersNearby(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 5.5)
local alive = false
    if not who:GetInAttackMode() and #players >= 1 then
         for i = 1, #players do
            local player = players[i]
            if player:GetIsAlive() and alive == false then alive = true end
            if ( player:GetIsAlive() and  player.GetIsNanoShielded and not player:GetIsNanoShielded()) then player:ActivateNanoShield() end
           if player:isa("Marine")  then
             if ( player:GetHealth() == player:GetMaxHealth() ) then
           local addarmoramount = math.random(4,8)
           addarmoramount = who:GetInAttackMode() and addarmoramount * 1.5 or addarmoramount
           player:AddHealth(addarmoramount, false, not true, nil, nil, true)
           else
           player:AddHealth(Armory.kHealAmount, false, false, nil, nil, true)   
           end
           end
         end
    end
return alive
end
if Server then

    function AvocaArc:OnOrderComplete(currentOrder)

        if currentOrder == kTechId.Move then
          self:ClearOrders()
        end
    
    end
    
    end
function AvocaArc:SpecificRules() 

//local moving = self.mode == ARC.kMode.Moving     
//Print("moving is %s", moving) 
        
local attacking = self:GetInAttackMode()
//Print("attacking is %s", moving) 
local inradius = (self:GetOrigin() == self:GetHighestWaypoint():GetOrigin()() )  and GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
--if inradius then self:Scan() end
//Print("inradius is %s", inradius) 

local shouldstop = not PlayersNearby(self)
//Print("shouldstop is %s", shouldstop) 
local shouldmove = not shouldstop and not inradius
//Print("shouldmove is %s", shouldmove) 
//local shouldstop = moving and not PlayersNearby(self)
//Print("shouldstop is %s", shouldstop) 
local shouldattack = inradius and not attacking 
//Print("shouldattack is %s", shouldattack) 
local shouldundeploy = attacking and not inradius
//Print("shouldundeploy is %s", shouldundeploy) 
  
    
    if shouldstop or shouldattack then 
     //  Print("StopOrder")
       FindNewParent(self)
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
         --Print("ShouldUndeploy")
         GiveUnDeploy(self)
       else --should move
      // Print("GiveMove")
       MoveToHives(self)
       end
       
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
   end
 
end
function AvocaArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

function AvocaArc:GetDamageType()
return kDamageType.StructuresOnly
end

function AvocaArc:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.ARC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
function AvocaArc:Waypoint()
    for _, marine in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 9999)) do
                     if  marine:GetClient():GetIsVirtual() and  marine:GetIsAlive() and not marine:isa("Commander") then
                     marine:GiveOrder(kTechId.Defend, self:GetId(), self:GetOrigin(), nil, true, true)
                     end
    end
    return true
end


function AvocaArc:Instruct()
   CheckHivesForScan()
   self:SpecificRules()
   return true
end




end



if Client then

    function AvocaArc:OnUpdateRender()
          local showMaterial = not self:GetInAttackMode()
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client


Shared.LinkClassToMap("AvocaArc", AvocaArc.kMapName, networkVars)