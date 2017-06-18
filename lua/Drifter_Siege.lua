--All this just to make drifters stack, rediculous.
/*
local networkVars =
{
   isPet = "boolean",
}

local origcreate = Drifter.OnCreate
function Drifter:OnCreate()
origcreate(self)
self.isPet = false
end

  function Drifter:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
      if self.isPet then
   unitName = string.format(Locale.ResolveString("%s (Pet)"), unitName)
     end
return unitName
end 
local origupdate = Drifter.OnUpdate

function Drifter:OnUpdate(deltaTime)
 
         if not  self.timelastPet or self.timelastPet + 8 <= Shared.GetTime() then
        self.timelastPet = Shared.GetTime()
        GetImaginator():ManagePetDrifter(self)
        end
       origupdate(self, deltaTime)  
end
*/
local kDetectInterval = 0.5
local kDetectRange = 1.5
local kDrifterConstructSound = PrecacheAsset("sound/NS2.fev/alien/drifter/drift")
Drifter.kOrdered2DSoundName = PrecacheAsset("sound/NS2.fev/alien/drifter/ordered_2d")
Drifter.kOrdered3DSoundName = PrecacheAsset("sound/NS2.fev/alien/drifter/ordered")
local function ScanForNearbyEnemy(self)

    -- Check for nearby enemy units. Uncloak if we find any.
    self.lastDetectedTime = self.lastDetectedTime or 0
    if self.lastDetectedTime + kDetectInterval < Shared.GetTime() then
    
        if #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kDetectRange) > 0 then
        
            self:TriggerUncloak()
            
        end
        self.lastDetectedTime = Shared.GetTime()
        
    end
    
end

local kDrifterSelfOrderRange = 12

local function IsBeingGrown(self, target)

    if target.hasDrifterEnzyme then
        return true
    end

    for _, drifter in ipairs(GetEntitiesForTeam("Drifter", target:GetTeamNumber())) do
    
        if self ~= drifter then
        
            local order = drifter:GetCurrentOrder()
            if order and order:GetType() == kTechId.Grow then
            
                local growTarget = Shared.GetEntity(order:GetParam())
                if growTarget == target then
                    return true
                end
            
            end
        
        end
    
    end

    return false

end
local function GetSiegeRules(structure)
   if GetSiegeDoorOpen() and structure:isa("Hive") and structure.hasDrifterEnzyme then return false end
   return true
end
local function FindTask(self)

    -- find ungrown structures
    for _, structure in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), kDrifterSelfOrderRange)) do
    
        if GetSiegeRules(structure) and not structure:GetIsBuilt() and (not structure.GetCanAutoBuild or structure:GetCanAutoBuild()) then      
  
            self:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
           
            return  
      
        end
    
    end

end


local function UpdateTasks(self, deltaTime)

    if not self:GetIsAlive() then
        return
    end
    
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        local maxSpeedTable = { maxSpeed = Drifter.kMoveSpeed }
        self:ModifyMaxSpeed(maxSpeedTable)
        local drifterMoveSpeed = maxSpeedTable.maxSpeed

        local currentOrigin = Vector(self:GetOrigin())
        
        if currentOrder:GetType() == kTechId.Move or currentOrder:GetType() == kTechId.Patrol then
            self:ProcessMoveOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder:GetType() == kTechId.Follow then
            self:ProcessFollowOrder(drifterMoveSpeed, deltaTime)     
        elseif currentOrder:GetType() == kTechId.EnzymeCloud or currentOrder:GetType() == kTechId.Hallucinate or currentOrder:GetType() == kTechId.MucousMembrane or currentOrder:GetType() == kTechId.Storm then
            self:ProcessEnzymeOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder:GetType() == kTechId.Grow then
            self:ProcessGrowOrder(drifterMoveSpeed, deltaTime)
        end
        
        -- Check difference in location to set moveSpeed
        local distanceMoved = (self:GetOrigin() - currentOrigin):GetLength()
        
        self.moveSpeed = (distanceMoved / drifterMoveSpeed) / deltaTime
        
    else
    
        if not self.timeLastTaskCheck or self.timeLastTaskCheck + 2 < Shared.GetTime() then
        
            FindTask(self)
            self.timeLastTaskCheck = Shared.GetTime()
        
        end
    
    end
    
