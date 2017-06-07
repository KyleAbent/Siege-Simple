--Kyle Abent
Script.Load("lua/Additions/DigestCommMixin.lua")
Script.Load("lua/Additions/SaltMixin.lua")
Script.Load("lua/InfestationMixin.lua")
local networkVars = {calling = "boolean", receiving = "boolean"} 
AddMixinNetworkVars(DigestCommMixin, networkVars)
AddMixinNetworkVars(SaltMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
local origcreate = Shift.OnCreate
function Shift:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
        InitMixin(self, SaltMixin)
 end
function Shift:GetMinRangeAC()
return ShiftAutoCCMR    
end

local originit = Shift.OnInitialized
function Shift:OnInitialized()
originit(self)
self.calling = false
self.receiving = false
InitMixin(self, InfestationMixin)
end
  function Shift:GetInfestationRadius()
    if self:GetIsACreditStructure() then
    return 1
    else
    return 0
    end
end
local origsppeed = Shift.GetMaxSpeed
function Shift:GetMaxSpeed()
    local speed = origsppeed(self)
          --Print("1 speed is %s", speed)
          speed = Clamp( (speed * kALienCragWhipShadeShiftDynamicSpeedBpdB) * GetRoundLengthToSiege(), speed, speed * kALienCragWhipShadeShiftDynamicSpeedBpdB)   --- buff when siege is open
          --Print("2 speed is %s", speed)
    return speed
end
local origbuttons = Shift.GetTechButtons
function Shift:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)
  if techId ~= kTechId.ShiftEcho then
 table[4] = kTechId.ShiftEnzyme
  table[6] = kTechId.ShiftCall
  table[7] = kTechId.ShiftReceive
  table[8] = kTechId.DigestComm
  end
 return table

end
function Shift:GetCanShiftCallRec()
 return self:GetIsBuilt() --and not self.calling
end
  function Shift:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
      if self.calling then
   unitName = string.format(Locale.ResolveString("%s (Calling!)"), unitName)
    elseif self.receiving then
   unitName = string.format(Locale.ResolveString("%s (Receiving!!)"), unitName)
   end
return unitName
end 
local origact = Shift.PerformActivation
function Shift:PerformActivation(techId, position, normal, commander)
origact(self, techId, position, normal, commander)

local success  = false
   if  techId == kTechId.ShiftEnzyme then
    success = self:TriggerEnzyme()
   elseif techId == kTechId.ShiftCall then
     self.calling = not self.calling
    self.receiving = false
    success = true
   elseif techId == kTechId.ShiftReceive and not GetIsInSiege(self) then
       self.receiving = not self.receiving
      self.calling =  false
       success = true
      end

return success, true

end
function Shift:CheckForAndActOn() -- Insta Teleport with 0 tres cost OP? Add limit? Time Delay? if 12 then take 3 at a time?
 --Print("Calling 3")
local receivingOrigin = nil
      for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Shift")) do
            if entity.receiving then receivingOrigin = entity:GetOrigin() break end --Print("Calling 4") break  end
      end
 if not receivingOrigin then return end
    --Print("Calling 5")
    local eligable = {}
     local teleportAbles = GetEntitiesWithMixinForTeamWithinRange("Construct", 2, self:GetOrigin(), kEchoRange)
       if not teleportAbles then return end
         for _, teleportable in ipairs(teleportAbles) do
             if teleportable.GetCanShiftCallRec and teleportable:GetCanShiftCallRec() and self ~= teleportable then
              table.insert(eligable, teleportable)
             end
         end

                 
      for _, egg in ipairs(GetEntitiesForTeamWithinRange("Egg", 2, self:GetOrigin(), kEchoRange)) do
            if egg then table.insert(eligable, egg) end
      end
   --Print("Calling 6")
    for _, teleportable in ipairs(eligable) do
    
          --Print("Calling 7")
              teleportable:SetOrigin( FindFreeSpace(receivingOrigin, 1, kEchoRange, true)) 
                    if HasMixin(teleportable, "Orders") then
                   --  Print("Calling 8")
                        teleportable:ClearCurrentOrder()
                    end
                   --  Print("Calling 9")
                    self:TriggerEffects("shift_echo")
                    success = true
                    self.echoActive = true
    end
    
    self.echoActive = false -- ?
 
end
local origupdate = Shift.OnUpdate
function Shift:OnUpdate(deltaTime)
  origupdate(self, deltaTime)
 if Server then
  if self.calling then
     --Print("Calling 1")
    if not self.timelastCallCheck or self.timelastCallCheck + 4 < Shared.GetTime() then
      self:CheckForAndActOn()
      self.timelastCallCheck = Shared.GetTime()
     --  Print("Calling 2")
    end
  --elseif self.receiving then
  
  end
  end
end
function Shift:TriggerEnzyme()

         if Server then
             local enzyme = CreateEntity(EnzymeCloud.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
         end
              return true     
end
Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)