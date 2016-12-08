--Kyle 'Avoca' Abent
class 'PLArc' (ARC)
PLArc.kMapName = "plarc"
local kNanoshieldMaterial = PrecacheAsset("Glow/green/green.material")
local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

function PLArc:OnInitialized()
ARC.OnInitialized(self)
 if Server then    self:AddTimedCallback(PLArc.Instruct, 2.5) end
end
function PLArc:OnCreate()
 ARC.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())

end
function PLArc:GetMaxHealth()
    return 4000
end
function PLArc:GetMaxArmor()
    return 1200
end

function ARC:GetShowDamageIndicator()
    return true
end
local function MoveToHives(who) --Closest hive from origin
local where = who:GetOrigin()
 local hive =  GetNearest(where, "Hive", 2, function(ent) return not ent:GetIsDestroyed() end)

 
               if hive then
        local origin = hive:GetOrigin() -- The arc should auto deploy beforehand
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                    return
                end  
    -- Print("No closest hive????")    
end

local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTargetActual(enemy, enemy:GetOrigin()) then
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
function PLArc:Scan()
   local scan = GetEntitiesWithinRange("Scan", who:GetOrigin(), ARC.kFireRange)
  if not #scan >=1 then CreateEntity(Scan.kMapName, self:GetOrigin(), 1) end

end
function PLArc:SpecificRules()
--How emberassing to have the 6.22 video show off broken lua but hey that what's given after only 6 hours
--and saying i would come back to fix the hive origin and of course fix the actual function of the intention
--of payload rules xD
--local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) --or CheckForAndActAccordingly(self)  
--Print("SpecificRules")

local moving = self.mode == ARC.kMode.Moving     
--Print("moving is %s", moving) 
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
--Print("attacking is %s", moving) 
local inradius = GetIsPointWithinHiveRadius(self:GetOrigin()) or CheckForAndActAccordingly(self)  
if inradius then self:Scan() end
--Print("inradius is %s", inradius) 

local shouldstop = not PlayersNearby(self)
--Print("shouldstop is %s", shouldstop) 
local shouldmove = not shouldstop and not moving and not inradius
--Print("shouldmove is %s", shouldmove) 
local shouldstop = moving and not PlayersNearby(self)
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
       MoveToHives(self)
       end
       
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
    
 end
 
    end
    
end

if Client then

    function PLArc:OnUpdateRender()
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
function PLArc:OnGetMapBlipInfo()
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
function PLArc:Instruct()
   self:SpecificRules()
   return true
end



Shared.LinkClassToMap("PLArc", PLArc.kMapName, networkVars)