end
function Drifter:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    -- Blend smoothly towards target value
    self.moveSpeedParam = Clamp(Slerp(self.moveSpeedParam, self.moveSpeed, deltaTime), 0, 1)
    --UpdateMoveYaw(self, deltaTime)
    
    if Server then
    
        self.constructing = false
        UpdateTasks(self, deltaTime)
        
        ScanForNearbyEnemy(self)
        
        self.camouflaged = (not self:GetHasOrder() or self:GetCurrentOrder():GetType() == kTechId.HoldPosition ) and not self:GetIsInCombat()
--[[
        self.hasCamouflage = GetHasTech(self, kTechId.ShadeHive) == true
        self.hasCelerity = GetHasTech(self, kTechId.ShiftHive) == true
        self.hasRegeneration = GetHasTech(self, kTechId.CragHive) == true
--]]
        --if self.hasRegeneration then
        
            if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then
            
                self:AddHealth(0.06 * self:GetMaxHealth())  
                self.timeLastAlienAutoHeal = Shared.GetTime()
                
            end    
        
        --end
        
        self.canUseAbilities = self.timeAbilityUsed + kDrifterAbilityCooldown < Shared.GetTime()
        
    elseif Client then
    
        self.trailCinematic:SetIsVisible(self:GetIsMoving() and self:GetIsVisible())
        
        if self.constructing and not self.playingConstructSound then
        
            Shared.PlaySound(self, kDrifterConstructSound)
            self.playingConstructSound = true
            
        elseif not self.constructing and self.playingConstructSound then
        
            Shared.StopSound(self, kDrifterConstructSound)
            self.playingConstructSound = false
            
        end
        
    end
    
end
local function PlayOrderedSounds(self)

    StartSoundEffectOnEntity(Drifter.kOrdered3DSoundName, self)
    
    local commanders = GetEntitiesForTeam("Commander", self:GetTeamNumber())
    local currentComm = commanders and commanders[1] or nil
    
    if currentComm then
        Server.PlayPrivateSound(currentComm, Drifter.kOrdered2DSoundName, currentComm, 1.0, Vector(0, 0, 0))
    end
    
end
function Drifter:OnOverrideOrder(order)

    local orderTarget = nil
    
    if order:GetParam() ~= nil then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    local orderType = order:GetType()
    
    if orderType == kTechId.Default or orderType == kTechId.Grow or orderType == kTechId.Move then

        if orderTarget and HasMixin(orderTarget, "Construct") and not orderTarget:GetIsBuilt() and GetAreFriends(self, orderTarget)  and (not orderTarget.GetCanAutoBuild or orderTarget:GetCanAutoBuild()) then    
            order:SetType(kTechId.Grow)
        elseif orderTarget and orderTarget:isa("Alien") and orderTarget:GetIsAlive() then
            order:SetType(kTechId.Follow)
        else
            order:SetType(kTechId.Move)
        end
    
    end
    
    if GetAreEnemies(self, orderTarget) then
        order.orderParam = -1
    end
    
    PlayOrderedSounds(self)
    
end
function Drifter:ProcessGrowOrder(moveSpeed, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    
    if currentOrder ~= nil then
    
        local target = Shared.GetEntity(currentOrder:GetParam())
        
        if not target or target:GetIsBuilt() or not target:GetIsAlive() then        
            self:CompletedCurrentOrder()
        else
        
            local targetPos = target:GetOrigin()  
            local toTarget = targetPos - self:GetOrigin()
                -- Continuously turn towards the target. But don't mess with path finding movement if it was done.

            if (toTarget):GetLength() > 3 then
                self:MoveToTarget(PhysicsMask.AIMovement, targetPos, moveSpeed, deltaTime)
            else
            
                if toTarget then
                    self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
                end
                local speed = 0.025
                if GetSiegeDoorOpen() and target:isa("Hive") then
                    if  GetImaginator():GetAlienEnabled()  then 
                       speed = speed / 4 
                    else
                        speed = speed / 1.3 
                    end
               end
                if IsBeingGrown(self, target) then target:Construct(speed) end
                target:RefreshDrifterConstruct()
                self.constructing = true
            end

        end
    
    end

end
--Shared.LinkClassToMap("Drifter", Drifter.kMapName, networkVars)