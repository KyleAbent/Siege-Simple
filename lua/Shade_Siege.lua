Script.Load("lua/Additions/DigestCommMixin.lua")
Script.Load("lua/Additions/SandMixin.lua")
Script.Load("lua/InfestationMixin.lua")
local networkVars = {}
AddMixinNetworkVars(DigestCommMixin, networkVars)
AddMixinNetworkVars(SandMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)

local origcreate = Shade.OnCreate
function Shade:OnCreate()
    origcreate(self)
    InitMixin(self, DigestCommMixin)
        InitMixin(self, SandMixin)
 end
local originit = Shade.OnInitialized
function Shade:OnInitialized()
originit(self)
InitMixin(self, InfestationMixin)
end
  function Shade:GetInfestationRadius()
    if self:GetIsACreditStructure() then
    return 1
    else
    return 0
    end
end
function Shade:GetMinRangeAC()
return ShadeAutoCCMR     
end
local origsppeed = Shade.GetMaxSpeed
function Shade:GetMaxSpeed()
    local speed = origsppeed(self)
          --Print("1 speed is %s", speed)
         -- speed = Clamp( (speed * kALienCragWhipShadeShiftDynamicSpeedBpdB) * GetRoundLengthToSiege(), speed, speed * kALienCragWhipShadeShiftDynamicSpeedBpdB)   --- buff when siege is open
          --Print("2 speed is %s", speed)
    return speed * 1.25
end
local origbuttons = Shade.GetTechButtons
function Shade:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[4] = kTechId.ShadeHallucination
 table[8] = kTechId.DigestComm
 return table

end

local origact = Shade.PerformActivation
function Shade:PerformActivation(techId, position, normal, commander)
local success = origact(self, techId, position, normal, commander)


   if  techId == kTechId.ShadeHallucination then
    success = self:TriggerHallucination()
end

return success, true

end
function Shade:GetCanShiftCallRec()
 return self:GetIsBuilt()
end
function Shade:TriggerHallucination()

         if Server then
             local hallucination = CreateEntity(HallucinationCloud.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
         end
             return true      
end

Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)